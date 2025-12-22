// lib/widgets/status_indicator.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatusIndicator extends StatelessWidget {
  final String status;
  final bool isActive;
  final bool isAvailable;
  final bool showLabel;
  final bool compact;
  final double size;
  final VoidCallback? onTap;

  const StatusIndicator({
    super.key,
    required this.status,
    this.isActive = true,
    this.isAvailable = true,
    this.showLabel = true,
    this.compact = false,
    this.size = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);

    if (compact) {
      return _buildCompactIndicator(statusData, context);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusData.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: statusData.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusData.icon, size: 16, color: statusData.color),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                statusData.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusData.color,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.elasticOut);
  }

  Widget _buildCompactIndicator(StatusData statusData, BuildContext context) {
    return Tooltip(
      message: statusData.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: statusData.color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: statusData.color.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            statusData.icon,
            size: size * 0.6,
            color: statusData.color,
          ),
        ),
      ),
    );
  }

  StatusData _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return StatusData(
          label: 'Actif',
          icon: Icons.check_circle,
          color: const Color(0xFF4CAF50),
          description: 'Livreur actif et opérationnel',
        );
      case 'en_attente':
        return StatusData(
          label: 'En attente',
          icon: Icons.access_time,
          color: const Color(0xFFFF9800),
          description: 'En attente de validation',
        );
      case 'suspendu':
        return StatusData(
          label: 'Suspendu',
          icon: Icons.pause_circle,
          color: const Color(0xFFF44336),
          description: 'Livreur temporairement suspendu',
        );
      case 'rejeté':
        return StatusData(
          label: 'Rejeté',
          icon: Icons.cancel,
          color: const Color(0xFF9E9E9E),
          description: 'Candidature rejetée',
        );
      case 'disponible':
        return StatusData(
          label: 'Disponible',
          icon: Icons.check,
          color: const Color(0xFF4CAF50),
          description: 'Disponible pour livraison',
        );
      case 'indisponible':
        return StatusData(
          label: 'Indisponible',
          icon: Icons.close,
          color: const Color(0xFFF44336),
          description: 'Non disponible pour le moment',
        );
      default:
        return StatusData(
          label: 'Inconnu',
          icon: Icons.help,
          color: const Color(0xFF2196F3),
          description: 'Statut non défini',
        );
    }
  }
}

class StatusData {
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const StatusData({
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Indicateur de disponibilité avec animation
class AvailabilityIndicator extends StatefulWidget {
  final bool isAvailable;
  final bool showLabel;
  final bool animate;
  final double size;

  const AvailabilityIndicator({
    super.key,
    required this.isAvailable,
    this.showLabel = true,
    this.animate = true,
    this.size = 24.0,
  });

  @override
  State<AvailabilityIndicator> createState() => _AvailabilityIndicatorState();
}

class _AvailabilityIndicatorState extends State<AvailabilityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.animate && widget.isAvailable) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isAvailable ? Colors.green : Colors.red;
    final icon = widget.isAvailable ? Icons.check_circle : Icons.cancel;
    final label = widget.isAvailable ? 'Disponible' : 'Indisponible';

    return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Center(
                child: Icon(icon, size: widget.size * 0.6, color: color),
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        )
        .animate(autoPlay: widget.animate && widget.isAvailable)
        .shake(hz: 2, curve: Curves.easeInOut, duration: 1000.ms);
  }
}

// Badge de statut circulaire
class StatusBadge extends StatelessWidget {
  final String status;
  final double size;
  final bool showTooltip;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = 16.0,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _getStatusData(status);

    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusData.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size > 20 ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: statusData.color.withOpacity(0.5),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    if (showTooltip) {
      badge = Tooltip(message: statusData.label, child: badge);
    }

    return badge.animate().scale(duration: 300.ms, curve: Curves.elasticOut);
  }

  StatusData _getStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return StatusData(
          label: 'Actif',
          icon: Icons.check_circle,
          color: const Color(0xFF4CAF50),
          description: '',
        );
      case 'en_attente':
        return StatusData(
          label: 'En attente',
          icon: Icons.access_time,
          color: const Color(0xFFFF9800),
          description: '',
        );
      case 'suspendu':
        return StatusData(
          label: 'Suspendu',
          icon: Icons.pause_circle,
          color: const Color(0xFFF44336),
          description: '',
        );
      case 'rejeté':
        return StatusData(
          label: 'Rejeté',
          icon: Icons.cancel,
          color: const Color(0xFF9E9E9E),
          description: '',
        );
      default:
        return StatusData(
          label: 'Inconnu',
          icon: Icons.help,
          color: const Color(0xFF2196F3),
          description: '',
        );
    }
  }
}

// Barre de progression de statut
class StatusProgressBar extends StatelessWidget {
  final String currentStatus;
  final List<String> statusFlow;

  const StatusProgressBar({
    super.key,
    required this.currentStatus,
    this.statusFlow = const ['en_attente', 'actif', 'suspendu'],
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = statusFlow.indexOf(currentStatus.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de progression
        SizedBox(
          height: 4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final stepWidth = width / (statusFlow.length - 1);

              return Stack(
                children: [
                  // Ligne de fond
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Progression
                  if (currentIndex >= 0)
                    Container(
                      width: currentIndex * stepWidth,
                      decoration: BoxDecoration(
                        color: _getStatusColor(statusFlow[currentIndex]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  // Points d'étape
                  ...statusFlow.asMap().entries.map((entry) {
                    final index = entry.key;
                    final status = entry.value;
                    final isActive = index <= currentIndex;
                    final isCurrent = index == currentIndex;

                    return Positioned(
                      left: index * stepWidth - 6,
                      top: -4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _getStatusColor(status)
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                          border: isCurrent
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                    // ignore: unnecessary_to_list_in_spreads
                  }).toList(),
                ],
              );
            },
          ),
        ),
        // Labels
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: statusFlow.map((status) {
            return Text(
              _getStatusLabel(status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: statusFlow.indexOf(status) <= currentIndex
                    ? _getStatusColor(status)
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'actif':
        return 'Actif';
      case 'suspendu':
        return 'Suspendu';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return const Color(0xFF4CAF50);
      case 'en_attente':
        return const Color(0xFFFF9800);
      case 'suspendu':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Indicateur de statut avec badge de notification
class StatusWithNotification extends StatelessWidget {
  final String status;
  final int notificationCount;
  final bool showNotification;

  const StatusWithNotification({
    super.key,
    required this.status,
    this.notificationCount = 0,
    this.showNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StatusIndicator(status: status, compact: true, size: 32),
        if (showNotification && notificationCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                notificationCount > 9 ? '9+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
