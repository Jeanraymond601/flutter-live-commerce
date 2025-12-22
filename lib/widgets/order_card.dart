import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom client et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: 12),

            // Adresse complète
            _buildInfoRow(
              context,
              icon: Icons.location_on_outlined,
              title: 'Adresse',
              value: '${order.neighborhood}, ${order.city}',
              subtitle: order.phone,
            ),

            const SizedBox(height: 12),

            // Produit commandé
            _buildInfoRow(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Produit',
              value: order.productName,
              subtitle: 'Quantité: ${order.quantity}',
            ),

            const SizedBox(height: 12),

            // Prix et frais
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    context,
                    label: 'Prix unitaire',
                    value: '${order.productPrice.toStringAsFixed(2)} €',
                  ),
                  _buildPriceRow(
                    context,
                    label: 'Total produit',
                    value: '${order.totalPrice.toStringAsFixed(2)} €',
                  ),
                  _buildPriceRow(
                    context,
                    icon: Icons.local_shipping_outlined,
                    label: 'Frais livraison',
                    value: '${order.deliveryFee.toStringAsFixed(2)} €',
                  ),
                  const Divider(height: 16),
                  _buildPriceRow(
                    context,
                    label: 'Total final',
                    value: '${order.finalTotal.toStringAsFixed(2)} €',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Date de commande
            Text(
              'Commande du ${_formatDate(order.orderDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 16),

            // Boutons d'action
            if (order.status == OrderStatus.pending)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    IconData? icon,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).colorScheme.secondary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!order.canAccept) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onReject,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Refuser la commande'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade400),
              foregroundColor: Colors.red,
            ),
            child: const Text('Refuser'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Accepter'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
