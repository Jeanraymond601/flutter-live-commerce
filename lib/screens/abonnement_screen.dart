// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/abonnement.dart';
import '../widgets/abonnement_card.dart';
import '../services/abonnement_service.dart';

class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  State<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  final AbonnementService _abonnementService = AbonnementService();
  final AbonnementFormData _formData = AbonnementFormData();

  // Pas de plan sélectionné par défaut
  String? _selectedPlanId;

  // Pour le dropdown/filtre (sans "Tous les plans")
  String? _filterPlanId;
  final List<String> _filterOptions = ['BASIC', 'COMFORT', 'PREMIUM'];

  // Pour gérer l'affichage de la modal
  bool _showModal = false;

  // Unique GlobalKey for form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _moisController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _moisController.addListener(_updateMontant);
    _filterPlanId = _filterOptions[0]; // Par défaut: BASIC
  }

  @override
  void dispose() {
    _nomController.dispose();
    _companyController.dispose();
    _adresseController.dispose();
    _moisController.dispose();
    super.dispose();
  }

  void _updateMontant() {
    if (_selectedPlanId != null) {
      try {
        final plan = AbonnementPlan.plans.firstWhere(
          (p) => p.id == _selectedPlanId,
        );
        final mois = int.tryParse(_moisController.text) ?? 1;
        setState(() {
          _formData.montant = plan.price * mois;
        });
      } catch (e) {
        print('Erreur dans _updateMontant: $e');
      }
    }
  }

  void _handlePlanSelection(String planId) {
    setState(() {
      _selectedPlanId = planId;
      _formData.selectedPlanId = planId;
      _updateMontant();
    });
  }

  void _handleBuyNow(String planId) {
    setState(() {
      _selectedPlanId = planId;
      _formData.selectedPlanId = planId;
      _updateMontant();
      _showModal = true; // Afficher la modal
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _formData.imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print('Erreur dans _pickImage: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData.isValid) {
        try {
          final success = await _abonnementService.submitAbonnement(_formData);

          if (mounted) {
            if (success) {
              _showSuccessDialog();
              _resetForm();
              _closeModal(); // Fermer la modal après succès
            } else {
              _showErrorDialog();
            }
          }
        } catch (e) {
          print('Erreur dans _submitForm: $e');
          _showErrorDialog();
        }
      }
    }
  }

  void _closeModal() {
    setState(() {
      _showModal = false;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedPlanId = null;
      _filterPlanId = _filterOptions[0];
      _formData.reset();
      _nomController.clear();
      _companyController.clear();
      _adresseController.clear();
      _moisController.text = '1';
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abonnement Confirmé'),
        content: const Text('Votre abonnement a été enregistré avec succès!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: const Text('Une erreur est survenue. Veuillez réessayer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm() {
    if (_selectedPlanId == null) return const SizedBox.shrink();

    try {
      final plan = AbonnementPlan.plans.firstWhere(
        (p) => p.id == _selectedPlanId,
      );

      return Container(
        key: ValueKey('form_$_selectedPlanId'),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête de la modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Formulaire - ${plan.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: plan.color,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _closeModal,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                onSaved: (value) => _formData.nom = value,
              ),

              const SizedBox(height: 15),

              // Nom de l'entreprise
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de l\'entreprise';
                  }
                  return null;
                },
                onSaved: (value) => _formData.companyName = value,
              ),

              const SizedBox(height: 15),

              // Adresse
              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
                onSaved: (value) => _formData.adresse = value,
              ),

              const SizedBox(height: 15),

              // Nombre de mois
              TextFormField(
                controller: _moisController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de mois',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de mois';
                  }
                  final mois = int.tryParse(value);
                  if (mois == null || mois < 1) {
                    return 'Nombre de mois invalide';
                  }
                  return null;
                },
                onSaved: (value) {
                  _formData.nombreMois = int.tryParse(value ?? '1') ?? 1;
                },
              ),

              const SizedBox(height: 15),

              // Montant (calculé automatiquement)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: plan.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: plan.color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_formData.montant?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: plan.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Upload d'image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _formData.imagePath != null
                          ? Colors.green
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: _formData.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _formData.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                        Text('Image'),
                                      ],
                                    );
                                  },
                                )
                              : Image.file(
                                  File(_formData.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.cloud_upload,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Capture de preuve de paiement',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '(Obligatoire)',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // Bouton de confirmation
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Confirmer l\'abonnement',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Erreur dans _buildSubscriptionForm: $e');
      return const SizedBox.shrink();
    }
  }

  // Modal pour le formulaire
  Widget _buildModal() {
    if (!_showModal || _selectedPlanId == null) return const SizedBox.shrink();

    return Stack(
      children: [
        // Overlay semi-transparent
        GestureDetector(
          onTap: _closeModal,
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),
        // Modal content
        Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildSubscriptionForm(),
            ),
          ),
        ),
      ],
    );
  }

  // Filtre les plans selon la sélection du dropdown
  List<AbonnementPlan> _getFilteredPlans() {
    if (_filterPlanId == 'BASIC') {
      return AbonnementPlan.plans.where((p) => p.id == 'basic').toList();
    } else if (_filterPlanId == 'COMFORT') {
      return AbonnementPlan.plans.where((p) => p.id == 'comfort').toList();
    } else if (_filterPlanId == 'PREMIUM') {
      return AbonnementPlan.plans.where((p) => p.id == 'premium').toList();
    }
    return List.from(AbonnementPlan.plans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'NOS ABONNEMENTS',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Titre principal
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Choisissez le plan parfait',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Trois options conçues pour s\'adapter à vos besoins',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Dropdown de filtrage
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterPlanId,
                      isExpanded: true,
                      icon: const Icon(Icons.filter_list, color: Colors.blue),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filterPlanId = newValue;
                          });
                        }
                      },
                      items: _filterOptions.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Container parent pour les cartes
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _getFilteredPlans().map((plan) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AbonnementCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          onSelected: _handlePlanSelection,
                          onBuyNow: () => _handleBuyNow(plan.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Indicateur de sélection
                if (_selectedPlanId != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _getPlanColor(_selectedPlanId!),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Plan ${_selectedPlanId!.toUpperCase()} sélectionné',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getPlanColor(_selectedPlanId!),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // Note informative
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Tous les plans incluent notre support client dédié',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Modal overlay
          if (_showModal) _buildModal(),
        ],
      ),
    );
  }

  // Méthode helper pour obtenir la couleur du plan
  Color _getPlanColor(String planId) {
    switch (planId) {
      case 'basic':
        return const Color(0xFFFFB300); // Jaune/or
      case 'comfort':
        return const Color(0xFF2196F3); // Bleu
      case 'premium':
        return const Color(0xFFF44336); // Rouge/orangé
      default:
        return Colors.blue;
    }
  }
}
