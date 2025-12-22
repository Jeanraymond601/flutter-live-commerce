// lib/widgets/facebook_stats_card.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';

class FacebookStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const FacebookStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Statistiques Facebook',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CORRECTION: Utiliser GridView pour un layout responsive
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatTile(
                  'Pages totales',
                  '${stats['total_pages'] ?? 0}',
                  Colors.blue,
                  Icons.pages,
                ),
                _buildStatTile(
                  'Pages connectées',
                  '${stats['connected_pages'] ?? 0}',
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatTile(
                  'Commentaires en attente',
                  '${stats['pending_comments'] ?? 0}',
                  Colors.orange,
                  Icons.comment,
                ),
                _buildStatTile(
                  'Haute priorité',
                  '${stats['high_priority_comments'] ?? 0}',
                  Colors.red,
                  Icons.priority_high,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
