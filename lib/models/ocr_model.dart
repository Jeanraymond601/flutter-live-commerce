class OcrModel {
  final String? phone;
  final String? address;
  final String? name;
  final String intent;
  final double confidence;
  final String sourceType;
  final DateTime? timestamp;
  final String? rawText;
  final String? extractedEmail;
  final double? extractedAmount;
  final String? title; // AJOUT: Nouveau champ pour le titre/sujet

  OcrModel({
    this.phone,
    this.address,
    this.name,
    required this.intent,
    required this.confidence,
    required this.sourceType,
    this.timestamp,
    this.rawText,
    this.extractedEmail,
    this.extractedAmount,
    this.title, // AJOUT: Paramètre pour le titre
  });

  factory OcrModel.fromJson(Map<String, dynamic> json) {
    return OcrModel(
      phone: json['phone'],
      address: json['address'],
      name: json['name'],
      intent: json['intent'] ?? 'Non spécifié',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      sourceType: json['sourceType'] ?? 'TEXT',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      rawText: json['rawText'],
      extractedEmail: json['extractedEmail'],
      extractedAmount: json['extractedAmount'] != null
          ? double.tryParse(json['extractedAmount'].toString())
          : null,
      title: json['title'], // AJOUT: Lecture du titre
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'address': address,
      'name': name,
      'intent': intent,
      'confidence': confidence,
      'sourceType': sourceType,
      'timestamp': timestamp?.toIso8601String(),
      'rawText': rawText,
      'extractedEmail': extractedEmail,
      'extractedAmount': extractedAmount,
      'title': title, // AJOUT: Sauvegarde du titre
    };
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasAddress => address != null && address!.isNotEmpty;
  bool get hasEmail => extractedEmail != null && extractedEmail!.isNotEmpty;
  bool get hasAmount => extractedAmount != null;
  bool get hasTitle =>
      title != null && title!.isNotEmpty; // AJOUT: Getter pour le titre
  bool get hasName =>
      name != null && name!.isNotEmpty; // AJOUT: Getter pour le nom

  // AJOUT: Méthode pour compter tous les champs extraits
  int get extractedFieldsCount {
    int count = 0;
    if (hasPhone) count++;
    if (hasAddress) count++;
    if (hasName) count++;
    if (hasEmail) count++;
    if (hasAmount) count++;
    if (hasTitle) count++;
    return count;
  }

  // AJOUT: Méthode pour obtenir la liste des champs manquants
  List<String> get missingFields {
    List<String> missing = [];
    if (!hasPhone) missing.add('Téléphone');
    if (!hasAddress) missing.add('Adresse');
    if (!hasName) missing.add('Nom');
    if (!hasEmail) missing.add('Email');
    if (!hasAmount) missing.add('Montant');
    if (!hasTitle) missing.add('Titre');
    return missing;
  }

  @override
  String toString() {
    return 'OCRResult{phone: $phone, address: $address, name: $name, title: $title, email: $extractedEmail, intent: $intent, confidence: ${(confidence * 100).toStringAsFixed(1)}%}';
  }
}
