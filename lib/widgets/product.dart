// lib/widgets/product_card.dart
import 'package:commerce/models/product.dart';
import 'package:commerce/utils/constants.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                children: [
                  // Statut
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: product.isActive
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Nom et code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.codeArticle.formatProductCode(),
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Menu d'actions
                  if (onEdit != null ||
                      onDelete != null ||
                      onToggleStatus != null)
                    _buildMenuButton(context),
                ],
              ),

              const SizedBox(height: 12),

              // Catégorie
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    product.categoryName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Prix et stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prix
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        Constants.formatPrice(product.price),
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                      ),
                    ],
                  ),

                  // Stock
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Stock',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _getStockIcon(product.stock),
                            size: 16,
                            color: _getStockColor(product.stock),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.stock}',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getStockColor(product.stock),
                                ),
                          ),
                        ],
                      ),
                      Text(
                        product.stockStatus,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: _getStockColor(product.stock),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Description (si disponible)
              if (product.description != null &&
                  product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              // Couleur et taille (si disponibles)
              if (product.color != null || product.size != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      if (product.color != null)
                        Row(
                          children: [
                            Icon(
                              Icons.color_lens,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.color!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      if (product.size != null)
                        Row(
                          children: [
                            Icon(
                              Icons.aspect_ratio,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.size!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      itemBuilder: (context) => [
        if (onToggleStatus != null)
          PopupMenuItem(
            value: 'toggle',
            child: Row(
              children: [
                Icon(
                  product.isActive ? Icons.block : Icons.check_circle,
                  color: product.isActive ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(product.isActive ? 'Désactiver' : 'Activer'),
              ],
            ),
          ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Supprimer'),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'toggle':
            onToggleStatus?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }

  IconData _getStockIcon(int stock) {
    if (stock == 0) return Icons.error_outline;
    if (stock <= 10) return Icons.warning;
    return Icons.check_circle;
  }
}

// Variante compacte pour les listes
class ProductCompactCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCompactCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: product.isActive ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            product.isActive ? Icons.check : Icons.block,
            color: product.isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.codeArticle.formatProductCode()),
            Row(
              children: [
                Text(Constants.formatPrice(product.price)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: _getStockColor(product.stock).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.stock}',
                    style: TextStyle(
                      color: _getStockColor(product.stock),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }
}
