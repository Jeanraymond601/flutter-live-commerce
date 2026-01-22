// lib/widgets/profile_info_card.dart
import 'package:flutter/material.dart';
import '../notifiers/seller_profile_notifier.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: onEditPressed,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDarkMode ? Colors.white : Colors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context: context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: sellerProfile.email,
            ),
            _buildDivider(context),
            _buildInfoItem(
              context: context,
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: sellerProfile.phone.isNotEmpty
                  ? sellerProfile.phone
                  : 'Non renseigné',
            ),
            _buildDivider(context),
            _buildInfoItem(
              context: context,
              icon: Icons.location_on_outlined,
              label: 'Adresse',
              value: sellerProfile.address.isNotEmpty
                  ? sellerProfile.address
                  : 'Non renseignée',
            ),
            _buildDivider(context),
            _buildInfoItem(
              context: context,
              icon: Icons.business_outlined,
              label: 'Entreprise',
              value: sellerProfile.companyName.isNotEmpty
                  ? sellerProfile.companyName
                  : 'Non renseignée',
            ),
            if (sellerProfile.bio != null && sellerProfile.bio!.isNotEmpty) ...[
              _buildDivider(context),
              _buildInfoItem(
                context: context,
                icon: Icons.description_outlined,
                label: 'Bio',
                value: sellerProfile.bio!,
                isMultiline: true,
              ),
            ],
            if (sellerProfile.website != null &&
                sellerProfile.website!.isNotEmpty) ...[
              _buildDivider(context),
              _buildInfoItem(
                context: context,
                icon: Icons.language_outlined,
                label: 'Site web',
                value: sellerProfile.website!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            size: 20,
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
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                isMultiline
                    ? Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      )
                    : Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
    );
  }
}
