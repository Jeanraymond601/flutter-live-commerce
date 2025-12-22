// lib/widgets/subscription_card.dart
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.webhook, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Webhooks & Synchronisation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIF',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SubscriptionInfo(),
            const SizedBox(height: 20),
            _SubscriptionActions(),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut des webhooks',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatusIndicator(label: 'Commentaires', isActive: true),
            const SizedBox(width: 16),
            _StatusIndicator(label: 'Messages', isActive: true),
            const SizedBox(width: 16),
            _StatusIndicator(label: 'Publications', isActive: true),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Dernière synchronisation: il y a 5 minutes',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        const Text(
          'Prochaine synchronisation automatique: dans 55 minutes',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusIndicator({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SubscriptionActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Synchroniser maintenant'),
            onPressed: () {
              _forceSync(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.settings, size: 16),
          label: const Text('Configurer'),
          onPressed: () {
            _showSettings(context);
          },
        ),
      ],
    );
  }

  void _forceSync(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Synchroniser maintenant'),
          content: const Text(
            'Voulez-vous forcer une synchronisation complète des données Facebook ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performSync(context);
              },
              child: const Text('Synchroniser'),
            ),
          ],
        );
      },
    );
  }

  void _performSync(BuildContext context) {
    // TODO: Implement sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Synchronisation en cours...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _WebhookSettings();
      },
    );
  }
}

class _WebhookSettings extends StatefulWidget {
  @override
  State<_WebhookSettings> createState() => _WebhookSettingsState();
}

class _WebhookSettingsState extends State<_WebhookSettings> {
  bool _autoSyncEnabled = true;
  int _syncInterval = 60;
  bool _commentsWebhook = true;
  bool _messagesWebhook = true;
  bool _postsWebhook = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Configuration des webhooks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Synchronisation automatique'),
            subtitle: const Text('Synchroniser les données périodiquement'),
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
            },
          ),
          if (_autoSyncEnabled) ...[
            const SizedBox(height: 12),
            const Text('Intervalle de synchronisation (minutes):'),
            Slider(
              value: _syncInterval.toDouble(),
              min: 15,
              max: 240,
              divisions: 9,
              label: '$_syncInterval min',
              onChanged: (value) {
                setState(() {
                  _syncInterval = value.toInt();
                });
              },
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Webhooks activés:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Commentaires'),
            subtitle: const Text('Recevoir les nouveaux commentaires'),
            value: _commentsWebhook,
            onChanged: (value) {
              setState(() {
                _commentsWebhook = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Messages'),
            subtitle: const Text('Recevoir les nouveaux messages'),
            value: _messagesWebhook,
            onChanged: (value) {
              setState(() {
                _messagesWebhook = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Publications'),
            subtitle: const Text('Recevoir les nouvelles publications'),
            value: _postsWebhook,
            onChanged: (value) {
              setState(() {
                _postsWebhook = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Enregistrer les paramètres'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _testWebhooks(context);
            },
            child: const Text('Tester les webhooks'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // TODO: Save webhook settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres des webhooks enregistrés'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _testWebhooks(BuildContext context) {
    // TODO: Test webhooks
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('Test des webhooks en cours...'),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
