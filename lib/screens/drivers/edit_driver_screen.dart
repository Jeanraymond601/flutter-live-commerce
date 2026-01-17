// lib/screens/drivers/edit_driver_screen.dart
// ignore_for_file: use_build_context_synchronously, dead_code

import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import '../../models/driver.dart';
import '../../services/driver_service.dart';

class EditDriverScreen extends StatefulWidget {
  final Driver driver;
  const EditDriverScreen({super.key, required this.driver});

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _isMounted = false;
  late Driver _originalDriver;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _originalDriver = widget.driver;

    // Initialiser les valeurs après un petit délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted && _formKey.currentState != null) {
        _formKey.currentState!.patchValue({
          'full_name': widget.driver.fullName,
          'email': widget.driver.email,
          'telephone': widget.driver.telephone,
          'adresse': widget.driver.adresse,
          'statut': widget.driver.statut,
          'disponibilite': widget.driver.disponibilite,
        });
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _updateDriver() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      setState(() {
        _isLoading = true;
      });

      try {
        final driverService = context.read<DriverService>();

        final updateData = <String, dynamic>{
          'full_name': formData['full_name']?.toString().trim(),
          'email': formData['email']?.toString().trim(),
          'telephone': formData['telephone']?.toString().trim(),
          'adresse': formData['adresse']?.toString().trim() ?? '',
          'statut': formData['statut']?.toString().trim(),
          'disponibilite':
              formData['disponibilite'] ?? widget.driver.disponibilite,
        };

        final result = await driverService.updateDriver(
          widget.driver.id,
          updateData,
        );

        if (!_isMounted) return;

        if (result['success'] == true) {
          // Retourner true pour indiquer une mise à jour réussie
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Livreur modifié avec succès !',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _showErrorSnackbar(result['error']?.toString() ?? 'Erreur inconnue');
        }
      } catch (e) {
        if (_isMounted) {
          _showErrorSnackbar('Erreur: ${e.toString().split('\n').first}');
        }
      } finally {
        if (_isMounted) {
          setState(() => _isLoading = false);
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

  bool _hasChanges() {
    if (_formKey.currentState == null) return false;

    final formData = _formKey.currentState!.value;

    return formData['full_name'] != _originalDriver.fullName ||
        formData['email'] != _originalDriver.email ||
        formData['telephone'] != _originalDriver.telephone ||
        (formData['adresse'] ?? '') != (_originalDriver.adresse) ||
        formData['statut'] != _originalDriver.statut ||
        formData['disponibilite'] != _originalDriver.disponibilite;
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
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('QUITTER'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  // Carte en haut du formulaire avec les informations du livreur
  Widget _buildDriverCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driver.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.driver.telephone,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.driver.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (widget.driver.adresse.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.driver.adresse,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.driver.statut == 'actif'
                        ? Colors.green.withOpacity(0.1)
                        : widget.driver.statut == 'en_attente'
                        ? Colors.orange.withOpacity(0.1)
                        : widget.driver.statut == 'suspendu'
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.driver.statut.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.driver.statut == 'actif'
                          ? Colors.green
                          : widget.driver.statut == 'en_attente'
                          ? Colors.orange
                          : widget.driver.statut == 'suspendu'
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.driver.disponibilite
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.driver.disponibilite ? 'Disponible' : 'Indisponible',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.driver.disponibilite
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<FormFieldValidator<String>>? validators,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: FormBuilderTextField(
          name: name,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blueGrey),
            border: InputBorder.none,
          ),
          keyboardType: keyboardType,
          validator: FormBuilderValidators.compose(validators ?? []),
          maxLines: maxLines,
          textInputAction: TextInputAction.next,
        ),
      ),
    );
  }

  // Widget pour le champ de statut
  Widget _buildStatusField() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: FormBuilderDropdown<String>(
          name: 'statut',
          decoration: InputDecoration(
            labelText: 'Statut',
            prefixIcon: Icon(Icons.work, color: Colors.blueGrey),
            border: InputBorder.none,
          ),
          items: const [
            DropdownMenuItem(
              value: 'actif',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Actif'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'en_attente',
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text('En attente'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'suspendu',
              child: Row(
                children: [
                  Icon(Icons.pause_circle, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Suspendu'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'rejeté',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text('Rejeté'),
                ],
              ),
            ),
          ],
          validator: FormBuilderValidators.required(
            errorText: 'Le statut est requis',
          ),
        ),
      ),
    );
  }

  // Widget pour le champ de disponibilité
  Widget _buildDisponibiliteField() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: FormBuilderSwitch(
          name: 'disponibilite',
          decoration: InputDecoration(
            labelText: 'Disponibilité',
            prefixIcon: Icon(Icons.directions_car, color: Colors.blueGrey),
            border: InputBorder.none,
          ),
          title: const Text('Disponible pour les livraisons'),
          initialValue: widget.driver.disponibilite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showDiscardDialog,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Modifier Livreur'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _showDiscardDialog();
              if (shouldPop && _isMounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte du livreur en haut
              _buildDriverCard(),

              const SizedBox(height: 8),
              const Text(
                'Modifier les informations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 16),

              // Formulaire
              FormBuilder(
                key: _formKey,
                initialValue: {
                  'full_name': widget.driver.fullName,
                  'email': widget.driver.email,
                  'telephone': widget.driver.telephone,
                  'adresse': widget.driver.adresse,
                  'statut': widget.driver.statut,
                  'disponibilite': widget.driver.disponibilite,
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildFormField(
                      name: 'adresse',
                      label: 'Adresse',
                      icon: Icons.location_on,
                      maxLines: 2,
                      validators: [
                        FormBuilderValidators.required(
                          errorText: Constants.validationRequired,
                        ),
                        FormBuilderValidators.minLength(
                          5,
                          errorText: 'Adresse trop courte',
                        ),
                      ],
                    ),

                    // Champ pour le statut
                    _buildStatusField(),

                    // Champ pour la disponibilité
                    _buildDisponibiliteField(),

                    const SizedBox(height: 32),

                    // Boutons Enregistrer/Annuler
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateDriver,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'ENREGISTRER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final shouldPop = await _showDiscardDialog();
                              if (shouldPop && _isMounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text(
                              'ANNULER',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
