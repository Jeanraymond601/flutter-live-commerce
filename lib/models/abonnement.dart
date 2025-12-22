import 'package:flutter/material.dart';

class AbonnementPlan {
  final String id;
  final String name;
  final Color color;
  final double price;
  final List<String> features;
  final String description;

  AbonnementPlan({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
    required this.features,
    required this.description,
  });

  // Liste des plans disponibles avec les nouvelles couleurs
  static List<AbonnementPlan> get plans => [
    AbonnementPlan(
      id: 'basic',
      name: 'BASIC',
      color: const Color(0xFFFFB300), // Jaune/or
      price: 10.99,
      features: [
        '✅ 1 Live par jour maximum',
        '✅ Support standard par email',
        '✅ Statistiques de base',
        '✅ Jusqu\'à 50 produits en vente',
        '✅ Tableau de bord simplifié',
        '✅ Audience limitée à 100 spectateurs',
      ],
      description: 'Idéal pour débuter en live-commerce',
    ),
    AbonnementPlan(
      id: 'comfort',
      name: 'COMFORT',
      color: const Color(0xFF2196F3), // Bleu
      price: 20.99,
      features: [
        '✅ Lives illimités 24h/24',
        '✅ Support prioritaire par chat',
        '✅ Tableau de bord avancé avec analytics',
        '✅ Jusqu\'à 500 produits en vente',
        '✅ Audience jusqu\'à 1000 spectateurs',
        '✅ Programmation de lives automatique',
        '✅ Notifications push aux followers',
        '✅ Analyse des performances détaillée',
      ],
      description: 'Pour les vendeurs sérieux qui veulent se développer',
    ),
    AbonnementPlan(
      id: 'premium',
      name: 'PREMIUM',
      color: const Color(0xFFF44336), // Rouge/orangé
      price: 30.99,
      features: [
        '✅ Toutes les fonctionnalités Business',
        '✅ Support VIP 24/7 par téléphone',
        '✅ Mise en avant automatique sur la plateforme',
        '✅ Audience illimitée de spectateurs',
        '✅ Nombre de produits illimité',
        '✅ Outils marketing premium inclus',
        '✅ Formation personnalisée gratuite',
        '✅ Accès aux webinaires exclusifs',
        '✅ Badge "Vendeur Premium" sur votre profil',
        '✅ Accès anticipé aux nouvelles fonctionnalités',
      ],
      description:
          'La solution ultime pour les professionnels du live-commerce',
    ),
  ];
}

// Classe pour gérer les données du formulaire
class AbonnementFormData extends ChangeNotifier {
  String? _selectedPlanId;
  String? _nom;
  String? _companyName;
  String? _adresse;
  double? _montant;
  String? _imagePath;
  int? _nombreMois;

  AbonnementFormData({
    String? selectedPlanId,
    String? nom,
    String? companyName,
    String? adresse,
    double? montant,
    String? imagePath,
    int? nombreMois = 1,
  }) : _selectedPlanId = selectedPlanId,
       _nom = nom,
       _companyName = companyName,
       _adresse = adresse,
       _montant = montant,
       _imagePath = imagePath,
       _nombreMois = nombreMois;

  // Getters
  String? get selectedPlanId => _selectedPlanId;
  String? get nom => _nom;
  String? get companyName => _companyName;
  String? get adresse => _adresse;
  double? get montant => _montant;
  String? get imagePath => _imagePath;
  int? get nombreMois => _nombreMois;

  // Setters avec notifyListeners()
  set selectedPlanId(String? value) {
    _selectedPlanId = value;
    notifyListeners();
  }

  set nom(String? value) {
    _nom = value;
    notifyListeners();
  }

  set companyName(String? value) {
    _companyName = value;
    notifyListeners();
  }

  set adresse(String? value) {
    _adresse = value;
    notifyListeners();
  }

  set montant(double? value) {
    _montant = value;
    notifyListeners();
  }

  set imagePath(String? value) {
    _imagePath = value;
    notifyListeners();
  }

  set nombreMois(int? value) {
    _nombreMois = value;
    notifyListeners();
  }

  bool get isValid {
    return _selectedPlanId != null &&
        _nom != null &&
        _nom!.isNotEmpty &&
        _companyName != null &&
        _companyName!.isNotEmpty &&
        _adresse != null &&
        _adresse!.isNotEmpty &&
        _imagePath != null &&
        _imagePath!.isNotEmpty;
  }

  void reset() {
    _selectedPlanId = null;
    _nom = null;
    _companyName = null;
    _adresse = null;
    _montant = null;
    _imagePath = null;
    _nombreMois = 1;
    notifyListeners();
  }

  void updateFromMap(Map<String, dynamic> data) {
    _selectedPlanId = data['selectedPlanId'] as String?;
    _nom = data['nom'] as String?;
    _companyName = data['companyName'] as String?;
    _adresse = data['adresse'] as String?;
    _montant = data['montant'] as double?;
    _imagePath = data['imagePath'] as String?;
    _nombreMois = data['nombreMois'] as int?;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedPlanId': _selectedPlanId,
      'nom': _nom,
      'companyName': _companyName,
      'adresse': _adresse,
      'montant': _montant,
      'imagePath': _imagePath,
      'nombreMois': _nombreMois,
    };
  }
}
