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

  // =========================
  // STATUS COLOR
  // =========================
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

  // =========================
  // STATUS LABEL
  // =========================
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

  // =========================
  // DROPDOWN ITEMS
  // =========================
  List<DropdownMenuItem<OrderStatus>> get _statusDropdownItems {
    return OrderStatus.values.map((status) {
      return DropdownMenuItem<OrderStatus>(
        value: status,
        child: Text(_statusLabel(status)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalQuantity = order.productList.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigation vers le détail si nécessaire
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // HEADER
              // =========================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Commande #${order.id.substring(0, 8)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // =========================
              // INFOS
              // =========================
              Row(
                children: [
                  _infoChip(
                    context,
                    label: 'Produits',
                    value: totalQuantity.toString(),
                  ),
                  const SizedBox(width: 12),
                  _infoChip(
                    context,
                    label: 'Total',
                    value: '${order.totalPrice.toStringAsFixed(2)} €',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // STATUS SELECT
              // =========================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _statusColor(order.status).withOpacity(0.4),
                  ),
                  color: _statusColor(order.status).withOpacity(0.08),
                ),
                child: Row(
                  children: [
                    Text('Statut', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    DropdownButton<OrderStatus>(
                      value: order.status,
                      items: _statusDropdownItems,
                      onChanged: (newStatus) {
                        if (newStatus != null && newStatus != order.status) {
                          onStatusChanged(newStatus);
                        }
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.expand_more,
                        color: _statusColor(order.status),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INFO CHIP
  // =========================
  Widget _infoChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
