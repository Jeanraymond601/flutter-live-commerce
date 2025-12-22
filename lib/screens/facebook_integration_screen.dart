// lib/screens/facebook_integration_screen.dart - VERSION COMPLÈTEMENT CORRIGÉE
import 'package:commerce/models/facebook_models.dart';
import 'package:commerce/provider/facebook_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:commerce/widgets/facebook_auth_section.dart';
import 'package:commerce/widgets/facebook_stats_card.dart';
import 'package:commerce/widgets/posts_feed_section.dart';
import 'package:commerce/widgets/lives_section.dart';

class FacebookIntegrationScreen extends StatefulWidget {
  static const String routeName = '/facebook-integration';

  const FacebookIntegrationScreen({super.key});

  @override
  State<FacebookIntegrationScreen> createState() =>
      _FacebookIntegrationScreenState();
}

class _FacebookIntegrationScreenState extends State<FacebookIntegrationScreen> {
  int _selectedIndex = 0;
  bool _initialLoadComplete = false;

  final List<Widget> _sections = [
    const _DashboardSection(),
    const _PostsSection(),
    const _LiveCommerceSection(),
  ];

  final List<String> _sectionTitles = [
    'Tableau de bord',
    'Publications',
    'Live Commerce',
  ];

  @override
  void initState() {
    super.initState();
    // CORRECTION: Charger après un délai pour éviter le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_initialLoadComplete) return;

    final provider = Provider.of<FacebookProvider>(context, listen: false);

    if (provider.pages.isEmpty) {
      await provider.loadFacebookPages();
    }

    _initialLoadComplete = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_sectionTitles[_selectedIndex]),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<FacebookProvider>(
        builder: (context, provider, child) {
          // Afficher un loading initial seulement
          if (!_initialLoadComplete && provider.pages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Afficher l'erreur si elle existe
          if (provider.error != null && provider.pages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de connexion Facebook',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        provider.loadFacebookPages();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Navigation tabs simplifiée
              Container(
                height: 60,
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_sectionTitles.length, (index) {
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: _selectedIndex == index
                                ? const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF1877F2),
                                      width: 3,
                                    ),
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _sectionTitles[index],
                                style: TextStyle(
                                  fontWeight: _selectedIndex == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedIndex == index
                                      ? const Color(0xFF1877F2)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Main content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final provider = Provider.of<FacebookProvider>(
                      context,
                      listen: false,
                    );
                    await provider.loadFacebookPages();
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _sections[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Dashboard Section
class _DashboardSection extends StatelessWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FacebookProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FacebookAuthSection(
          onDisconnected: () {
            // Callback après déconnexion
            provider.clearPages();
          },
          onConnected: () {
            // ⬅️ AJOUT: Callback après connexion réussie
            if (provider.pages.isNotEmpty && provider.selectedPage == null) {
              // Sélectionner automatiquement la première page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  provider.selectPage(provider.pages.first.pageId, force: true);
                }
              });
            }
          },
        ),
        const SizedBox(height: 20),
        if (provider.selectedPage != null) ...[
          FacebookStatsCard(stats: provider.stats),
          const SizedBox(height: 20),
          PageListSection(
            pages: provider.pages,
            onSelect: (pageId) {
              provider.selectPage(pageId, force: true);
            },
          ),
          const SizedBox(height: 20),
          const SubscriptionCard(),
        ] else if (provider.pages.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 12),
                  const Text(
                    'Sélectionnez une page Facebook',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Veuillez sélectionner une page pour voir les statistiques.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (provider.pages.isNotEmpty) {
                        provider.selectPage(
                          provider.pages.first.pageId,
                          force: true,
                        );
                      }
                    },
                    child: const Text('Sélectionner une page'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Posts Section
class _PostsSection extends StatelessWidget {
  const _PostsSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FacebookProvider>(context);

    if (provider.selectedPage == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.newspaper, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Aucune page sélectionnée',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez sélectionner une page Facebook pour voir ses publications',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (provider.pages.isNotEmpty) {
                    provider.selectPage(
                      provider.pages.first.pageId,
                      force: true,
                    );
                  }
                },
                child: const Text('Sélectionner une page'),
              ),
            ],
          ),
        ),
      );
    }

    return const PostsFeedSection();
  }
}

// Live Commerce Section
class _LiveCommerceSection extends StatelessWidget {
  const _LiveCommerceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.live_tv, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Live Commerce',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez vos lives Facebook pour gérer les commentaires en temps réel',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.video_call),
                  label: const Text('Démarrer un live'),
                  onPressed: () {
                    // Fonctionnalité de live
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const LivesSection(),
      ],
    );
  }
}

// PageListSection avec callback
class PageListSection extends StatelessWidget {
  final List<FacebookPage> pages;
  final Function(String pageId) onSelect;

  const PageListSection({
    super.key,
    required this.pages,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.pages, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('Aucune page Facebook', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes Pages Facebook',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: pages.map((page) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child:
                      page.profilePicUrl != null &&
                          page.profilePicUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            page.profilePicUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.facebook, color: Colors.blue),
                ),
                title: Text(
                  page.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(page.category ?? 'Non catégorisé'),
                trailing: page.isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  if (!page.isSelected) {
                    onSelect(page.pageId);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Extension pour List
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// SubscriptionCard
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Abonnement Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Activez votre abonnement pour débloquer toutes les fonctionnalités',
              style: TextStyle(color: Colors.purple[700]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Achat d'abonnement
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Voir les plans'),
            ),
          ],
        ),
      ),
    );
  }
}
