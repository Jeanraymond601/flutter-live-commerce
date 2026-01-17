// lib/widgets/driver_card.dart
// VERSION UX PRO MOBILE – AVATAR AVEC INITIALES + MENU ACTIONS STYLÉ

import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../utils/constants.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onEdit; // Ajout de la fonction onEdit
  final VoidCallback? onDelete; // Ajout de la fonction onDelete
  final bool isSelected;

  const DriverCard({
    super.key,
    required this.driver,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  // ================= INITIALS =================
  String get _initials {
    final parts = driver.fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.defaultPadding,
        vertical: Constants.defaultPadding / 2,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Constants.defaultRadius),
        onTap: null, // DÉSACTIVÉ - L'utilisateur doit utiliser le menu
        child: Padding(
          padding: const EdgeInsets.all(Constants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDriverInfo(),
              const SizedBox(height: 10),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // AVATAR AVEC INITIALES
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              _initials,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // NOM + TEL
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.fullName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                driver.telephone,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // ================= MENU ACTIONS =================
        // Toujours afficher le menu d'actions
        _buildActionsMenu(),
      ],
    );
  }

  // ================= MENU D'ACTIONS =================
  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[700]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      onSelected: (value) {
        if (value == 'edit' && onEdit != null) {
          onEdit!(); // Appel direct de la fonction onEdit
        }
        if (value == 'delete' && onDelete != null) {
          onDelete!(); // Appel direct de la fonction onDelete
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          enabled: onEdit != null,
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 18,
                color: onEdit != null ? Colors.blueAccent : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Modifier',
                style: TextStyle(
                  color: onEdit != null ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          enabled: onDelete != null,
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 18,
                color: onDelete != null ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Supprimer',
                style: TextStyle(
                  color: onDelete != null ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= INFO =================
  Widget _buildDriverInfo() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.email, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                driver.email,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                driver.zone_livraison,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= STATUS =================
  Widget _buildBottomInfo() {
    return Row(
      children: [
        _buildStatusChip(
          icon: _getStatusIcon(driver.statut),
          label: driver.statusDisplay,
          color: Color(driver.statusColor),
        ),
        const Spacer(),
        _buildStatusChip(
          icon: driver.disponibilite ? Icons.check_circle : Icons.cancel,
          label: driver.availabilityDisplay,
          color: driver.disponibilite ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return Icons.check_circle;
      case 'en_attente':
        return Icons.access_time;
      case 'suspendu':
        return Icons.pause_circle;
      case 'rejeté':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
