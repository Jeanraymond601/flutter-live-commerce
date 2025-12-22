// lib/models/driver.dart
// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'driver.g.dart'; // Pour Hive code generation

@HiveType(typeId: 1)
class Driver {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String user_id;

  @HiveField(2)
  final String seller_id;

  @HiveField(3)
  final String zone_livraison;

  @HiveField(4)
  final bool disponibilite;

  @HiveField(5)
  final DateTime created_at;

  @HiveField(6)
  final DateTime updated_at;

  @HiveField(7)
  final User user;

  @HiveField(8)
  final DateTime? deleted_at;

  @HiveField(9)
  final bool is_deleted;

  Driver({
    required this.id,
    required this.user_id,
    required this.seller_id,
    required this.zone_livraison,
    required this.disponibilite,
    required this.created_at,
    required this.updated_at,
    required this.user,
    this.deleted_at,
    this.is_deleted = false,
  });

  // Copy with method pour les mises à jour
  Driver copyWith({
    String? id,
    String? user_id,
    String? seller_id,
    String? zone_livraison,
    bool? disponibilite,
    DateTime? created_at,
    DateTime? updated_at,
    User? user,
    DateTime? deleted_at,
    bool? is_deleted,
  }) {
    return Driver(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      seller_id: seller_id ?? this.seller_id,
      zone_livraison: zone_livraison ?? this.zone_livraison,
      disponibilite: disponibilite ?? this.disponibilite,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      user: user ?? this.user,
      deleted_at: deleted_at ?? this.deleted_at,
      is_deleted: is_deleted ?? this.is_deleted,
    );
  }

