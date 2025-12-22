// ignore_for_file: avoid_print

import '../models/abonnement.dart';

class AbonnementService {
  // Simulation d'un appel API
  Future<bool> submitAbonnement(AbonnementFormData formData) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // Ici, vous intégrerez l'appel API réel
    // Pour l'instant, simulation de succès
    try {
      if (formData.selectedPlanId == null) {
        throw Exception('Veuillez sélectionner un plan');
      }
      if (formData.imagePath == null || formData.imagePath!.isEmpty) {
        throw Exception('Veuillez télécharger une preuve de paiement');
      }
      // Simulation
      print('Abonnement soumis avec succès:');
      print('- Plan: ${formData.selectedPlanId}');
      print('- Nom: ${formData.nom}');
      print('- Entreprise: ${formData.companyName}');
      print('- Adresse: ${formData.adresse}');
      print('- Montant: ${formData.montant}');
      print('- Mois: ${formData.nombreMois}');

      return true;
    } catch (e) {
      print('Erreur lors de la soumission: $e');
      return false;
    }
  }

  // Méthode pour valider les données localement
  List<String> validateFormData(AbonnementFormData formData) {
    final errors = <String>[];

    if (formData.selectedPlanId == null) {
      errors.add('Veuillez sélectionner un plan');
    }

    if (formData.nom == null || formData.nom!.isEmpty) {
      errors.add('Le nom est requis');
    }

    if (formData.companyName == null || formData.companyName!.isEmpty) {
      errors.add('Le nom de l\'entreprise est requis');
    }

    if (formData.adresse == null || formData.adresse!.isEmpty) {
      errors.add('L\'adresse est requise');
    }

    if (formData.montant == null || formData.montant! <= 0) {
      errors.add('Le montant est invalide');
    }

    if (formData.imagePath == null || formData.imagePath!.isEmpty) {
      errors.add('La preuve de paiement est requise');
    }

    if (formData.nombreMois == null || formData.nombreMois! < 1) {
      errors.add('Le nombre de mois est invalide');
    }

    return errors;
  }

  // Méthode pour calculer le montant total
  double calculateTotal(AbonnementFormData formData) {
    if (formData.selectedPlanId == null) return 0;

    final plan = AbonnementPlan.plans.firstWhere(
      (p) => p.id == formData.selectedPlanId,
    );

    return plan.price * (formData.nombreMois ?? 1);
  }

  // Méthode pour obtenir les détails du plan
  AbonnementPlan? getSelectedPlan(String? planId) {
    if (planId == null) return null;

    try {
      return AbonnementPlan.plans.firstWhere((p) => p.id == planId);
    } catch (e) {
      return null;
    }
  }
}

// Extension pour convertir en JSON (si nécessaire pour l'API)
extension AbonnementFormDataExtensions on AbonnementFormData {
  Map<String, dynamic> toJson() {
    return {
      'plan_id': selectedPlanId,
      'nom': nom,
      'company_name': companyName,
      'adresse': adresse,
      'montant': montant,
      'nombre_mois': nombreMois,
      'image_path': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
