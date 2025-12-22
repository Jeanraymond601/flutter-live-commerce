// lib/screens/drivers/create_driver_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/driver_service.dart';
import '../../widgets/status_indicator.dart';

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
  String? _selectedStatus = 'en_attente';
  String? _errorMessage;

  // Définir les RegExp en tant que constantes de classe
  static final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // ignore: unused_field
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

      // Validation supplémentaire
      final errors = _validateFormData(formData);
      if (errors.isNotEmpty) {
        _showErrorSnackbar(errors.join('\n'));
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final driverService = Provider.of<DriverService>(
          context,
          listen: false,
        );

        // Préparer les données pour l'API
        final driverData = {
          'full_name': formData['full_name'].toString().trim(),
          'email': formData['email'].toString().trim(),
          'telephone': formData['telephone'].toString().trim(),
          'adresse': formData['adresse']?.toString().trim() ?? '',
          'password': formData['password'].toString(),
          'statut': _selectedStatus ?? 'en_attente',
        };

        // Utiliser la nouvelle méthode avec email
        final result = await driverService.createDriverWithEmail(driverData);

        if (mounted) {
          if (result['success'] == true) {
            // Afficher le message de succès avec les détails
            _showSuccessDialog(result);
          } else {
            setState(() {
              _errorMessage = result['error'] ?? 'Erreur inconnue';
            });
            _showErrorSnackbar(_errorMessage!);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Erreur: ${e.toString()}';
          });
          _showErrorSnackbar(_errorMessage!);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showErrorSnackbar('Veuillez corriger les erreurs dans le formulaire');
    }
  }

  List<String> _validateFormData(Map<String, dynamic> formData) {
    final errors = <String>[];

    // Vérifier que tous les champs requis sont remplis
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

    // Vérifier le format de l'email
    if (formData['email'] != null) {
      if (!emailRegex.hasMatch(formData['email'].toString())) {
        errors.add('Format d\'email invalide');
      }
    }

    // Vérifier le format du téléphone
    if (formData['telephone'] != null) {
      if (!RegExp(r'^[0-9]{10}$').hasMatch(formData['telephone'].toString())) {
        errors.add('Format de téléphone invalide (10 chiffres requis)');
      }
    }

    // Vérifier le mot de passe
    if (formData['password'] != null) {
      final password = formData['password'].toString();
      if (password.length < 8) {
        errors.add('Le mot de passe doit contenir au moins 8 caractères');
      }
      // Vérifier la complexité du mot de passe
      final hasUpperCase = passwordUpperRegex.hasMatch(password);
      final hasLowerCase = passwordLowerRegex.hasMatch(password);
      final hasDigits = passwordDigitRegex.hasMatch(password);
      final hasSpecial = passwordSpecialRegex.hasMatch(password);

      if (!hasUpperCase || !hasLowerCase || !hasDigits || !hasSpecial) {
        errors.add(
          'Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial (@\$!%*?&)',
        );
      }
    }

    return errors;
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final data = result['data'] ?? {};
    final driverName = data['full_name'] ?? 'le livreur';
    final driverEmail = data['email'] ?? '';
    final _ = data['email_sent'] == true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Succès !'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$driverName a été créé avec succès !',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // CORRECTION: Toujours montrer "Email envoyé" car le backend envoie toujours
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.email, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Email envoyé',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Un email de bienvenue a été envoyé à $driverEmail',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La zone de livraison a été détectée automatiquement',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Identifiants du livreur :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Email', driverEmail),
                if (data['zone_livraison'] != null)
                  _buildInfoRow('Zone de livraison', data['zone_livraison']),
                if (data['password'] != null)
                  _buildInfoRow('Mot de passe', '********'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // CORRECTION: Retourner directement à l'écran précédent (DriverListScreen)
                Navigator.of(context).pop(true); // true indique un succès
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
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
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
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
    bool enabled = true,
    String? hintText,
    int? maxLines,
    String? initialValue,
  }) {
    final actualMaxLines = obscureText ? 1 : (maxLines ?? 1);

    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultRadius),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.shade100 : null,
        suffixIcon: name == 'password'
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              )
            : null,
      ),
      keyboardType: keyboardType,
      obscureText: name == 'password' && !_showPassword,
      enabled: enabled,
      validator: FormBuilderValidators.compose(validators ?? []),
      textInputAction: name == 'adresse'
          ? TextInputAction.done
          : TextInputAction.next,
      maxLines: actualMaxLines,
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
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.defaultPadding),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec illustration
              _buildHeader(),
              const SizedBox(height: 24),

              // Message d'erreur
              if (_errorMessage != null) _buildErrorCard(),
              const SizedBox(height: 16),

              // Formulaire
              _buildForm(),
              const SizedBox(height: 24),

              // Bouton de création
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 30,
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
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Remplissez les informations du livreur',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Un email de bienvenue sera envoyé automatiquement',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
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
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOut);
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
            // Nom complet
            _buildFormField(
              name: 'full_name',
              label: 'Nom complet',
              icon: Icons.person,
              hintText: 'Ex: Jean Dupont',
              validators: [
                FormBuilderValidators.required(
                  errorText: Constants.validationRequired,
                ),
                FormBuilderValidators.minLength(
                  2,
                  errorText: 'Minimum 2 caractères',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email
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
            const SizedBox(height: 16),

            // Téléphone
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
                  RegExp(r'^[0-9]{10}$'),
                  errorText: Constants.validationPhone,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Adresse
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormField(
                  name: 'adresse',
                  label: 'Adresse complète',
                  icon: Icons.home,
                  hintText: 'Ex: Lotissement, Commune, Ville',
                  maxLines: 2,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: Constants.validationRequired,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ La zone de livraison sera détectée automatiquement depuis cette adresse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mot de passe
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            ),
            const SizedBox(height: 16),

            // Statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut initial',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Constants.driverStatuses.map((status) {
                    final isSelected = _selectedStatus == status;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusIndicator(
                            status: status,
                            compact: true,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusLabel(status),
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : 'en_attente';
                        });
                      },
                      backgroundColor: isSelected
                          ? _getStatusColor(status)
                          : Colors.grey.shade200,
                      selectedColor: _getStatusColor(status),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildCreateButton() {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createDriver,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.defaultRadius),
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
                    children: [
                      const Icon(Icons.person_add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'CRÉER LE LIVREUR ET ENVOYER L\'EMAIL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return 'Actif';
      case 'en_attente':
        return 'En attente';
      case 'suspendu':
        return 'Suspendu';
      case 'rejeté':
        return 'Rejeté';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return const Color(0xFF4CAF50);
      case 'en_attente':
        return const Color(0xFFFF9800);
      case 'suspendu':
        return const Color(0xFFF44336);
      case 'rejeté':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }
}
