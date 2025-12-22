// lib/widgets/facebook_auth_section.dart - VERSION COMPLÈTEMENT CORRIGÉE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:commerce/provider/facebook_provider.dart';
import 'package:commerce/services/facebook_service.dart';

class FacebookAuthSection extends StatefulWidget {
  final VoidCallback? onDisconnected;
  final VoidCallback? onConnected; // ⬅️ AJOUT: Callback pour connexion réussie

  const FacebookAuthSection({
    super.key,
    this.onDisconnected,
    this.onConnected, // ⬅️ AJOUT: Nouveau paramètre
  });

  @override
  State<FacebookAuthSection> createState() => _FacebookAuthSectionState();
}

class _FacebookAuthSectionState extends State<FacebookAuthSection> {
  bool _isConnecting = false;
  bool _hasInitialized = false;
  bool _checkingConnection =
      false; // ⬅️ AJOUT: Pour vérifier après autorisation

  @override
  void initState() {
    super.initState();
    _initializeOnce();
  }

  void _initializeOnce() {
    if (_hasInitialized) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasInitialized) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted || _hasInitialized) return;

    try {
      final provider = Provider.of<FacebookProvider>(context, listen: false);

      if (provider.pages.isNotEmpty) {
        _hasInitialized = true;
        return;
      }

      await provider.loadFacebookPages();
      _hasInitialized = true;
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FacebookProvider>(context);
    final service = Provider.of<FacebookService>(context, listen: false);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentState(provider, service),
    );
  }

  Widget _buildCurrentState(
    FacebookProvider provider,
    FacebookService service,
  ) {
    // État de chargement
    if ((provider.isLoading || _checkingConnection) && !_hasInitialized) {
      return const _LoadingState();
    }

    // État d'erreur
    if (provider.error != null && provider.pages.isEmpty) {
      return _ErrorState(
        error: provider.error!,
        onRetry: () => _safeLoadPages(provider),
      );
    }

    // État connecté
    if (provider.pages.isNotEmpty) {
      return _ConnectedState(
        provider: provider,
        service: service,
        onRefresh: () => _safeLoadPages(provider),
        onDisconnected: widget.onDisconnected,
      );
    }

    // État déconnecté
    return _DisconnectedState(
      isConnecting: _isConnecting,
      onConnect: () => _connectToFacebook(service, provider),
    );
  }

  Future<void> _safeLoadPages(FacebookProvider provider) async {
    try {
      await provider.loadFacebookPages();
    } catch (e) {
      debugPrint('Error loading pages: $e');
    }
  }

  // ⬅️ CORRECTION MAJEURE: Méthode pour gérer la connexion Facebook
  Future<void> _connectToFacebook(
    FacebookService service,
    FacebookProvider provider,
  ) async {
    if (_isConnecting || !mounted) return;

    setState(() => _isConnecting = true);

    try {
      final response = await service.connectToFacebook();

      if (!mounted) {
        setState(() => _isConnecting = false);
        return;
      }

      if (response.success && response.authUrl.isNotEmpty) {
        final uri = Uri.parse(response.authUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          // ⬅️ CORRECTION: Afficher boîte de dialogue avec vérification automatique
          _showConnectionDialog(context, () {
            // Quand l'utilisateur clique sur "J'ai autorisé"
            _checkFacebookAuthorization(provider);
          });
        } else {
          _showSnackBar(
            'Impossible d\'ouvrir le lien d\'authentification',
            Colors.red,
          );
        }
      } else {
        _showSnackBar('Erreur de connexion Facebook', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Erreur: ${_safeSubstring(e.toString(), 50)}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  // ⬅️ NOUVELLE MÉTHODE: Vérifier l'autorisation Facebook
  void _checkFacebookAuthorization(FacebookProvider provider) async {
    if (!mounted) return;

    setState(() => _checkingConnection = true);

    // Afficher un indicateur de chargement
    final snackbarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Vérification de la connexion Facebook...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      // Essayer plusieurs fois avec un délai
      bool success = false;
      for (int attempt = 0; attempt < 5; attempt++) {
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) break;

        // Rafraîchir les pages
        await provider.loadFacebookPages();

        if (provider.pages.isNotEmpty) {
          success = true;
          break;
        }
      }

      // Fermer le snackbar
      snackbarController.close();

      if (!mounted) return;

      if (success) {
        // Connexion réussie
        _showSnackBar('✅ Connexion Facebook réussie !', Colors.green);

        // Appeler le callback si fourni
        if (widget.onConnected != null) {
          widget.onConnected!();
        }

        // Sélectionner automatiquement la première page si aucune n'est sélectionnée
        if (provider.selectedPage == null && provider.pages.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            provider.selectPage(provider.pages.first.pageId, force: true);
          }
        }
      } else {
        _showSnackBar(
          'Aucune page Facebook trouvée après connexion',
          Colors.orange,
        );
      }
    } catch (e) {
      if (mounted) {
        snackbarController.close();
        _showSnackBar('Erreur de vérification: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _checkingConnection = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ⬅️ CORRECTION: Boîte de dialogue améliorée
  void _showConnectionDialog(BuildContext context, VoidCallback onAuthorized) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.facebook, color: Color(0xFF1877F2)),
            SizedBox(width: 8),
            Text('Connexion Facebook'),
          ],
        ),
        content: SizedBox(
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instructions :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. '),
                  Expanded(child: Text('Le navigateur s\'ouvre avec Facebook')),
                ],
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('2. '),
                  Expanded(child: Text('Connectez-vous avec votre compte')),
                ],
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('3. '),
                  Expanded(
                    child: Text('Autorisez toutes les permissions requises'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Après autorisation, cliquez sur "Vérifier la connexion"',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              onAuthorized(); // Vérifier la connexion
            },
            child: const Text('Vérifier la connexion'),
          ),
        ],
      ),
    );
  }

  String _safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}

