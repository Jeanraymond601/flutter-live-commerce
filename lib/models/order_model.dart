import 'package:flutter/material.dart';

class Order {
  final String id;
  final String customerName;
  final String neighborhood;
  final String city;
  final String phone;
  final String productName;
  final int quantity;
  final double productPrice;
  final double deliveryFee;
  final DateTime orderDate;
  final OrderStatus status;
  final int availableStock;

  Order({
    required this.id,
    required this.customerName,
    required this.neighborhood,
    required this.city,
    required this.phone,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    required this.deliveryFee,
    required this.orderDate,
    required this.status,
    required this.availableStock,
  });

  double get totalPrice => (productPrice * quantity);
  double get finalTotal => totalPrice + deliveryFee;
  bool get canAccept => availableStock >= quantity;

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      customerName: customerName,
      neighborhood: neighborhood,
      city: city,
      phone: phone,
      productName: productName,
      quantity: quantity,
      productPrice: productPrice,
      deliveryFee: deliveryFee,
      orderDate: orderDate,
      status: status ?? this.status,
      availableStock: availableStock,
    );
  }
}

enum OrderStatus { pending, confirmed, rejected }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.rejected:
        return 'Refusée';
    }
  }

  Color getColor(BuildContext context) {
    final _ = Theme.of(context);
    switch (this) {
      case OrderStatus.pending:
        return Colors.amber;
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
    }
  }

  Color getTextColor(BuildContext context) {
    final _ = Theme.of(context);
    switch (this) {
      case OrderStatus.pending:
        return Colors.black87;
      case OrderStatus.confirmed:
      case OrderStatus.rejected:
        return Colors.white;
    }
  }
}
