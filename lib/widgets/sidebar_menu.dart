// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final String vendorName;
  final Function(int) onItemSelected;
  final VoidCallback onClose;
  final int selectedIndex;
  final int? driverCount; // Nouveau: nombre de livreurs

  const SidebarMenu({
    super.key,
    required this.vendorName,
    required this.onItemSelected,
    required this.onClose,
    this.selectedIndex = 0,
    this.driverCount,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header avec avatar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            child: Column(
              children: [
                // Avatar rond avec badge de livreurs
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.store,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    if (driverCount != null && driverCount! > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            driverCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Nom du vendeur
                Text(
                  vendorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vendeur Professionnel',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                // Statut du vendeur (optionnel)
                if (driverCount != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$driverCount livreur${driverCount! > 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: "Tableau de bord",
                  index: 0,
                  badgeCount: null,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: "Gestion produits",
                  index: 1,
                  badgeCount: null,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.receipt_long,
                  title: "Commandes",
                  index: 2,
                  badgeCount:
                      null, // Vous pouvez ajouter un badge pour nouvelles commandes
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.local_shipping,
                  title: "Livraisons",
                  index: 3,
                  badgeCount:
                      null, // Vous pouvez ajouter un badge pour livraisons en attente
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.directions_bike,
                  title: "Mes Livreurs",
                  index: 4,
                  badgeCount: driverCount, // Montre le nombre de livreurs
                  isDriverSection: true,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  title: "Abonnement",
                  index: 5,
                  badgeCount: null,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: "Mon Profil",
                  index: 6,
                  badgeCount: null,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.facebook,
                  title: "Intégration Facebook",
                  index: 7,
                  isLogout: false,
                  badgeCount: null,
                ),
              ],
            ),
          ),

          // Section de statistiques rapides (optionnelle)
          if (driverCount != null && driverCount! > 0)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$driverCount livreur${driverCount! > 1 ? 's' : ''} actif${driverCount! > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

          // Version
          Container(
            padding: const EdgeInsets.all(12),
            child: const Column(
              children: [
                Text(
                  'Commerce Madagascar',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    bool isLogout = false,
    bool isDriverSection = false,
    int? badgeCount,
  }) {
    final isSelected = selectedIndex == index;

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
                  color: isLogout
                      ? Colors.red[200]
                      : isDriverSection
                      ? Colors.yellow[200]
                      : Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isLogout
                            ? Colors.red[200]
                            : isDriverSection
                            ? Colors.yellow[200]
                            : Colors.white,
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (badgeCount != null)
                      Text(
                        '$badgeCount disponible${badgeCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDriverSection ? Colors.yellow : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
}
