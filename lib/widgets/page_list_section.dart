// lib/widgets/page_list_section.dart - VERSION CORRIGÉE
import 'package:commerce/models/facebook_models.dart';
import 'package:flutter/material.dart';
import 'package:commerce/widgets/facebook_card.dart';

class PageListSection extends StatelessWidget {
  final List<FacebookPage> pages;
  final VoidCallback onSelect;
  final VoidCallback? onRefresh;

  const PageListSection({
    super.key,
    required this.pages,
    required this.onSelect,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes Pages Facebook',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // CORRECTION: Utiliser ListView au lieu de Column pour éviter l'overflow
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return FacebookCard(
                page: pages[index],
                isSelected: pages[index].isSelected,
                onSelect: () => _handlePageSelect(context, pages[index]),
                onSettings: () => _showSettings(context, pages[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePageSelect(BuildContext context, FacebookPage page) {
    // CORRECTION: Éviter la sélection automatique si déjà sélectionnée
    if (page.isSelected) {
      _showAlreadySelectedDialog(context, page);
      return;
    }

    // Sinon, procéder à la sélection
    onSelect();
  }

  void _showAlreadySelectedDialog(BuildContext context, FacebookPage page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Page déjà sélectionnée'),
        content: Text('La page "${page.name}" est déjà sélectionnée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, FacebookPage page) {
    // CORRECTION: Utiliser un SingleChildScrollView pour éviter l'overflow
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres: ${page.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // ... Vos autres widgets de paramètres ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Mes Pages Facebook',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.pages, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Aucune page Facebook',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour voir vos pages',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
