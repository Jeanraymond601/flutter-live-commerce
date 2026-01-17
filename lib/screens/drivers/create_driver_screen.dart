// lib/screens/drivers/create_driver_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/driver_service.dart';

class CreateDriverScreen extends StatefulWidget {
  const CreateDriverScreen({super.key});

  @override
  State<CreateDriverScreen> createState() => _CreateDriverScreenState();
}

class _CreateDriverScreenState extends State<CreateDriverScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  final String _selectedStatus = 'actif'; // Statut par défaut actif
  String? _errorMessage;

  static final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phoneRegex = RegExp(r'^[0-9]{10}$');
  static final passwordUpperRegex = RegExp(r'[A-Z]');
  static final passwordLowerRegex = RegExp(r'[a-z]');
  static final passwordDigitRegex = RegExp(r'[0-9]');
  static final passwordSpecialRegex = RegExp(r'[@$!%*?&]');

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createDriver() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final errors = _validateFormData(formData);
      if (errors.isNotEmpty) {
        _showErrorSnackbar(errors.join('\n'));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final driverService = Provider.of<DriverService>(
          context,
          listen: false,
        );

        final driverData = {
          'full_name': formData['full_name'].toString().trim(),
          'email': formData['email'].toString().trim(),
          'telephone': formData['telephone'].toString().trim(),
          'adresse': formData['adresse']?.toString().trim() ?? '',
          'password': formData['password'].toString(),
          'statut': _selectedStatus,
        };

        final result = await driverService.createDriverWithEmail(driverData);

        if (mounted) {
          if (result['success'] == true) {
            _showSuccessDialog(result);
          } else {
            setState(
              () => _errorMessage = result['error'] ?? 'Erreur inconnue',
            );
            _showErrorSnackbar(_errorMessage!);
          }
        }
      } catch (e) {
        setState(() => _errorMessage = 'Erreur: ${e.toString()}');
        _showErrorSnackbar(_errorMessage!);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _showErrorSnackbar('Veuillez corriger les erreurs dans le formulaire');
    }
  }

  List<String> _validateFormData(Map<String, dynamic> formData) {
    final errors = <String>[];
    final requiredFields = [
      'full_name',
      'email',
      'telephone',
      'adresse',
      'password',
    ];
    for (final field in requiredFields) {
      if (formData[field] == null || formData[field].toString().isEmpty) {
        errors.add('Le champ $field est requis');
      }
    }
    if (formData['email'] != null &&
        !emailRegex.hasMatch(formData['email'].toString())) {
      errors.add('Format d\'email invalide');
    }
    if (formData['telephone'] != null &&
        !phoneRegex.hasMatch(formData['telephone'].toString())) {
      errors.add('Format de téléphone invalide (10 chiffres requis)');
    }
    if (formData['password'] != null) {
      final password = formData['password'].toString();
      final hasUpperCase = passwordUpperRegex.hasMatch(password);
      final hasLowerCase = passwordLowerRegex.hasMatch(password);
      final hasDigits = passwordDigitRegex.hasMatch(password);
      final hasSpecial = passwordSpecialRegex.hasMatch(password);
      if (password.length < 8 ||
          !hasUpperCase ||
          !hasLowerCase ||
          !hasDigits ||
          !hasSpecial) {
        errors.add(
          'Mot de passe doit avoir majuscule, minuscule, chiffre et caractère spécial (@\$!%*?&)',
        );
      }
    }
    return errors;
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final data = result['data'] ?? {};
    final driverName = data['full_name'] ?? 'le livreur';
    final driverEmail = data['email'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Succès !'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$driverName a été créé avec succès !',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Email', driverEmail),
              if (data['zone_livraison'] != null)
                _buildInfoRow('Zone livraison', data['zone_livraison']),
              if (data['password'] != null)
                _buildInfoRow('Mot de passe', '********'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Retour à la liste'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<FormFieldValidator<String>>? validators,
    bool obscureText = false,
    String? hintText,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: FormBuilderTextField(
          name: name,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: InputBorder.none,
            suffixIcon: name == 'password'
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
          ),
          keyboardType: keyboardType,
          obscureText: name == 'password' && !_showPassword,
          validator: FormBuilderValidators.compose(validators ?? []),
          maxLines: name == 'adresse' ? 2 : 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Livreur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              if (_errorMessage != null) _buildErrorCard(),
              const SizedBox(height: 16),
              _buildForm(),
              const SizedBox(height: 24),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter un nouveau livreur',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Remplissez les informations du livreur',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Un email de bienvenue sera envoyé automatiquement',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideX(begin: -0.5, end: 0, duration: 450.ms);
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildForm() {
    return Column(
          children: [
            _buildFormField(
              name: 'full_name',
              label: 'Nom complet',
              icon: Icons.person,
              hintText: 'Ex: Jean Dupont',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
              ],
            ),
            _buildFormField(
              name: 'email',
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              hintText: 'Ex: jean.dupont@email.com',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
                FormBuilderValidators.email(
                  errorText: Constants.validationEmail,
                ),
              ],
            ),
            _buildFormField(
              name: 'telephone',
              label: 'Téléphone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              hintText: 'Ex: 0341234567',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
                FormBuilderValidators.match(
                  phoneRegex,
                  errorText: Constants.validationPhone,
                ),
              ],
            ),
            _buildFormField(
              name: 'adresse',
              label: 'Adresse complète',
              icon: Icons.home,
              hintText: 'Ex: Lotissement, Commune, Ville',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
              ],
            ),
            _buildFormField(
              name: 'password',
              label: 'Mot de passe',
              icon: Icons.lock,
              obscureText: true,
              hintText: 'Minimum 8 caractères complexes',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
                FormBuilderValidators.minLength(
                  8,
                  errorText: 'Minimum 8 caractères',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Doit contenir: majuscule, minuscule, chiffre et caractère spécial (@\$!%*?&)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, end: 0, duration: 500.ms);
  }

  Widget _buildCreateButton() {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createDriver,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'CRÉER LE LIVREUR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 1, end: 0, duration: 600.ms);
  }
}
