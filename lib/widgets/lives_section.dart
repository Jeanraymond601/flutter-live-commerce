// lib/widgets/lives_section.dart
import 'package:flutter/material.dart';
import 'package:commerce/models/facebook_models.dart';

class LivesSection extends StatelessWidget {
  final List<FacebookLiveVideo> lives;
  final VoidCallback? onSyncPressed;
  final VoidCallback? onCreateLivePressed;
  final Function(String videoId)? onViewLiveComments;
  final Function(String videoId)? onViewAnalytics;

  const LivesSection({
    super.key,
    required this.lives,
    this.onSyncPressed,
    this.onCreateLivePressed,
    this.onViewLiveComments,
    this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    if (lives.isEmpty) {
      return _NoLiveVideos(
        onCreateLivePressed: onCreateLivePressed,
        onSyncPressed: onSyncPressed,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LiveHeader(
          lives: lives,
          onCreateLivePressed: onCreateLivePressed,
          onSyncPressed: onSyncPressed,
        ),
        const SizedBox(height: 16),
        ...lives.map(
          (live) => _LiveCard(
            live: live,
            onViewLiveComments: onViewLiveComments,
            onViewAnalytics: onViewAnalytics,
          ),
        ),
      ],
    );
  }
}

class _NoLiveVideos extends StatelessWidget {
  final VoidCallback? onCreateLivePressed;
  final VoidCallback? onSyncPressed;

  const _NoLiveVideos({this.onCreateLivePressed, this.onSyncPressed});

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
              onPressed: onCreateLivePressed,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Synchroniser les lives'),
              onPressed: onSyncPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  final List<FacebookLiveVideo> lives;
  final VoidCallback? onCreateLivePressed;
  final VoidCallback? onSyncPressed;

  const _LiveHeader({
    required this.lives,
    this.onCreateLivePressed,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    final liveCount = lives.length;
    final liveNow = lives.where((live) => live.isLive).length;
    final totalRevenue = lives.fold<double>(
      0,
      (sum, live) => sum + live.totalRevenue,
    );
    final totalComments = lives.fold<int>(
      0,
      (sum, live) => sum + live.totalComments,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Commerce',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onSyncPressed,
                      tooltip: 'Synchroniser',
                    ),
                  ],
                ),
              ],
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
                  value: totalComments.toString(),
                  label: 'Commentaires',
                  icon: Icons.comment,
                  color: Colors.orange,
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
                    onPressed: onCreateLivePressed,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrer'),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les lives'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('En direct seulement'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Lives terminés'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Lives planifiés'),
                  value: false,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                const Text('Date de création'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Depuis',
                          hintText: 'JJ/MM/AAAA',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Jusqu\'à',
                          hintText: 'JJ/MM/AAAA',
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Appliquer'),
            ),
          ],
        );
      },
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
  final Function(String videoId)? onViewLiveComments;
  final Function(String videoId)? onViewAnalytics;

  const _LiveCard({
    required this.live,
    this.onViewLiveComments,
    this.onViewAnalytics,
  });

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        live.title ?? 'Live sans titre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (live.viewersCount > 0)
                        Text(
                          '${live.viewersCount} spectateurs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  live.description!,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (live.actualStartTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${live.actualStartTime!.day}/${live.actualStartTime!.month}/${live.actualStartTime!.year} à ${live.actualStartTime!.hour}:${live.actualStartTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            _LiveStats(live: live),
            const SizedBox(height: 16),
            _LiveActions(
              live: live,
              onViewLiveComments: onViewLiveComments,
              onViewAnalytics: onViewAnalytics,
            ),
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
                if (onViewAnalytics != null) {
                  onViewAnalytics!(live.facebookVideoId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Voir les commentaires'),
              onTap: () {
                Navigator.pop(context);
                if (onViewLiveComments != null) {
                  onViewLiveComments!(live.facebookVideoId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                if (live.permalinkUrl != null &&
                    live.permalinkUrl!.isNotEmpty) {
                  // Copier le lien dans le presse-papier
                  // Clipboard.setData(ClipboardData(text: live.permalinkUrl!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien copié dans le presse-papier'),
                    ),
                  );
                }
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
                  _confirmStopLive(context, live);
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

  void _confirmStopLive(BuildContext context, FacebookLiveVideo live) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terminer le live ?'),
          content: const Text('Voulez-vous vraiment terminer ce live ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement stop live
              },
              child: const Text('Terminer'),
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
    } else if (live.isPublished) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      text = 'PUBLIÉ';
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
          icon: Icons.remove_red_eye,
          value: live.viewersCount.toString(),
          label: 'Spectateurs',
        ),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _LiveActions extends StatelessWidget {
  final FacebookLiveVideo live;
  final Function(String videoId)? onViewLiveComments;
  final Function(String videoId)? onViewAnalytics;

  const _LiveActions({
    required this.live,
    this.onViewLiveComments,
    this.onViewAnalytics,
  });

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
                if (onViewLiveComments != null) {
                  onViewLiveComments!(live.facebookVideoId);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Regarder'),
            onPressed: () {
              if (live.streamUrl != null && live.streamUrl!.isNotEmpty) {
                // Ouvrir le stream
                // launchUrl(Uri.parse(live.streamUrl!));
              }
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text('Commentaires'),
            onPressed: () {
              if (onViewLiveComments != null) {
                onViewLiveComments!(live.facebookVideoId);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Analytiques'),
            onPressed: () {
              if (onViewAnalytics != null) {
                onViewAnalytics!(live.facebookVideoId);
              }
            },
          ),
        ),
      ],
    );
  }
}
