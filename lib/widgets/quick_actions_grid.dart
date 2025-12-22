import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onActionSelected;

  const QuickActionsGrid({super.key, required this.onActionSelected});

  final List<QuickAction> _actions = const [
    QuickAction(
      id: 'products',
      title: 'Mes produits',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFF4CAF50),
    ),
    QuickAction(
      id: 'livestreams',
      title: 'Mes lives',
      icon: Icons.videocam_outlined,
      color: Color(0xFF2196F3),
    ),
    QuickAction(
      id: 'orders',
      title: 'Commandes',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF9C27B0),
    ),
    QuickAction(
      id: 'stats',
      title: 'Statistiques',
      icon: Icons.analytics_outlined,
      color: Color(0xFFFF9800),
    ),
    QuickAction(
      id: 'support',
      title: 'Support & Aide',
      icon: Icons.support_agent_outlined,
      color: Color(0xFF795548),
    ),
    QuickAction(
      id: 'settings',
      title: 'Paramètres',
      icon: Icons.settings_outlined,
      color: Color(0xFF607D8B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Définir les couleurs de manière explicite
    final backgroundColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final cardBackgroundColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade50;
    final borderColor = isDarkMode
        ? Colors.grey.shade600
        : Colors.grey.shade200;
    final textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
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
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _actions.length,
            itemBuilder: (context, index) {
              final action = _actions[index];
              return _buildActionButton(
                action,
                cardBackgroundColor,
                borderColor,
                textColor,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    QuickAction action,
    Color backgroundColor,
    Color borderColor,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () => onActionSelected(action.id),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}