  // Factory constructor pour créer depuis JSON
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['driver_id'] ?? json['id'] ?? '',
      user_id: json['user_id'] ?? '',
      seller_id: json['seller_id'] ?? '',
      zone_livraison: json['zone_livraison'] ?? 'Zone non spécifiée',
      disponibilite: json['disponibilite'] ?? true,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: User.fromJson(json),
      deleted_at: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      is_deleted: json['is_deleted'] ?? false,
    );
  }

  // Convertir en JSON pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      'driver_id': id,
      'user_id': user_id,
      'seller_id': seller_id,
      'zone_livraison': zone_livraison,
      'disponibilite': disponibilite,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      if (deleted_at != null) 'deleted_at': deleted_at!.toIso8601String(),
      'is_deleted': is_deleted,
      ...user.toJson(),
    };
  }

  // Convertir en Map pour la création
  Map<String, dynamic> toCreateJson() {
    return {
      'full_name': user.full_name,
      'email': user.email,
      'telephone': user.telephone,
      'adresse': user.adresse,
      'password': user.password,
      'statut': user.statut,
    };
  }

  // Convertir en Map pour la mise à jour
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': user.full_name,
      'telephone': user.telephone,
      'adresse': user.adresse,
      'statut': user.statut,
      'is_active': user.is_active,
      'disponibilite': disponibilite,
      'zone_livraison': zone_livraison,
    };
  }

  // Getters utiles
  String get fullName => user.full_name;
  String get email => user.email;
  String get telephone => user.telephone;
  String get adresse => user.adresse;
  String get statut => user.statut;
  bool get is_active => user.is_active;

  // Getter pour vérifier si supprimé
  bool get isDeleted => is_deleted || deleted_at != null;

  // Getters formatés pour l'UI
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(created_at);
  }

  String get formattedUpdatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(updated_at);
  }

  String? get formattedDeletedAt {
    if (deleted_at == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(deleted_at!);
  }

  String get statusDisplay {
    switch (user.statut.toLowerCase()) {
      case 'actif':
        return 'Actif';
      case 'en_attente':
        return 'En attente';
      case 'suspendu':
        return 'Suspendu';
      case 'rejeté':
        return 'Rejeté';
      default:
        return user.statut;
    }
  }

  String get availabilityDisplay {
    return disponibilite ? 'Disponible' : 'Indisponible';
  }

  // Méthodes de vérification
  bool get isActive => user.statut.toLowerCase() == 'actif' && user.is_active;
  bool get isSuspended => user.statut.toLowerCase() == 'suspendu';
  bool get isPending => user.statut.toLowerCase() == 'en_attente';
  bool get isRejected => user.statut.toLowerCase() == 'rejeté';

  // Méthode pour obtenir la couleur du statut
  int get statusColor {
    switch (user.statut.toLowerCase()) {
      case 'actif':
        return 0xFF4CAF50; // Vert
      case 'en_attente':
        return 0xFFFF9800; // Orange
      case 'suspendu':
        return 0xFFF44336; // Rouge
      case 'rejeté':
        return 0xFF9E9E9E; // Gris
      default:
        return 0xFF2196F3; // Bleu par défaut
    }
  }

  // Méthode pour obtenir l'icône du statut
  String get statusIcon {
    switch (user.statut.toLowerCase()) {
      case 'actif':
        return 'check_circle';
      case 'en_attente':
        return 'pending';
      case 'suspendu':
        return 'pause_circle';
      case 'rejeté':
        return 'cancel';
      default:
        return 'person';
    }
  }

  // Méthode pour obtenir l'icône de disponibilité
  String get availabilityIcon {
    return disponibilite ? 'check' : 'close';
  }

  // Méthode pour obtenir la couleur de disponibilité
  int get availabilityColor {
    return disponibilite ? 0xFF4CAF50 : 0xFFF44336;
  }

  @override
  String toString() {
    return 'Driver(id: $id, name: ${user.full_name}, zone: $zone_livraison, status: ${user.statut}, deleted: $is_deleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Driver && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String full_name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String telephone;

  @HiveField(4)
  final String adresse;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final String statut;

  @HiveField(7)
  final bool is_active;

  @HiveField(8)
  final String? password;

  @HiveField(9)
  final DateTime? created_at;

  @HiveField(10)
  final DateTime? updated_at;

  User({
    required this.id,
    required this.full_name,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.role,
    required this.statut,
    required this.is_active,
    this.password,
    this.created_at,
    this.updated_at,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? json['id'] ?? '',
      full_name: json['full_name'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      role: json['role'] ?? 'LIVREUR',
      statut: json['statut'] ?? 'en_attente',
      is_active: json['is_active'] ?? false,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': full_name,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'role': role,
      'statut': statut,
      'is_active': is_active,
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
      if (updated_at != null) 'updated_at': updated_at!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? full_name,
    String? email,
    String? telephone,
    String? adresse,
    String? role,
    String? statut,
    bool? is_active,
    String? password,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return User(
      id: id ?? this.id,
      full_name: full_name ?? this.full_name,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      is_active: is_active ?? this.is_active,
      password: password ?? this.password,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $full_name, email: $email, status: $statut)';
  }
}

// Classe pour la réponse paginée des drivers
class DriversResponse {
  final int count;
  final int total;
  final int active;
  final int available;
  final Map<String, dynamic> seller;
  final List<Driver> drivers;

  DriversResponse({
    required this.count,
    required this.total,
    required this.active,
    required this.available,
    required this.seller,
    required this.drivers,
  });

  factory DriversResponse.fromJson(Map<String, dynamic> json) {
    return DriversResponse(
      count: json['count'] ?? 0,
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      available: json['available'] ?? 0,
      seller: json['seller'] ?? {},
      drivers:
          (json['drivers'] as List<dynamic>?)
              ?.map((driverJson) => Driver.fromJson(driverJson))
              .toList() ??
          [],
    );
  }
}

// Classe pour les statistiques des drivers
class DriversStats {
  final int total;
  final int active;
  final int available;
  final Map<String, int> byStatut;
  final Map<String, int> byDisponibilite;

  DriversStats({
    required this.total,
    required this.active,
    required this.available,
    required this.byStatut,
    required this.byDisponibilite,
  });

  factory DriversStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return DriversStats(
      total: stats['total'] ?? 0,
      active: stats['active'] ?? 0,
      available: stats['available'] ?? 0,
      byStatut: Map<String, int>.from(stats['by_statut'] ?? {}),
      byDisponibilite: Map<String, int>.from(stats['by_disponibilite'] ?? {}),
    );
  }
}

// Classe pour la réponse des zones disponibles
class ZonesResponse {
  final String seller_id;
  final int total_zones;
  final List<String> zones;
  final List<ZoneWithStats> zones_with_stats;

  ZonesResponse({
    required this.seller_id,
    required this.total_zones,
    required this.zones,
    required this.zones_with_stats,
  });

  factory ZonesResponse.fromJson(Map<String, dynamic> json) {
    return ZonesResponse(
      seller_id: json['seller_id'] ?? '',
      total_zones: json['total_zones'] ?? 0,
      zones:
          (json['zones'] as List<dynamic>?)
              ?.map((zone) => zone.toString())
              .toList() ??
          [],
      zones_with_stats:
          (json['zones_with_stats'] as List<dynamic>?)
              ?.map((zoneJson) => ZoneWithStats.fromJson(zoneJson))
              .toList() ??
          [],
    );
  }
}

// Classe pour une zone avec statistiques
class ZoneWithStats {
  final String zone;
  final int total;
  final int available;
  final int indisponible;

  ZoneWithStats({
    required this.zone,
    required this.total,
    required this.available,
    required this.indisponible,
  });

  factory ZoneWithStats.fromJson(Map<String, dynamic> json) {
    return ZoneWithStats(
      zone: json['zone'] ?? '',
      total: json['total'] ?? 0,
      available: json['available'] ?? 0,
      indisponible: json['indisponible'] ?? 0,
    );
  }
}
