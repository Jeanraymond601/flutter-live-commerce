import 'dart:async';
import 'package:flutter/material.dart';

class NotificationMessage {
  final String title;
  final String body;
  final DateTime receivedAt;

  NotificationMessage({
    required this.title,
    required this.body,
    required this.receivedAt,
  });
}

class NotificationService extends ChangeNotifier {
  final StreamController<NotificationMessage> _messageStreamController =
      StreamController.broadcast();

  Stream<NotificationMessage> get messages => _messageStreamController.stream;

  NotificationService() {
    _init();
  }

  Future<void> _init() async {}

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}
