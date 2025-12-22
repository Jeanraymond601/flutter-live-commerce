import 'package:flutter/material.dart';
import '../models/seller_profile.dart';

class ProfileHeader extends StatelessWidget {
  final SellerProfile sellerProfile;
  final VoidCallback onImageTap;

  const ProfileHeader({
    super.key,
    required this.sellerProfile,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Définir les couleurs de manière explicite pour éviter les null
    final avatarBackgroundColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade200;
    final iconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500;
    final buttonTextColor = isDarkMode ? Colors.white : Colors.grey.shade700;
    final buttonBorderColor = isDarkMode
        ? Colors.grey.shade600
        : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
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
        children: [
          // Avatar avec badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sellerProfile.subscription.color,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: avatarBackgroundColor,
                    backgroundImage: sellerProfile.profileImageUrl != null
                        ? NetworkImage(sellerProfile.profileImageUrl!)
                        : null,
                    child: sellerProfile.profileImageUrl == null
                        ? Icon(Icons.person, size: 40, color: iconColor)
                        : null,
                  ),
                ),
              ),
              // Badge de statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sellerProfile.statusColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  sellerProfile.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Nom complet
          Text(
            sellerProfile.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // Nom de l'entreprise
          Text(
            sellerProfile.companyName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: sellerProfile.subscription.color,
            ),
          ),

          const SizedBox(height: 4),

          // Rôle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: sellerProfile.subscription.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Vendeur',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sellerProfile.subscription.color,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bouton modifier l'avatar
          OutlinedButton.icon(
            onPressed: onImageTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonTextColor,
              side: BorderSide(color: buttonBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Modifier la photo'),
          ),
        ],
      ),
    );
  }
}
