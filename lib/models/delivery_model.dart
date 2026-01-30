// models/sql_delivery_model.dart
import 'package:flutter/material.dart';

class SqlDelivery {
  // Champs EXACTS de ta table deliveries
  final String id;
  final String orderId;
  final String? driverId;
  final String recipientName;
  final String? recipientPhone;
  final String deliveryAddress;
  final String
  status; // pending, assigned, picked_up, in_progress, delivered, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deliveryCode;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final DateTime? scheduledAt;
  final int? estimatedDuration; // en minutes
  final int? actualDuration; // en minutes

  // Champs additionnels pour OCR Messenger (à ajouter à ta table si nécessaire)
  final String? deliveryZone; // Zone extraite par service Madagascar
  final double? ocrConfidence; // 0.0 à 1.0
  final String? source; // messenger_text, messenger_image, manual, whatsapp
  final String? imageUrl; // URL de l'image Messenger

  SqlDelivery({
    required this.id,
    required this.orderId,
    this.driverId,
    required this.recipientName,
    this.recipientPhone,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryCode,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.scheduledAt,
    this.estimatedDuration,
    this.actualDuration,
    this.deliveryZone,
    this.ocrConfidence,
    this.source,
    this.imageUrl,
  });

  factory SqlDelivery.fromJson(Map<String, dynamic> json) {
    return SqlDelivery(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString(),
      recipientName: json['recipient_name']?.toString() ?? 'Client',
      recipientPhone: json['recipient_phone']?.toString(),
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deliveryCode: json['delivery_code']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      deliveryInstructions: json['delivery_instructions']?.toString(),
      scheduledAt: _parseOptionalDateTime(json['scheduled_at']),
      estimatedDuration: _parseInt(json['estimated_duration']),
      actualDuration: _parseInt(json['actual_duration']),
      deliveryZone: json['delivery_zone']?.toString(),
      ocrConfidence: _parseDouble(json['ocr_confidence']),
      source: json['source']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Méthodes helper pour l'UI
  SqlDeliveryStatus get deliveryStatus {
    switch (status) {
      case 'pending':
        return SqlDeliveryStatus.pending;
      case 'assigned':
      case 'picked_up':
      case 'in_progress':
        return SqlDeliveryStatus.inProgress;
      case 'delivered':
        return SqlDeliveryStatus.delivered;
      case 'cancelled':
        return SqlDeliveryStatus.failed;
      default:
        return SqlDeliveryStatus.pending;
    }
  }

  // Pour compatibilité avec ton UI existant
  String get customerName => recipientName;
  String get fullAddress => deliveryAddress;
  String get productInfo => "Commande #${orderId.substring(0, 8)}";
  String get productName => "Commande #${orderId.substring(0, 8)}";
  double get orderTotal => 0.0; // À récupérer depuis l'API
  double get deliveryFee => 0.0; // À récupérer depuis l'API

  String get deliveryPersonName {
    if (driverId == null) return "En attente d'assignation";
    return "Livreur #${driverId!.substring(0, 6)}";
  }

  // Méthodes pour extraire ville/quartier depuis l'adresse
  String get extractedCity {
    // Logique d'extraction simple - à améliorer avec regex
    final parts = deliveryAddress.split(',').last.trim();
    return parts.isNotEmpty ? parts : 'Ville inconnue';
  }

  String get extractedNeighborhood {
    // Logique d'extraction simple
    if (deliveryAddress.contains(',')) {
      return deliveryAddress.split(',').first.trim();
    }
    return 'Quartier inconnu';
  }

  // Timeline simulée pour compatibilité
  List<DeliveryStep> get timelineSteps {
    // Créer une liste mutable
    final steps = <DeliveryStep>[];

    // Ajouter les étapes de base
    steps.add(
      DeliveryStep(
        label: 'Commande confirmée',
        isCompleted: true,
        isCurrent: false,
      ),
    );

    steps.add(
      DeliveryStep(label: 'Adresse reçue', isCompleted: true, isCurrent: false),
    );

    steps.add(
      DeliveryStep(
        label: 'Assignée au livreur',
        isCompleted: status != 'pending',
        isCurrent: status == 'assigned' || status == 'picked_up',
      ),
    );

    steps.add(
      DeliveryStep(
        label: 'En cours de livraison',
        isCompleted: ['in_progress', 'delivered'].contains(status),
        isCurrent: status == 'in_progress',
      ),
    );

    // Pour l'étape "Livrée", on définit la date si nécessaire
    final isDelivered = status == 'delivered';
    final hasUpdateDate = updatedAt != createdAt;

    steps.add(
      DeliveryStep(
        label: 'Livrée',
        date: (isDelivered && hasUpdateDate) ? updatedAt : null,
        isCompleted: isDelivered,
        isCurrent: isDelivered,
      ),
    );

    return steps;
  }

  bool get isLate {
    if (scheduledAt == null) return false;
    if (status == 'delivered' || status == 'cancelled') return false;
    return DateTime.now().isAfter(scheduledAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'driver_id': driverId,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'delivery_address': deliveryAddress,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_code': deliveryCode,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_instructions': deliveryInstructions,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'actual_duration': actualDuration,
      'delivery_zone': deliveryZone,
      'ocr_confidence': ocrConfidence,
      'source': source,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() {
    return 'SqlDelivery{id: $id, code: $deliveryCode, status: $status, zone: $deliveryZone}';
  }
}

enum SqlDeliveryStatus { pending, inProgress, delivered, failed }

extension SqlDeliveryStatusExtension on SqlDeliveryStatus {
  String get displayName {
    switch (this) {
      case SqlDeliveryStatus.pending:
        return 'En attente';
      case SqlDeliveryStatus.inProgress:
        return 'En cours';
      case SqlDeliveryStatus.delivered:
        return 'Livrée';
      case SqlDeliveryStatus.failed:
        return 'Annulée';
    }
  }

  Color getColor() {
    switch (this) {
      case SqlDeliveryStatus.pending:
        return Colors.orange;
      case SqlDeliveryStatus.inProgress:
        return Colors.blue;
      case SqlDeliveryStatus.delivered:
        return Colors.green;
      case SqlDeliveryStatus.failed:
        return Colors.red;
    }
  }

  IconData getIcon() {
    switch (this) {
      case SqlDeliveryStatus.pending:
        return Icons.access_time;
      case SqlDeliveryStatus.inProgress:
        return Icons.local_shipping;
      case SqlDeliveryStatus.delivered:
        return Icons.check_circle;
      case SqlDeliveryStatus.failed:
        return Icons.error;
    }
  }
}

// Garde ta classe DeliveryStep existante pour la timeline
class DeliveryStep {
  final String label;
  final DateTime? date;
  final bool isCompleted;
  final bool isCurrent;

  const DeliveryStep({
    required this.label,
    this.date,
    required this.isCompleted,
    required this.isCurrent,
  });
}
