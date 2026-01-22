import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import 'status_badges.dart';
import 'progress_timeline.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onViewDetails;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Client name + Delivery ID + Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Livraison #${delivery.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: delivery.status),
              ],
            ),

            const SizedBox(height: 16),

            // SECTION CLIENT
            _buildSectionHeader(context, 'Client'),
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              title: delivery.customerName,
              subtitle: delivery.customerPhone,
            ),
            _buildInfoRow(
              context,
              icon: Icons.location_on_outlined,
              title: delivery.fullAddress,
              subtitle: 'Livraison à domicile',
            ),

            const SizedBox(height: 16),

            // SECTION COMMANDE
            _buildSectionHeader(context, 'Commande'),
            _buildInfoRow(
              context,
              icon: Icons.shopping_bag_outlined,
              title: delivery.productInfo,
              subtitle: '${delivery.orderTotal.toStringAsFixed(2)} €',
              trailing: Chip(
                label: Text(
                  'Frais: ${delivery.deliveryFee.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // SECTION LIVREUR (avatar + nom)
            _buildSectionHeader(context, 'Livreur'),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(delivery.deliveryPersonPhoto),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    delivery.deliveryPersonName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // BOUTON ACTION (trois points)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'details') onViewDetails();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('Voir détails'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // TIMELINE DE PROGRESSION
            ProgressTimeline(steps: delivery.timelineSteps),

            const SizedBox(height: 16),

            // DATES (badge unique)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    delivery.isLate &&
                        delivery.status != DeliveryStatus.delivered
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      delivery.isLate &&
                          delivery.status != DeliveryStatus.delivered
                      ? Colors.red.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateInfo(
                    context,
                    label: 'Expédiée',
                    date: delivery.shippingDate,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  _buildDateInfo(
                    context,
                    label: 'Arrivée estimée',
                    date: delivery.estimatedArrival,
                    isLate: delivery.isLate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context, {
    required String label,
    required DateTime date,
    bool isLate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: isLate
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isLate ? Colors.red : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
