import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../utils/constants.dart';

class OrderService extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: Constants.apiBaseUrl));
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> fetchOrders(String vendorId, {String? token}) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: {'vendor_id': vendorId},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _orders = data.map((e) => Order.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? token,
  }) async {
    try {
      final response = await _dio.put(
        '/orders/$orderId/status',
        data: {'status': status.name},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      if (response.statusCode == 200) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order(
            id: _orders[index].id,
            vendorId: _orders[index].vendorId,
            productList: _orders[index].productList,
            totalPrice: _orders[index].totalPrice,
            status: status,
            createdAt: _orders[index].createdAt,
          );
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> subscribeToOrderNotifications() async {
    // This method would be used to initialize Firebase messaging topics or listeners
    // This service is initialized separately in NotificationService
  }
}
