import 'package:flutter/material.dart';
import '../models/delivery_model.dart'; // Import du modèle SQL
import 'status_badges.dart';
import 'progress_timeline.dart';

class DeliveryCard extends StatelessWidget {
  final SqlDelivery delivery;
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Livraison #${delivery.deliveryCode}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: delivery.deliveryStatus),
              ],
            ),

            const SizedBox(height: 16),

            // SECTION CLIENT
            _buildSectionHeader(context, 'Client'),
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              title: delivery.customerName,
              subtitle: delivery.recipientPhone,
            ),
            _buildInfoRow(
              context,
              icon: Icons.location_on_outlined,
              title: delivery.fullAddress,
              subtitle: delivery.extractedCity.isNotEmpty
                  ? delivery.extractedCity
                  : 'Adresse',
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
            _buildInfoRow(
              context,
              icon: Icons.receipt_outlined,
              title: 'Commande #${delivery.orderId}',
              subtitle: delivery.status.replaceAll('_', ' ').toUpperCase(),
            ),

            const SizedBox(height: 16),

            // SECTION LIVREUR
            _buildSectionHeader(context, 'Livreur'),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    delivery.deliveryPersonName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            if (delivery.timelineSteps.isNotEmpty)
              ProgressTimeline(steps: delivery.timelineSteps),

            const SizedBox(height: 16),

            // DATES ET TEMPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: delivery.isLate && delivery.status != 'delivered'
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: delivery.isLate && delivery.status != 'delivered'
                      ? Colors.red.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateInfo(
                        context,
                        label: 'Créée',
                        date: delivery.createdAt,
                      ),
                      if (delivery.scheduledAt != null) ...[
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        _buildDateInfo(
                          context,
                          label: 'Programmée',
                          date: delivery.scheduledAt!,
                          isLate: delivery.isLate,
                        ),
                      ],
                    ],
                  ),
                  if (delivery.estimatedDuration != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Durée estimée: ${delivery.estimatedDuration} min',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // INFORMATIONS OCR si disponibles
            if (delivery.ocrConfidence != null || delivery.source != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Source: ${_getSourceDisplayName(delivery.source)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.blue[800]),
                            ),
                            if (delivery.ocrConfidence != null)
                              Text(
                                'Confiance OCR: ${(delivery.ocrConfidence! * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.blue[800]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getSourceDisplayName(String? source) {
    switch (source) {
      case 'messenger_text':
        return 'Messenger (texte)';
      case 'messenger_image':
        return 'Messenger (image)';
      case 'whatsapp':
        return 'WhatsApp';
      case 'manual':
        return 'Manuelle';
      default:
        return source ?? 'Inconnue';
    }
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isLate ? Colors.red : null,
                  ),
                ),
                Text(
                  '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
