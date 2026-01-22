import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER : CLIENT + STATUT
            // =========================
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Text(
                    _getInitials(order.customerName),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Commande automatique',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 16),

            // =========================
            // ADRESSE
            // =========================
            _infoBlock(
              context,
              icon: Icons.location_on_outlined,
              title: 'Adresse de livraison',
              mainText: '${order.neighborhood}, ${order.city}',
              subText: order.phone,
            ),

            const SizedBox(height: 12),

            // =========================
            // PRODUIT
            // =========================
            _infoBlock(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Produit commandé',
              mainText: order.productName,
              subText: 'Quantité : ${order.quantity}',
            ),

            const SizedBox(height: 16),

            // =========================
            // PRIX
            // =========================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _priceRow(
                    context,
                    label: 'Prix unitaire',
                    value: '${order.productPrice.toStringAsFixed(2)} €',
                  ),
                  _priceRow(
                    context,
                    label: 'Total produit',
                    value: '${order.totalPrice.toStringAsFixed(2)} €',
                  ),
                  _priceRow(
                    context,
                    label: 'Frais de livraison',
                    value: '${order.deliveryFee.toStringAsFixed(2)} €',
                  ),
                  const Divider(height: 18),
                  _priceRow(
                    context,
                    label: 'Total à payer',
                    value: '${order.finalTotal.toStringAsFixed(2)} €',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =========================
            // DATE
            // =========================
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Commandée le ${_formatDate(order.orderDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INFO BLOCK
  // =========================
  Widget _infoBlock(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String mainText,
    String? subText,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                mainText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subText != null)
                Text(
                  subText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================
  // PRICE ROW
  // =========================
  Widget _priceRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? theme.colorScheme.secondary : null,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // UTILITIES
  // =========================
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        'à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
