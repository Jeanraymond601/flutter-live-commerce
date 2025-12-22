import 'dart:math';

import 'package:flutter/material.dart';

class Delivery {
  final String id;
  final String customerName;
  final String city;
  final String neighborhood;
  final String customerPhone;
  final String productName;
  final int quantity;
  final double deliveryFee;
  final double orderTotal;
  final DateTime shippingDate;
  final DateTime estimatedArrival;
  final String deliveryPersonName;
  final String deliveryPersonPhoto;
  final String deliveryPersonPhone;
  final DeliveryStatus status;
  final List<DeliveryStep> timelineSteps;

  Delivery({
    required this.id,
    required this.customerName,
    required this.city,
    required this.neighborhood,
    required this.customerPhone,
    required this.productName,
    required this.quantity,
    required this.deliveryFee,
    required this.orderTotal,
    required this.shippingDate,
    required this.estimatedArrival,
    required this.deliveryPersonName,
    required this.deliveryPersonPhoto,
    required this.deliveryPersonPhone,
    required this.status,
    required this.timelineSteps,
  });

  String get fullAddress => '$neighborhood, $city';
  String get productInfo => '$productName (x$quantity)';
  bool get isLate =>
      DateTime.now().isAfter(estimatedArrival) &&
      status != DeliveryStatus.delivered;
}

enum DeliveryStatus { pending, inProgress, delivered, failed }

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.pending:
        return 'En attente de prise en charge';
      case DeliveryStatus.inProgress:
        return 'En cours de livraison';
      case DeliveryStatus.delivered:
        return 'Livrée';
      case DeliveryStatus.failed:
        return 'Échouée / Retour';
    }
  }

  Color getColor() {
    switch (this) {
      case DeliveryStatus.pending:
        return const Color(0xFFFFC107); // Jaune
      case DeliveryStatus.inProgress:
        return const Color(0xFF2196F3); // Bleu
      case DeliveryStatus.delivered:
        return const Color(0xFF4CAF50); // Vert
      case DeliveryStatus.failed:
        return const Color(0xFFF44336); // Rouge
    }
  }

  IconData getIcon() {
    switch (this) {
      case DeliveryStatus.pending:
        return Icons.hourglass_top;
      case DeliveryStatus.inProgress:
        return Icons.local_shipping;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.failed:
        return Icons.error;
    }
  }
}

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

// Classe utilitaire pour générer des données d'exemple
class DeliveryDataGenerator {
  static final Random _random = Random();
  static final List<String> customerNames = [
    'Marie Dubois',
    'Jean Martin',
    'Sophie Bernard',
    'Pierre Thomas',
    'Julie Robert',
    'Nicolas Richard',
    'Isabelle Petit',
    'Michel Durand',
    'Catherine Leroy',
  ];

  static final List<String> cities = [
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice',
    'Nantes',
  ];
  static final List<String> neighborhoods = [
    'Centre-ville',
    'Le Port',
    'Les Hauts',
    'La Plaine',
    'Quartier Sud',
    'Zone Commerciale',
    'Résidence Bellevue',
  ];

  static final List<String> products = [
    'T-shirt Premium',
    'Casque Bluetooth',
    'Montre Connectée',
    'Enceinte Portable',
    'Sac à dos',
    'Chaussures Sport',
    'Lunettes de Soleil',
    'Parfum Signature',
  ];

  static final List<String> deliveryPersons = [
    'Ahmed K.',
    'Fatima M.',
    'Thomas L.',
    'Sarah B.',
    'Mohammed C.',
    'Emma R.',
    'David P.',
    'Sophie G.',
  ];

  static String getRandomPhone() {
    return '06 ${_random.nextInt(90) + 10} ${_random.nextInt(90) + 10} ${_random.nextInt(90) + 10}';
  }

  static List<DeliveryStep> generateTimeline(DeliveryStatus status) {
    final steps = [
      DeliveryStep(
        label: 'Commande confirmée',
        isCompleted: true,
        isCurrent: false,
      ),
      DeliveryStep(
        label: 'Expédiée',
        isCompleted: status.index >= 1,
        isCurrent: status == DeliveryStatus.inProgress && status.index == 1,
      ),
      DeliveryStep(
        label: 'En cours',
        isCompleted: status.index >= 2,
        isCurrent: status == DeliveryStatus.inProgress && status.index == 2,
      ),
      DeliveryStep(
        label: 'Livrée',
        isCompleted: status == DeliveryStatus.delivered,
        isCurrent: status == DeliveryStatus.delivered,
      ),
    ];

    return steps;
  }

  static List<Delivery> generateSampleDeliveries(int count) {
    final deliveries = <Delivery>[];

    for (int i = 0; i < count; i++) {
      final statusIndex = _random.nextInt(4);
      final status = DeliveryStatus.values[statusIndex];

      final shippingDate = DateTime.now().subtract(
        Duration(days: _random.nextInt(5)),
      );
      final estimatedArrival = shippingDate.add(
        Duration(days: 2 + _random.nextInt(4)),
      );

      deliveries.add(
        Delivery(
          id: 'DLV${1000 + i}',
          customerName: customerNames[_random.nextInt(customerNames.length)],
          city: cities[_random.nextInt(cities.length)],
          neighborhood: neighborhoods[_random.nextInt(neighborhoods.length)],
          customerPhone: getRandomPhone(),
          productName: products[_random.nextInt(products.length)],
          quantity: 1 + _random.nextInt(4),
          deliveryFee: 4.99 + _random.nextDouble() * 5,
          orderTotal: 49.99 + _random.nextDouble() * 150,
          shippingDate: shippingDate,
          estimatedArrival: estimatedArrival,
          deliveryPersonName:
              deliveryPersons[_random.nextInt(deliveryPersons.length)],
          deliveryPersonPhoto:
              'https://i.pravatar.cc/150?img=${_random.nextInt(70)}',
          deliveryPersonPhone: getRandomPhone(),
          status: status,
          timelineSteps: generateTimeline(status),
        ),
      );
    }

    return deliveries;
  }
}