// ==================== ÉTATS SIMPLIFIÉS ====================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Chargement Facebook...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _safeSubstring('Erreur: $error', 80),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}

class _ConnectedState extends StatelessWidget {
  final FacebookProvider provider;
  final FacebookService service;
  final VoidCallback onRefresh;
  final VoidCallback? onDisconnected;

  const _ConnectedState({
    required this.provider,
    required this.service,
    required this.onRefresh,
    this.onDisconnected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPage = provider.selectedPage;
    final pagesCount = provider.pages.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connecté à Facebook',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        selectedPage != null
                            ? selectedPage.name
                            : '$pagesCount page(s)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Rafraîchir',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions rapides
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.pages, size: 16),
                  label: const Text('Voir pages'),
                  onPressed: () => _showPages(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Déconnecter'),
                  onPressed: () => _confirmDisconnect(context),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPages(BuildContext context) {
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Pages Facebook',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...provider.pages.map(
            (page) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: page.profilePicUrl != null
                    ? Image.network(page.profilePicUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.pages, color: Colors.blue),
              ),
              title: Text(page.name),
              subtitle: Text(page.category ?? 'Non catégorisé'),
              trailing: page.isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                  provider.selectPage(page.pageId);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmDisconnect(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnecter Facebook ?'),
        content: const Text(
          'Vous devrez vous reconnecter pour utiliser les fonctionnalités Facebook.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (!context.mounted) return;

              Navigator.pop(context);

              try {
                final success = await service.disconnectFacebook();

                if (!context.mounted) return;

                if (success) {
                  provider.clearPages();

                  if (onDisconnected != null) {
                    onDisconnected!();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Déconnexion réussie'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Échec de la déconnexion'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _DisconnectedState extends StatelessWidget {
  final bool isConnecting;
  final VoidCallback onConnect;

  const _DisconnectedState({
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.facebook, size: 64, color: Color(0xFF1877F2)),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous à Facebook',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Gérez vos pages Facebook et commentaires',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isConnecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.facebook),
                label: Text(
                  isConnecting
                      ? 'Connexion en cours...'
                      : 'Se connecter à Facebook',
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: isConnecting ? null : onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
