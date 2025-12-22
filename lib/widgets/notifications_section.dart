// lib/widgets/notifications_section.dart
import 'package:flutter/material.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from provider
    final List<Map<String, dynamic>> notifications = [];

    if (notifications.isEmpty) {
      return const _NoNotifications();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NotificationsHeader(notificationCount: notifications.length),
        const SizedBox(height: 12),
        ...notifications.map(
          (notification) => _NotificationCard(notification: notification),
        ),
      ],
    );
  }
}

class _NoNotifications extends StatelessWidget {
  const _NoNotifications();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Toutes les notifications sont à jour',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: Force check for notifications
              },
              child: const Text('Vérifier les notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final int notificationCount;

  const _NotificationsHeader({required this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Badge.count(
          count: notificationCount,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          largeSize: 24,
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show all notifications
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final type = notification['type'] ?? 'info';
    final title = notification['title'] ?? 'Notification';
    final message = notification['message'] ?? '';
    final time = notification['time'] ?? DateTime.now();
    final isUnread = notification['unread'] ?? false;

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'success':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'warning':
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'error':
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case 'order':
        icon = Icons.shopping_cart;
        iconColor = Colors.blue;
        break;
      case 'comment':
        icon = Icons.comment;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnread ? Colors.blue[50] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          // TODO: Handle notification tap
        },
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time is DateTime) {
      final now = DateTime.now();
      final difference = now.difference(time);

      if (difference.inMinutes < 1) return 'À l\'instant';
      if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} min';
      }
      if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
      if (difference.inDays < 30) return 'Il y a ${difference.inDays} j';

      return '${time.day}/${time.month}/${time.year}';
    }
    return 'Récemment';
  }
}
