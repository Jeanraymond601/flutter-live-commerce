import 'dart:async';
import '../models/ocr_model.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  // Historique des extractions
  final List<OcrModel> _extractionHistory = [];

  // Dictionnaires d'extraction améliorés
  final Map<String, String> intentKeywords = {
    'commande': 'Prise de commande',
    'commander': 'Prise de commande',
    'achat': 'Demande d\'achat',
    'acheter': 'Demande d\'achat',
    'livraison': 'Demande de livraison',
    'livrer': 'Demande de livraison',
    'livreur': 'Suivi livraison',
    'prix': 'Demande de prix',
    'tarif': 'Demande de prix',
    'coute': 'Demande de prix',
    'cout': 'Demande de prix',
    'disponible': 'Vérification disponibilité',
    'stock': 'Vérification stock',
    'contact': 'Demande de contact',
    'appeler': 'Demande de contact',
    'appel': 'Demande de contact',
    'urgence': 'Demande urgente',
    'urgent': 'Demande urgente',
    'facture': 'Demande facture',
    'devis': 'Demande devis',
    'proforma': 'Demande proforma',
    'reservation': 'Réservation',
    'reserver': 'Réservation',
    'annuler': 'Annulation',
    'annulation': 'Annulation',
    'retour': 'Retour produit',
    'remboursement': 'Demande remboursement',
    'sav': 'Service après-vente',
    'garantie': 'Demande garantie',
    'reclamation': 'Réclamation',
    'information': 'Demande d\'information',
    'info': 'Demande d\'information',
    'renseignement': 'Demande d\'information',
    'besoin': 'Demande d\'information',
    'je veux': 'Demande d\'information',
    'je souhaite': 'Expression d\'intérêt',
    'j\'ai besoin': 'Demande d\'assistance',
  };

  final List<String> addressIndicators = [
    'rue',
    'avenue',
    'boulevard',
    'lotissement',
    'lot',
    'quartier',
    'tanjombato',
    'analakely',
    'andoharanofotsy',
    'ambohijatovo',
    'tsaralalana',
    'anakely',
    '67 ha',
    '67ha',
    'ivandry',
    'ambohidratrimo',
    'ampasampito',
    'antanimena',
    'ampandrana',
    'anjanahary',
    'mahamasina',
    'antananarivo',
    'tana',
    'madagascar',
  ];

  final List<String> nameTitles = [
    'monsieur',
    'madame',
    'mademoiselle',
    'mme',
    'm.',
    'mr',
    'mrs',
    'dr',
    'docteur',
    'prof',
    'professeur',
  ];

  // Simulation d'analyse IA avec extraction avancée
  Future<OcrModel> analyzeText(String text, String sourceType) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Extraction de TOUS les champs
    final phone = _extractPhoneNumber(text);
    final address = _extractAddress(text);
    final name = _extractName(text);
    final email = _extractEmail(text);
    final amount = _extractAmount(text);
    final title = _extractTitle(text);
    final intent = _detectIntent(text);
    final confidence = _calculateConfidence(
      text,
      phone,
      address,
      name,
      email,
      amount,
      title,
    );
    final timestamp = DateTime.now();

    // Création du modèle avec toutes les informations
    final result = OcrModel(
      phone: phone,
      address: address,
      name: name,
      intent: intent,
      confidence: confidence,
      sourceType: sourceType,
      timestamp: timestamp,
      rawText: text,
      extractedEmail: email,
      extractedAmount: amount,
      title: title,
    );

    // Ajouter à l'historique
    _addToHistory(result);

    return result;
  }

  // Simulation d'OCR sur image avec améliorations
  Future<String> extractTextFromImage() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Exemple qui contient tous les champs recherchés
    return """
OBJET: Demande de renseignements
DATE: 18/01/2024

Cher Monsieur Rakoto,

Je vous contacte pour avoir plus d'informations sur vos produits.
Voici mes coordonnées :

Nom: Jean Rakoto
Téléphone: 034 56 78 902
Adresse: 67 Ha, Antananarivo 101
Email: jean.rakoto@gmail.com

Je suis intéressé par votre catalogue et souhaiterais connaître les prix.

Cordialement,
Jean
    """;
  }

  // Méthodes d'extraction avancées

  String? _extractPhoneNumber(String text) {
    // Formats de numéros malgaches améliorés
    final patterns = [
      RegExp(r'0(3[2348])\s*(\d{2})\s*(\d{2})\s*(\d{2})'), // 034 56 78 902
      RegExp(r'0(3[2348])\d{7}'), // 0345678902
      RegExp(
        r'\+261\s*(3[2348])\s*(\d{2})\s*(\d{2})\s*(\d{2})',
      ), // +261 34 56 78 902
      RegExp(
        r'\(0(3[2348])\)\s*(\d{2})\s*(\d{2})\s*(\d{2})',
      ), // (034) 56 78 902
      RegExp(r'téléphone\s*[:=]\s*([0-9\s\.\-\(\)]+)', caseSensitive: false),
      RegExp(r'tel\s*[:=]\s*([0-9\s\.\-\(\)]+)', caseSensitive: false),
      RegExp(r'phone\s*[:=]\s*([0-9\s\.\-\(\)]+)', caseSensitive: false),
      RegExp(r'contact\s*[:=]\s*([0-9\s\.\-\(\)]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String phone = match.group(0) ?? '';

        // Nettoyer le numéro
        phone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

        // S'assurer qu'il commence par 0
        if (phone.startsWith('261')) {
          phone = '0${phone.substring(3)}';
        }

        // Vérifier la longueur
        if (phone.length >= 10 && phone.startsWith('0')) {
          return phone;
        }
      }
    }

    return null;
  }

  String? _extractAddress(String text) {
    // Chercher d'abord les patterns spécifiques
    final patterns = [
      RegExp(r'adresse\s*[:=]\s*(.+?)(?:\n|\.|$)', caseSensitive: false),
      RegExp(r'addr\s*[:=]\s*(.+?)(?:\n|\.|$)', caseSensitive: false),
      RegExp(r'location\s*[:=]\s*(.+?)(?:\n|\.|$)', caseSensitive: false),
      RegExp(r'lieu\s*[:=]\s*(.+?)(?:\n|\.|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        String address = match.group(1)?.trim() ?? '';
        if (address.isNotEmpty && address.length > 5) {
          return _cleanAddress(address);
        }
      }
    }

    // Chercher les indicateurs d'adresse dans le texte
    String lowerText = text.toLowerCase();

    for (var indicator in addressIndicators) {
      if (lowerText.contains(indicator)) {
        int startIndex = lowerText.indexOf(indicator);

        // Extraire le contexte autour de l'indicateur
        int extractStart = startIndex;
        while (extractStart > 0) {
          String precedingText = lowerText.substring(0, extractStart);
          if (precedingText.endsWith('\n') ||
              precedingText.endsWith(':') ||
              precedingText.endsWith(',') ||
              precedingText.endsWith(';')) {
            break;
          }
          extractStart--;
        }

        int extractEnd = startIndex + indicator.length;
        while (extractEnd < text.length) {
          if (extractEnd < text.length &&
              ['\n', '.', ',', ';', ' ', '-'].contains(text[extractEnd])) {
            break;
          }
          extractEnd++;
        }

        String address = text.substring(extractStart, extractEnd).trim();
        address = _cleanAddress(address);

        if (address.length > 5) {
          return address;
        }
      }
    }

    return null;
  }

  String _cleanAddress(String address) {
    // Nettoyer les préfixes inutiles
    List<String> prefixes = [
      'adresse',
      'addr',
      'location',
      'lieu',
      'à',
      'd\'',
      'de',
      ':',
      '=',
      ',',
    ];

    for (var prefix in prefixes) {
      if (address.toLowerCase().startsWith(prefix)) {
        address = address.substring(prefix.length).trim();
      }
    }

    // Capitaliser proprement
    address = address
        .split(' ')
        .map((word) {
          if (word.isNotEmpty) {
            // Garder les chiffres comme "67"
            if (RegExp(r'^\d+').hasMatch(word)) {
              return word;
            }
            // Garder "ha" en minuscules
            if (word.toLowerCase() == 'ha') {
              return word.toLowerCase();
            }
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }
          return word;
        })
        .join(' ');

    return address;
  }

  String? _extractName(String text) {
    // Chercher les titres + noms
    for (var title in nameTitles) {
      final pattern = RegExp(
        // ignore: prefer_interpolation_to_compose_strings
        r'(?:^|\s|\.|,)'
                r'(?:' +
            title +
            r')'
                r'[\s\.]+'
                r'([A-ZÀ-ÿ][a-zà-ÿ]+(?:\s+[A-ZÀ-ÿ][a-zà-ÿ]+)*)',
        caseSensitive: false,
      );

      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }

    // Chercher "Nom:"
    final namePatterns = [
      RegExp(
        r'nom\s*[:=]\s*([A-ZÀ-ÿ][a-zà-ÿ]+(?:\s+[A-ZÀ-ÿ][a-zà-ÿ]+)*)',
        caseSensitive: false,
      ),
      RegExp(
        r'name\s*[:=]\s*([A-ZÀ-ÿ][a-zà-ÿ]+(?:\s+[A-ZÀ-ÿ][a-zà-ÿ]+)*)',
        caseSensitive: false,
      ),
      RegExp(
        r'prénom\s*[:=]\s*([A-ZÀ-ÿ][a-zà-ÿ]+(?:\s+[A-ZÀ-ÿ][a-zà-ÿ]+)*)',
        caseSensitive: false,
      ),
      RegExp(
        r'client\s*[:=]\s*([A-ZÀ-ÿ][a-zà-ÿ]+(?:\s+[A-ZÀ-ÿ][a-zà-ÿ]+)*)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in namePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }

    // Chercher des noms communs malgaches en début de phrase
    final commonNames = [
      'rakoto',
      'rasoa',
      'rabe',
      'randria',
      'rajaona',
      'jean',
      'marie',
      'joseph',
      'pierre',
      'paul',
    ];

    String lowerText = text.toLowerCase();
    for (var name in commonNames) {
      if (lowerText.contains(name)) {
        // Vérifier si c'est un nom propre (après un titre ou en début)
        int index = lowerText.indexOf(name);
        if (index > 0) {
          String before = lowerText.substring(0, index).trim();
          if (before.endsWith('monsieur') ||
              before.endsWith('madame') ||
              before.endsWith('m.') ||
              before.endsWith('mme') ||
              before.isEmpty) {
            return name[0].toUpperCase() + name.substring(1);
          }
        }
      }
    }

    return null;
  }

  String? _extractEmail(String text) {
    final emailPattern = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
      caseSensitive: false,
    );

    // Chercher d'abord après "email"
    final emailKeywordPattern = RegExp(
      r'email\s*[:=]\s*([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
      caseSensitive: false,
    );

    final match1 = emailKeywordPattern.firstMatch(text);
    if (match1 != null && match1.groupCount >= 1) {
      return match1.group(1);
    }

    // Chercher n'importe quel email
    final match2 = emailPattern.firstMatch(text);
    return match2?.group(0);
  }

  double? _extractAmount(String text) {
    // Patterns pour les montants
    final amountPatterns = [
      RegExp(r'(\d[\d\s.,]*\d)\s*[Aa]r'), // 1.250.000 Ar
      RegExp(r'[Mm]ontant\s*[:=]\s*(\d[\d\s.,]*\d)'), // Montant: 450000
      RegExp(r'[Pp]rix\s*[:=]\s*(\d[\d\s.,]*\d)'), // Prix: 3.450.000
      RegExp(r'[Tt]otal\s*[:=]\s*(\d[\d\s.,]*\d)'), // Total: 41.300
      RegExp(r'budget\s*[:=]\s*(\d[\d\s.,]*\d)', caseSensitive: false),
      RegExp(r'cout\s*[:=]\s*(\d[\d\s.,]*\d)', caseSensitive: false),
      RegExp(r'coût\s*[:=]\s*(\d[\d\s.,]*\d)', caseSensitive: false),
      RegExp(r'\$(\d[\d\s.,]*\d)'), // $100
      RegExp(r'(\d[\d\s.,]*\d)\s*€'), // 100 €
    ];

    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final amountStr = match.group(1)?.replaceAll(RegExp(r'[\s.,]'), '');
        if (amountStr != null) {
          return double.tryParse(amountStr);
        }
      }
    }
    return null;
  }

  String? _extractTitle(String text) {
    // Chercher les mots-clés de titre
    final titlePatterns = [
      RegExp(r'objet\s*[:=]\s*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'sujet\s*[:=]\s*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'titre\s*[:=]\s*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'subject\s*[:=]\s*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r're\s*[:=]\s*(.+?)(?:\n|$)', caseSensitive: false),
    ];

    for (final pattern in titlePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        String title = match.group(1)?.trim() ?? '';
        if (title.isNotEmpty && title.length < 100) {
          return title;
        }
      }
    }

    // Si pas de titre explicite, extraire la première phrase significative
    final lines = text.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty &&
          line.length > 10 &&
          line.length < 80 &&
          !line.toLowerCase().contains('http') &&
          !line.contains('@') &&
          !RegExp(r'^\d').hasMatch(line)) {
        return line;
      }
    }

    // Utiliser l'intention comme titre par défaut
    String intent = _detectIntent(text);
    if (intent != 'Non spécifié' && intent != 'Expression d\'intérêt') {
      return intent;
    }

    return null;
  }

  String _detectIntent(String text) {
    String lowerText = text.toLowerCase();

    // Chercher les mots-clés d'intention
    for (final entry in intentKeywords.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    // Détection par contexte
    if (lowerText.contains('question') ||
        lowerText.contains('information') ||
        lowerText.contains('renseignement') ||
        lowerText.contains('je veux') ||
        lowerText.contains('j\'ai besoin')) {
      return 'Demande d\'information';
    } else if (lowerText.contains('merci') || lowerText.contains('remercie')) {
      return 'Remerciement';
    } else if (lowerText.contains('produit') || lowerText.contains('article')) {
      return 'Demande produit';
    } else if (lowerText.contains('commande') ||
        lowerText.contains('acheter')) {
      return 'Prise de commande';
    } else if (lowerText.contains('livraison') ||
        lowerText.contains('livrer')) {
      return 'Demande de livraison';
    }

    return 'Expression d\'intérêt';
  }

  double _calculateConfidence(
    String text,
    String? phone,
    String? address,
    String? name,
    String? email,
    double? amount,
    String? title,
  ) {
    double score = 0.0;
    int extractedCount = 0;

    // Points pour chaque champ extrait
    if (phone != null && phone.length >= 10) {
      score += 0.15;
      extractedCount++;
    }

    if (address != null && address.length > 5) {
      score += 0.15;
      extractedCount++;
    }

    if (name != null && name.isNotEmpty) {
      score += 0.15;
      extractedCount++;
    }

    if (email != null && email.isNotEmpty) {
      score += 0.15;
      extractedCount++;
    }

    if (amount != null) {
      score += 0.15;
      extractedCount++;
    }

    if (title != null && title.isNotEmpty) {
      score += 0.15;
      extractedCount++;
    }

    // Bonus pour la longueur et structure du texte
    if (text.length > 50) score += 0.05;
    if (text.contains('\n')) score += 0.02;
    if (text.contains(':')) score += 0.02;
    if (text.contains(',')) score += 0.01;

    // Score minimum si on a au moins 3 champs
    if (extractedCount >= 3 && score < 0.6) score = 0.6;

    // Score maximum si on a tous les champs
    if (extractedCount == 6) score = 1.0;

    return score.clamp(0.0, 1.0);
  }

  // Gestion de l'historique
  void _addToHistory(OcrModel result) {
    _extractionHistory.insert(0, result);

    // Limiter l'historique à 50 entrées
    if (_extractionHistory.length > 50) {
      _extractionHistory.removeLast();
    }
  }

  List<OcrModel> getHistory() {
    return List.from(_extractionHistory);
  }

  List<OcrModel> getHistoryByType(String type) {
    return _extractionHistory.where((item) => item.sourceType == type).toList();
  }

  List<OcrModel> getRecentHistory(int count) {
    return _extractionHistory.take(count).toList();
  }

  void clearHistory() {
    _extractionHistory.clear();
  }

  // Statistiques
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayExtractions = _extractionHistory
        .where(
          (item) => item.timestamp != null && item.timestamp!.isAfter(today),
        )
        .length;

    final successfulExtractions = _extractionHistory
        .where((item) => item.confidence >= 0.6)
        .length;

    return {
      'total': _extractionHistory.length,
      'today': todayExtractions,
      'successRate': _extractionHistory.isEmpty
          ? 0
          : (successfulExtractions / _extractionHistory.length * 100).round(),
      'byType': {
        'TEXT': _extractionHistory
            .where((item) => item.sourceType == 'TEXT')
            .length,
        'IMAGE': _extractionHistory
            .where((item) => item.sourceType == 'IMAGE')
            .length,
        'LIVE': _extractionHistory
            .where((item) => item.sourceType == 'LIVE')
            .length,
      },
    };
  }
}
