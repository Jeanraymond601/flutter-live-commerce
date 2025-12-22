// lib/widgets/product_stats_card.dart
// ignore_for_file: deprecated_member_use

import 'package:commerce/models/product.dart';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';

class ProductStatsCard extends StatelessWidget {
  final ProductStats stats;

  const ProductStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques Produits',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // 3 cartes sur la même ligne
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.inventory,
                    color: Colors.blue,
                    title: 'Produits',
                    value: '${stats.totalProducts}',
                    subtitle: 'Articles',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    title: 'Actifs',
                    value: '${stats.activeProducts}',
                    subtitle: 'En ligne',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.category,
                    color: Colors.orange,
                    title: 'Catégories',
                    value: '${stats.categoriesCount}',
                    subtitle: 'Variétés',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Réduit le padding
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18), // Taille réduite
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // IMPORTANT
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ), // Taille réduite
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14, // Taille réduite
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ), // Taille réduite
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Version ultra-mini pour affichage très compact
class ProductStatsCompactCard extends StatelessWidget {
  final ProductStats stats;

  const ProductStatsCompactCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
      ),
      child: Row(
        children: [
          _buildCompactStat(
            icon: Icons.inventory,
            value: '${stats.totalProducts}',
            label: 'Produits',
          ),
          const SizedBox(width: 16),
          _buildCompactStat(
            icon: Icons.check_circle,
            value: '${stats.activeProducts}',
            label: 'Actifs',
          ),
          const SizedBox(width: 16),
          _buildCompactStat(
            icon: Icons.category,
            value: '${stats.categoriesCount}',
            label: 'Catégories',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}

// Version horizontale avec séparateurs
class ProductStatsHorizontalCard extends StatelessWidget {
  final ProductStats stats;

  const ProductStatsHorizontalCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHorizontalStat(
            icon: Icons.inventory,
            value: '${stats.totalProducts}',
            label: 'Produits',
          ),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          _buildHorizontalStat(
            icon: Icons.check_circle,
            value: '${stats.activeProducts}',
            label: 'Actifs',
          ),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          _buildHorizontalStat(
            icon: Icons.category,
            value: '${stats.categoriesCount}',
            label: 'Catégories',
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}
