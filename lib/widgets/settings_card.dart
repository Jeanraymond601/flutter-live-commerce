import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final String selectedLanguage;
  final List<String> languages;
  final Function(bool) onDarkModeChanged;
  final Function(bool) onNotificationsChanged;
  final Function(String?) onLanguageChanged;

  const SettingsCard({
    super.key,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.selectedLanguage,
    required this.languages,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
    required this.onLanguageChanged,
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
          Text(
            'Paramètres',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const Divider(height: 20),

          // Mode sombre/clair
          _buildSettingItem(
            context: context,
            icon: darkModeEnabled
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            title: darkModeEnabled ? 'Mode sombre' : 'Mode clair',
            subtitle: 'Changer le thème de l\'application',
            trailing: Switch(
              value: darkModeEnabled,
              onChanged: onDarkModeChanged,
              activeColor: const Color(0xFF2196F3),
            ),
          ),

          const Divider(height: 20),

          // Notifications
          _buildSettingItem(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications push',
            subtitle: 'Recevoir les notifications',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
              activeColor: const Color(0xFF4CAF50),
            ),
          ),

          const Divider(height: 20),

          // Langue
          _buildSettingItem(
            context: context,
            icon: Icons.language_outlined,
            title: 'Langue',
            subtitle: 'Langue de l\'interface',
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: Container(),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              onChanged: onLanguageChanged,
              items: languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
