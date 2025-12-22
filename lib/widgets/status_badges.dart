import 'package:flutter/material.dart';
import '../models/delivery_model.dart';

class StatusBadge extends StatelessWidget {
  final DeliveryStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.getColor(), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.getIcon(), size: 14, color: status.getColor()),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.getColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
