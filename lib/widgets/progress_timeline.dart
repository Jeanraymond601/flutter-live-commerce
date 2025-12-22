import 'package:flutter/material.dart';
import '../models/delivery_model.dart';

class ProgressTimeline extends StatelessWidget {
  final List<DeliveryStep> steps;

  const ProgressTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suivi de livraison',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: step.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : step.isCurrent
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.surfaceVariant,
                        border: Border.all(
                          color: step.isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : step.isCurrent
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          step.isCompleted
                              ? Icons.check
                              : step.isCurrent
                              ? Icons.local_shipping
                              : Icons.circle,
                          size: 16,
                          color: step.isCompleted || step.isCurrent
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: step.isCurrent
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: step.isCurrent
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (step.date != null)
                      Text(
                        '${step.date!.day}/${step.date!.month}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(steps.length - 1, (index) {
                final step1 = steps[index];
                final step2 = steps[index + 1];
                final isCompleted = step1.isCompleted && step2.isCompleted;

                return Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
