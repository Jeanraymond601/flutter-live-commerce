import 'package:flutter/material.dart';
import 'package:commerce/models/facebook_models.dart';

class FacebookCard extends StatelessWidget {
  final FacebookPage page;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onSettings;

  const FacebookCard({
    super.key,
    required this.page,
    this.isSelected = false,
    this.onSelect,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue[50] : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundImage: page.profilePicUrl != null
                      ? NetworkImage(page.profilePicUrl!)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: page.profilePicUrl == null
                      ? const Icon(Icons.facebook, color: Colors.blue)
                      : null,
                ),

                const SizedBox(width: 12),

                // Nom et catégorie
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        page.category ?? 'Non catégorisé',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicateur de sélection
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSelect,
                    child: Text(isSelected ? 'Sélectionnée' : 'Sélectionner'),
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton paramètres
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: onSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
