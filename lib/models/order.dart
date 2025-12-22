import 'dart:convert';

enum OrderStatus { pending, shipped, delivered }

class ProductOrderItem {
  final String productId;
  final int quantity;

  ProductOrderItem({
    required this.productId,
    required this.quantity,
  });

  factory ProductOrderItem.fromJson(Map<String, dynamic> json) {
    return ProductOrderItem(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String vendorId;
  final List<ProductOrderItem> productList;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.vendorId,
    required this.productList,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var productListJson = json['productList'] as List<dynamic>? ?? [];
    List<ProductOrderItem> productList = productListJson
        .map((e) => ProductOrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return Order(
      id: json['id'] as String,
      vendorId: json['vendorId'] as String,
      productList: productList,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'productList': productList.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  String toString() => jsonEncode(toJson());
}
