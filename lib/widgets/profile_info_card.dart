import 'package:flutter/material.dart';
import '../models/seller_profile.dart';

class ProfileInfoCard extends StatelessWidget {
  final SellerProfile sellerProfile;
  final VoidCallback onEditPressed;

  const ProfileInfoCard({
    super.key,
    required this.sellerProfile,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: onEditPressed,
                icon: Icon(
                  Icons.edit_outlined,
                  color: sellerProfile.subscription.color,
                  size: 20,
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Liste des informations
          _buildInfoRow(
            context: context,
            icon: Icons.email_outlined,
            label: 'Email',
            value: sellerProfile.email,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context: context,
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: sellerProfile.phone,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context: context,
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: sellerProfile.address,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context: context,
            icon: Icons.calendar_today_outlined,
            label: 'Membre depuis',
            value:
                '${sellerProfile.createdAt.day}/${sellerProfile.createdAt.month}/${sellerProfile.createdAt.year}',
          ),

          const SizedBox(height: 20),

          // Bouton modifier
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onEditPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: sellerProfile.subscription.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Modifier mes informations'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: sellerProfile.subscription.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: sellerProfile.subscription.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
