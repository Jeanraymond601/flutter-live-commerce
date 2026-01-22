// lib/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/seller_profile_notifier.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onImageTap;

  const ProfileHeader({super.key, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final sellerProfile = Provider.of<SellerProfileNotifier>(context).profile;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar et informations
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF005DFF),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: sellerProfile.profileImageUrl != null
                        ? NetworkImage(sellerProfile.profileImageUrl!)
                        : null,
                    child: sellerProfile.profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF005DFF),
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Informations du profil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      sellerProfile.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Nom de l'entreprise
                    Text(
                      sellerProfile.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Statut "Actif"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Actif',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bouton "Changer le profil"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onImageTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF005DFF).withOpacity(0.3),
              ),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'Changer le profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
