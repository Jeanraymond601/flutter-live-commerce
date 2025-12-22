// lib/widgets/lives_section.dart
import 'package:flutter/material.dart';
import 'package:commerce/models/facebook_models.dart';

class LivesSection extends StatelessWidget {
  const LivesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from provider
    final List<FacebookLiveVideo> lives = [];

    if (lives.isEmpty) {
      return const _NoLiveVideos();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LiveHeader(lives: lives),
        const SizedBox(height: 16),
        ...lives.map((live) => _LiveCard(live: live)),
      ],
    );
  }
}

class _NoLiveVideos extends StatelessWidget {
  const _NoLiveVideos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun live en cours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Commencez un live Facebook pour traiter les commandes en direct',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Créer un live'),
              onPressed: () {
                // TODO: Implement create live
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  final List<FacebookLiveVideo> lives;

  const _LiveHeader({required this.lives});

  @override
  Widget build(BuildContext context) {
    final liveCount = lives.length;
    final liveNow = lives.where((live) => live.isLive).length;
    final totalRevenue = lives.fold<double>(
      0,
      (sum, live) => sum + live.totalRevenue,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Commerce',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderStat(
                  value: liveCount.toString(),
                  label: 'Total lives',
                  icon: Icons.video_library,
                  color: Colors.blue,
                ),
                _HeaderStat(
                  value: liveNow.toString(),
                  label: 'En direct',
                  icon: Icons.live_tv,
                  color: Colors.red,
                ),
                _HeaderStat(
                  value: '${totalRevenue.toStringAsFixed(0)}€',
                  label: 'Revenu total',
                  icon: Icons.euro,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau live'),
                    onPressed: () {
                      // TODO: Implement new live
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: const Text('Planifier'),
                  onPressed: () {
                    // TODO: Implement schedule live
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final FacebookLiveVideo live;

  const _LiveCard({required this.live});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _LiveStatusBadge(live: live),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    live.title ?? 'Live sans titre',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showLiveMenu(context, live);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (live.description != null && live.description!.isNotEmpty)
              Text(
                live.description!,
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            _LiveStats(live: live),
            const SizedBox(height: 16),
            _LiveActions(live: live),
          ],
        ),
      ),
    );
  }

  void _showLiveMenu(BuildContext context, FacebookLiveVideo live) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytiques'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement analytics
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement copy link
              },
            ),
            if (live.isLive)
              ListTile(
                leading: const Icon(Icons.stop, color: Colors.red),
                title: const Text('Terminer le live'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement stop live
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Supprimer'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteLive(context, live);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteLive(BuildContext context, FacebookLiveVideo live) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le live ?'),
          content: const Text(
            'Cette action est irréversible. Les données associées seront également supprimées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement delete
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class _LiveStatusBadge extends StatelessWidget {
  final FacebookLiveVideo live;

  const _LiveStatusBadge({required this.live});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (live.isLive) {
      backgroundColor = Colors.red;
      textColor = Colors.white;
      text = 'EN DIRECT';
    } else if (live.isEnded) {
      backgroundColor = Colors.grey;
      textColor = Colors.white;
      text = 'TERMINÉ';
    } else if (live.isScheduled) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      text = 'PLANIFIÉ';
    } else {
      backgroundColor = Colors.orange;
      textColor = Colors.white;
      text = 'EN TRAITEMENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _LiveStats extends StatelessWidget {
  final FacebookLiveVideo live;

  const _LiveStats({required this.live});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.comment,
          value: live.totalComments.toString(),
          label: 'Commentaires',
        ),
        _StatItem(
          icon: Icons.shopping_cart,
          value: live.totalOrders.toString(),
          label: 'Commandes',
        ),
        _StatItem(
          icon: Icons.euro,
          value: '${live.totalRevenue.toStringAsFixed(2)}€',
          label: 'Revenu',
        ),
        _StatItem(
          icon: Icons.timer,
          value: '${live.nlpProcessedComments}',
          label: 'Traités',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _LiveActions extends StatelessWidget {
  final FacebookLiveVideo live;

  const _LiveActions({required this.live});

  @override
  Widget build(BuildContext context) {
    if (live.isLive) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Voir les commentaires'),
              onPressed: () {
                // TODO: Navigate to comments
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Refresh live data
            },
            tooltip: 'Rafraîchir',
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Analytiques'),
            onPressed: () {
              // TODO: Show analytics
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.content_copy),
            label: const Text('Copier'),
            onPressed: () {
              // TODO: Copy live data
            },
          ),
        ),
      ],
    );
  }
}
