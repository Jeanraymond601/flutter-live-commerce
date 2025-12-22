// lib/widgets/posts_feed_section.dart
import 'package:flutter/material.dart';
import 'package:commerce/models/facebook_models.dart';

class PostsFeedSection extends StatelessWidget {
  const PostsFeedSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from provider
    final List<FacebookPost> posts = [];

    if (posts.isEmpty) {
      return const _NoPosts();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PostsHeader(posts: posts),
        const SizedBox(height: 16),
        ...posts.map((post) => _PostCard(post: post)),
      ],
    );
  }
}

class _NoPosts extends StatelessWidget {
  const _NoPosts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.post_add, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune publication',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Les publications de votre page Facebook apparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Synchroniser les publications'),
              onPressed: () {
                // TODO: Sync posts
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsHeader extends StatelessWidget {
  final List<FacebookPost> posts;

  const _PostsHeader({required this.posts});

  @override
  Widget build(BuildContext context) {
    final totalPosts = posts.length;
    final livePosts = posts.where((post) => post.isLiveCommerce).length;
    final totalLikes = posts.fold<int>(0, (sum, post) => sum + post.likesCount);
    final totalComments = posts.fold<int>(
      0,
      (sum, post) => sum + post.commentsCount,
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
                  'Publications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Synchroniser'),
                      onPressed: () {
                        // TODO: Sync posts
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                      tooltip: 'Filtrer',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeaderStat(
                  value: totalPosts.toString(),
                  label: 'Publications',
                  icon: Icons.article,
                ),
                _HeaderStat(
                  value: livePosts.toString(),
                  label: 'Live Commerce',
                  icon: Icons.live_tv,
                ),
                _HeaderStat(
                  value: totalLikes.toString(),
                  label: 'J\'aime',
                  icon: Icons.favorite,
                ),
                _HeaderStat(
                  value: totalComments.toString(),
                  label: 'Commentaires',
                  icon: Icons.comment,
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
          title: const Text('Filtrer les publications'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Live Commerce seulement'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('Publications populaires'),
                  subtitle: const Text('Plus de 50 commentaires'),
                  value: false,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                const Text('Date de publication'),
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

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final FacebookPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (post.pictureUrl != null && post.pictureUrl!.isNotEmpty)
            Image.network(
              post.pictureUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (post.isLiveCommerce)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      post.formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.truncatedMessage,
                  style: const TextStyle(fontSize: 14),
                ),
                if (post.message != null && post.message!.length > 100) ...[
                  TextButton(
                    onPressed: () {
                      _showFullMessage(context, post.message!);
                    },
                    child: const Text('Voir plus'),
                  ),
                ],
                const SizedBox(height: 16),
                _PostStats(post: post),
                const SizedBox(height: 16),
                _PostActions(post: post),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message complet'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

class _PostStats extends StatelessWidget {
  final FacebookPost post;

  const _PostStats({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.favorite,
          value: post.likesCount.toString(),
          label: 'J\'aime',
          color: Colors.red,
        ),
        _StatItem(
          icon: Icons.comment,
          value: post.commentsCount.toString(),
          label: 'Commentaires',
          color: Colors.blue,
        ),
        _StatItem(
          icon: Icons.share,
          value: post.sharesCount.toString(),
          label: 'Partages',
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _PostActions extends StatelessWidget {
  final FacebookPost post;

  const _PostActions({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('Voir sur Facebook'),
            onPressed: () {
              _openFacebookPost(context, post.postId);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text('Gérer commentaires'),
            onPressed: () {
              _manageComments(context, post.postId);
            },
          ),
        ),
      ],
    );
  }

  void _openFacebookPost(BuildContext context, String postId) {
    // TODO: Open Facebook post URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de la publication $postId...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _manageComments(BuildContext context, String postId) {
    // TODO: Navigate to comments management for this post
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion des commentaires pour $postId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
