// lib/widgets/sidebar_menu.dart - VERSION CORRIGÉE
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/seller_profile_notifier.dart';

class SidebarMenu extends StatelessWidget {
  final Function(int) onItemSelected;
  final VoidCallback onClose;
  final int selectedIndex;

  const SidebarMenu({
    super.key,
    required this.onItemSelected,
    required this.onClose,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final sellerProfile = Provider.of<SellerProfileNotifier>(context).profile;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF005DFF),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // =========================
          // HEADER PROFIL VENDEUR
          // =========================
          Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    // Avatar avec initiales
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: sellerProfile.profileImageUrl != null
                          ? CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(
                                sellerProfile.profileImageUrl!,
                              ),
                            )
                          : Text(
                              _getInitials(sellerProfile.fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),

                    // Statut en ligne
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Nom vendeur
                Text(
                  sellerProfile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  sellerProfile.companyName.isNotEmpty
                      ? sellerProfile.companyName
                      : 'Vendeur professionnel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                // Badge niveau d'abonnement (en blanc)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sellerProfile.subscriptionLevel?.toUpperCase() ??
                            'BASIC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // MENU PRINCIPAL
          // =========================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Tableau de bord',
                  index: 0,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Gestion produits',
                  index: 1,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.receipt_long,
                  title: 'Commandes',
                  index: 2,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.local_shipping,
                  title: 'Livraisons',
                  index: 3,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.directions_bike,
                  title: 'Mes Livreurs',
                  index: 4,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Abonnement',
                  index: 5,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Mon Profil',
                  index: 6,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.facebook,
                  title: 'Intégration Facebook',
                  index: 7,
                ),

                // =========================
                // NOUVEAU : EXTRACTION IA (après Facebook)
                // =========================
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.auto_awesome_mosaic,
                  title: 'Analyse IA',
                  index: 8,
                  badge: 'IA',
                ),
              ],
            ),
          ),

          // =========================
          // FOOTER (inchangé)
          // =========================
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Information version (si existante dans ton code original)
                const Text(
                  'Commerce Madagascar',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 2),
                const Text(
                  'v2.1.0',
                  style: TextStyle(color: Colors.white54, fontSize: 9),
                ),
                const SizedBox(height: 2),
                const Text(
                  '© 2026 Tous droits réservés',
                  style: TextStyle(color: Colors.white54, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MENU ITEM
  // =========================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    String? subtitle,
    Color? color,
    String? badge,
  }) {
    final isSelected = selectedIndex == index;
    final itemColor = color ?? Colors.white;

    return Material(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () {
          onItemSelected(index);
          onClose();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected ? itemColor : Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? itemColor : Colors.white,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: itemColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: itemColor),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: itemColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 3,
                  height: 24,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.2),
    );
  }

  // =========================
  // INITIALS GENERATOR
  // =========================
  String _getInitials(String name) {
    if (name.trim().isEmpty) return '??';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
