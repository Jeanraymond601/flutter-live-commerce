import 'package:flutter/material.dart';
import 'package:commerce/models/product.dart';
import 'package:commerce/utils/constants.dart';

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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= AVATAR =================
              _ProductAvatar(name: product.name, isActive: product.isActive),

              const SizedBox(width: 14),

              // ================= CONTENT =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME + MENU
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildMenu(context),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // CODE
                    Text(
                      product.codeArticle.formatProductCode(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // CATEGORY
                    Row(
                      children: [
                        Icon(
                          _categoryIcon(product.categoryName),
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.categoryName.isNotEmpty
                              ? product.categoryName
                              : 'Sans catégorie',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // PRICE + STOCK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Constants.formatPrice(product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),

                        _StockBadge(stock: product.stock),
                      ],
                    ),

                    // OPTIONS
                    if (product.color != null || product.size != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 10,
                          children: [
                            if (product.color != null)
                              _MiniInfo(
                                icon: Icons.palette,
                                label: product.color!,
                              ),
                            if (product.size != null)
                              _MiniInfo(
                                icon: Icons.straighten,
                                label: product.size!,
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // ================= STATUS BUTTON =================
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: product.isActive
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        onPressed: onToggleStatus,
                        icon: Icon(
                          product.isActive ? Icons.check_circle : Icons.block,
                          size: 18,
                          color: product.isActive ? Colors.green : Colors.red,
                        ),
                        label: Text(
                          product.isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            color: product.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  // ================= MENU =================

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
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
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
    );
  }

  // ================= HELPERS =================

  IconData _categoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('vetement')) return Icons.checkroom;
    if (c.contains('access')) return Icons.watch;
    if (c.contains('electron')) return Icons.devices;
    if (c.contains('environ')) return Icons.eco;
    if (c.contains('aliment')) return Icons.restaurant;
    return Icons.category;
  }
}

// ================= SUB WIDGETS =================

class _ProductAvatar extends StatelessWidget {
  final String name;
  final bool isActive;

  const _ProductAvatar({required this.name, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 2).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final color = stock == 0
        ? Colors.red
        : stock <= 10
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$stock',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
