import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final ValueChanged<OrderStatus> onStatusChanged;

  const OrderItem({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
    }
  }

  List<DropdownMenuItem<OrderStatus>> get _statusDropdownItems {
    return OrderStatus.values.map((status) {
      return DropdownMenuItem(value: status, child: Text(_statusLabel(status)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalQuantity = order.productList.fold<int>(
      0,
      (acc, item) => acc + item.quantity,
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text('Commande #${order.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produits: $totalQuantity'),
            Text('Total: ${order.totalPrice.toStringAsFixed(2)} €'),
            Row(
              children: [
                const Text('Statut: '),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  items: _statusDropdownItems,
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != order.status) {
                      onStatusChanged(newStatus);
                    }
                  },
                  underline: Container(),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Optionally navigate to detailed order view
        },
      ),
    );
  }
}
