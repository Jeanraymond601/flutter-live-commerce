// lib/models/zone.dart
// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'zone.g.dart'; // Pour Hive code generation

@HiveType(typeId: 3)
class Zone {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String? postal_code;

  @HiveField(5)
  final bool is_active;

  @HiveField(6)
  final int? drivers_count;

  @HiveField(7)
  final int? available_drivers;

  @HiveField(8)
  final DateTime created_at;

  @HiveField(9)
  final DateTime updated_at;

  Zone({
    required this.id,
    required this.name,
    this.description,
    required this.city,
    this.postal_code,
    required this.is_active,
    this.drivers_count,
    this.available_drivers,
    required this.created_at,
    required this.updated_at,
  });

  // Factory constructor depuis une string (pour les zones simples)
  factory Zone.fromString(String zoneName) {
    return Zone(
      id: zoneName.hashCode.toString(),
      name: zoneName,
      city: _extractCityFromZone(zoneName),
      is_active: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }

  // Factory constructor depuis JSON API
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? json['zone']?.hashCode.toString() ?? '',
      name: json['name'] ?? json['zone'] ?? '',
      description: json['description'],
      city: json['city'] ?? _extractCityFromZone(json['zone'] ?? ''),
      postal_code: json['postal_code'],
      is_active: json['is_active'] ?? true,
      drivers_count: json['drivers_count'] ?? json['total'],
      available_drivers: json['available_drivers'] ?? json['available'],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Méthode statique pour extraire la ville d'une zone
  static String _extractCityFromZone(String zone) {
    if (zone.contains(' - ')) {
      return zone.split(' - ')[0];
    }

    // Liste des villes principales de Madagascar
    final cities = [
      'Antananarivo',
      'Toamasina',
      'Mahajanga',
      'Toliara',
      'Antsiranana',
      'Fianarantsoa',
      'Antsirabe',
      'Morondava',
      'Ambositra',
      'Moramanga',
      'Manakara',
      'Mananjary',
      'Sainte-Marie',
      'Nosy Be',
      'Taolagnaro',
    ];

    for (final city in cities) {
      if (zone.contains(city)) {
        return city;
      }
    }

    return 'Autre';
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'postal_code': postal_code,
      'is_active': is_active,
      'drivers_count': drivers_count,
      'available_drivers': available_drivers,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  // Copy with method
  Zone copyWith({
    String? id,
    String? name,
    String? description,
    String? city,
    String? postal_code,
    bool? is_active,
    int? drivers_count,
    int? available_drivers,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      postal_code: postal_code ?? this.postal_code,
      is_active: is_active ?? this.is_active,
      drivers_count: drivers_count ?? this.drivers_count,
      available_drivers: available_drivers ?? this.available_drivers,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  // Getters utiles
  String get displayName {
    if (description != null && description!.isNotEmpty) {
      return '$name ($description)';
    }
    return name;
  }

  String get cityAndZone {
    if (city == name) {
      return city;
    }
    return '$city - $name';
  }

  bool get hasDrivers => (drivers_count ?? 0) > 0;
  bool get hasAvailableDrivers => (available_drivers ?? 0) > 0;

  double get availabilityRate {
    if (drivers_count == null || drivers_count == 0) return 0.0;
    return (available_drivers ?? 0) / drivers_count!;
  }

  String get availabilityText {
    if (drivers_count == null || drivers_count == 0) {
      return 'Aucun livreur';
    }
    return '$available_drivers/$drivers_count disponibles';
  }

  // Méthode pour obtenir la couleur basée sur la disponibilité
  int get availabilityColor {
    final rate = availabilityRate;
    if (rate >= 0.7) return 0xFF4CAF50; // Vert
    if (rate >= 0.3) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Rouge
  }

  // Méthode pour obtenir l'icône basée sur la disponibilité
  String get availabilityIcon {
    final rate = availabilityRate;
    if (rate >= 0.7) return 'check_circle';
    if (rate >= 0.3) return 'warning';
    return 'error';
  }

  // Méthode pour vérifier si c'est une zone d'Antananarivo
  bool get isAntananarivoZone {
    return city.toLowerCase().contains('antananarivo') ||
        name.toLowerCase().contains('tana');
  }

  // Méthode pour vérifier si c'est une zone côtière
  bool get isCoastalZone {
    final coastalCities = [
      'toamasina',
      'mahajanga',
      'toliara',
      'antsiranana',
      'morondava',
      'manakara',
      'mananjary',
      'sainte-marie',
      'nosy be',
      'taolagnaro',
    ];

    return coastalCities.any(
      (cityName) => city.toLowerCase().contains(cityName),
    );
  }

  // Méthode pour obtenir le type de zone
  String get zoneType {
    if (isAntananarivoZone) return 'Capitale';
    if (isCoastalZone) return 'Côtière';
    if (city.toLowerCase().contains('antsirabe') ||
        city.toLowerCase().contains('fianarantsoa')) {
      return 'Hauts Plateaux';
    }
    return 'Autre';
  }

  @override
  String toString() {
    return 'Zone(id: $id, name: $name, city: $city, drivers: $drivers_count, available: $available_drivers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Zone && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

// Classe pour la détection de zone
class ZoneDetection {
  final String address;
  final String detectedZone;
  final String? confidence;
  final Map<String, dynamic>? details;
  final DateTime detectedAt;

  ZoneDetection({
    required this.address,
    required this.detectedZone,
    this.confidence,
    this.details,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  // Factory constructor depuis la réponse API
  factory ZoneDetection.fromApiResponse(Map<String, dynamic> json) {
    return ZoneDetection(
      address: json['address'] ?? '',
      detectedZone:
          json['zone'] ?? json['detected_zone'] ?? 'Zone non détectée',
      confidence: json['confidence'],
      details: json['details'],
      detectedAt: json['detected_at'] != null
          ? DateTime.parse(json['detected_at'])
          : null,
    );
  }

  // Factory constructor pour une détection simple
  factory ZoneDetection.simple(String address, String zone) {
    return ZoneDetection(
      address: address,
      detectedZone: zone,
      confidence: 'high',
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'detected_zone': detectedZone,
      'confidence': confidence,
      'details': details,
      'detected_at': detectedAt.toIso8601String(),
    };
  }

  // Getters utiles
  bool get isHighConfidence => confidence == 'high';
  bool get isMediumConfidence => confidence == 'medium';
  bool get isLowConfidence => confidence == 'low';

  String get confidenceDisplay {
    switch (confidence) {
      case 'high':
        return 'Haute confiance';
      case 'medium':
        return 'Confiance moyenne';
      case 'low':
        return 'Faible confiance';
      default:
        return 'Inconnue';
    }
  }

  int get confidenceColor {
    switch (confidence) {
      case 'high':
        return 0xFF4CAF50; // Vert
      case 'medium':
        return 0xFFFF9800; // Orange
      case 'low':
        return 0xFFF44336; // Rouge
      default:
        return 0xFF9E9E9E; // Gris
    }
  }

  @override
  String toString() {
    return 'ZoneDetection(address: $address, zone: $detectedZone, confidence: $confidence)';
  }
}

// Classe pour les suggestions de zones
class ZoneSuggestion {
  final String zone;
  final double score;
  final String? reason;
  final List<String>? similarZones;

  ZoneSuggestion({
    required this.zone,
    required this.score,
    this.reason,
    this.similarZones,
  });

  factory ZoneSuggestion.fromJson(Map<String, dynamic> json) {
    return ZoneSuggestion(
      zone: json['zone'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      reason: json['reason'],
      similarZones: (json['similar_zones'] as List<dynamic>?)
          ?.map((zone) => zone.toString())
          .toList(),
    );
  }

  // Getters utiles
  bool get isHighScore => score >= 0.8;
  bool get isMediumScore => score >= 0.5;
  bool get isLowScore => score < 0.5;

  String get scoreDisplay => '${(score * 100).round()}%';

  @override
  String toString() {
    return 'ZoneSuggestion(zone: $zone, score: $score)';
  }
}

// Classe pour les statistiques de zone
class ZoneStatistics {
  final String zone;
  final int totalDrivers;
  final int activeDrivers;
  final int availableDrivers;
  final int completedDeliveries;
  final double averageRating;
  final DateTime periodStart;
  final DateTime periodEnd;

  ZoneStatistics({
    required this.zone,
    required this.totalDrivers,
    required this.activeDrivers,
    required this.availableDrivers,
    required this.completedDeliveries,
    required this.averageRating,
    required this.periodStart,
    required this.periodEnd,
  });

  factory ZoneStatistics.fromJson(Map<String, dynamic> json) {
    return ZoneStatistics(
      zone: json['zone'] ?? '',
      totalDrivers: json['total_drivers'] ?? 0,
      activeDrivers: json['active_drivers'] ?? 0,
      availableDrivers: json['available_drivers'] ?? 0,
      completedDeliveries: json['completed_deliveries'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'])
          : DateTime.now().subtract(const Duration(days: 30)),
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'])
          : DateTime.now(),
    );
  }

  // Getters utiles
  double get activityRate {
    if (totalDrivers == 0) return 0.0;
    return activeDrivers / totalDrivers;
  }

  double get availabilityRate {
    if (totalDrivers == 0) return 0.0;
    return availableDrivers / totalDrivers;
  }

  String get periodDisplay {
    final format = 'dd/MM/yyyy';
    return '${_formatDate(periodStart, format)} - ${_formatDate(periodEnd, format)}';
  }

  String _formatDate(DateTime date, String format) {
    // Implémentation simplifiée - utiliser intl en production
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  String toString() {
    return 'ZoneStatistics(zone: $zone, drivers: $totalDrivers, available: $availableDrivers, deliveries: $completedDeliveries)';
  }
}
