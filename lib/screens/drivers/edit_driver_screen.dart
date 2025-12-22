// lib/screens/drivers/edit_driver_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';
import '../../widgets/zone_detector.dart';
import '../../widgets/status_indicator.dart';

class EditDriverScreen extends StatefulWidget {
  final Driver driver;

  const EditDriverScreen({super.key, required this.driver});

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _passwordController = TextEditingController();

  String _detectedZone = '';
  bool _isLoading = false;
  bool _showPassword = false;
  bool _passwordChanged = false;
  String? _selectedStatus;
  late Driver _originalDriver;

  @override
  void initState() {
    super.initState();
    _originalDriver = widget.driver;
    _selectedStatus = widget.driver.statut;
    _detectedZone = widget.driver.zone_livraison;

    // Initialiser les valeurs du formulaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.patchValue({
        'full_name': widget.driver.fullName,
        'email': widget.driver.email,
        'telephone': widget.driver.telephone,
        'adresse': widget.driver.adresse,
        'password': '', // Mot de passe vide par défaut
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      if (_detectedZone.isEmpty) {
        _showErrorSnackbar('Veuillez détecter la zone de livraison');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final driverService = context.read<DriverService>();

        // Préparer les données de mise à jour
        final updateData = <String, dynamic>{
          'full_name': formData['full_name'],
          'email': formData['email'],
          'telephone': formData['telephone'],
          'adresse': widget.driver.adresse, // On garde l'adresse originale
          'zone_livraison': _detectedZone,
          'statut': _selectedStatus,
          'disponibilite': widget.driver.disponibilite,
        };

        // Ajouter le mot de passe seulement s'il a été modifié
        if (_passwordChanged && formData['password']?.isNotEmpty == true) {
          updateData['password'] = formData['password'];
        }

        final updatedDriver = await driverService.updateDriver(
          widget.driver.id,
          updateData,
        );

        if (mounted) {
          Navigator.of(context).pop(updatedDriver);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Livreur modifié avec succès !',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('Erreur: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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

  void _onZoneDetected(String zone) {
    setState(() {
      _detectedZone = zone;
    });
  }

  bool _hasChanges() {
    final formData = _formKey.currentState?.value ?? {};

    return formData['full_name'] != _originalDriver.fullName ||
        formData['email'] != _originalDriver.email ||
        formData['telephone'] != _originalDriver.telephone ||
        _detectedZone != _originalDriver.zone_livraison ||
        _selectedStatus != _originalDriver.statut ||
        (_passwordChanged && formData['password']?.isNotEmpty == true);
  }

  Future<bool> _showDiscardDialog() async {
    if (!_hasChanges()) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text(
          'Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('QUITTER'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<FormFieldValidator<String>>? validators,
    bool enabled = true,
    bool isPassword = false,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Constants.defaultRadius),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
        suffixIcon: isPassword
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
      obscureText: isPassword && !_showPassword,
      enabled: enabled,
      validator: FormBuilderValidators.compose(validators ?? []),
      textInputAction: TextInputAction.next,
      onChanged: isPassword
          ? (value) {
              setState(() {
                _passwordChanged = value?.isNotEmpty == true;
              });
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showDiscardDialog();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier Livreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!mounted) return;
              final shouldPop = await _showDiscardDialog();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
            },
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

                // Informations du livreur
                _buildDriverInfo(),
                const SizedBox(height: 16),

                // Formulaire
                _buildForm(),
                const SizedBox(height: 24),

                // Zone détectée
                if (_detectedZone.isNotEmpty) _buildZoneCard(),
                const SizedBox(height: 24),

                // Boutons d'action
                _buildActionButtons(),
              ],
            ),
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
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.edit,
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
                        'Modifier le livreur',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Modifiez les informations du livreur',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153), // 60% opacity
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
        .slide(
          begin: const Offset(-0.5, 0),
          end: Offset.zero,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildDriverInfo() {
    return Card(
      elevation: 1,
      color: Colors.blue.withAlpha(7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${widget.driver.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153), // 60% opacity
                    ),
                  ),
                  Text(
                    widget.driver.fullName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            StatusIndicator(status: widget.driver.statut, compact: false),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
          children: [
            // Nom complet
            _buildFormField(
              name: 'full_name',
              label: 'Nom complet',
              icon: Icons.person,
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

            // Adresse avec détection de zone
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse complète',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                ZoneDetector(
                  onZoneDetected: _onZoneDetected,
                  hintText: 'Entrez l\'adresse complète',
                  showSuggestions: true,
                  // initialValue a été retiré car non supporté par ZoneDetector
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mot de passe (optionnel)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mot de passe (laisser vide pour ne pas modifier)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                _buildFormField(
                  name: 'password',
                  label: 'Nouveau mot de passe',
                  icon: Icons.lock,
                  isPassword: true,
                  validators: [
                    if (_passwordChanged)
                      FormBuilderValidators.minLength(
                        8,
                        errorText: 'Minimum 8 caractères',
                      ),
                    if (_passwordChanged)
                      FormBuilderValidators.match(
                        RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                        ),
                        errorText: Constants.validationPassword,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut',
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
                          _selectedStatus = selected
                              ? status
                              : widget.driver.statut;
                        });
                      },
                      backgroundColor: isSelected
                          ? _getStatusColor(status)
                          : Colors.grey[200],
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
        .slide(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildZoneCard() {
    return Card(
          color: Colors.green.withAlpha(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zone détectée',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _detectedZone,
                        style: const TextStyle(
                          fontSize: 16,
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
        .fadeIn(duration: 300.ms)
        .scaleY(begin: 0.8, end: 1, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildActionButtons() {
    return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  if (!mounted) return;
                  final shouldPop = await _showDiscardDialog();
                  if (shouldPop && mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.defaultRadius,
                    ),
                  ),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ANNULER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading || !_hasChanges() ? null : _updateDriver,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Constants.defaultRadius,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  disabledBackgroundColor: Colors.grey[300],
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
                          const Icon(Icons.save, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ENREGISTRER',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slide(
          begin: const Offset(0, 1),
          end: Offset.zero,
          duration: 600.ms,
          curve: Curves.easeOut,
        );
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
