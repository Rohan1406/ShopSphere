import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/models/order.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final Order order;

  const OrderTrackingTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final firstIncompleteIndex = order.trackingSteps.indexWhere(
      (s) => !s.isCompleted,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Tracking Timeline',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'TRK: ${order.trackingNumber}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(order.trackingSteps.length, (index) {
            final step = order.trackingSteps[index];
            final isLast = index == order.trackingSteps.length - 1;
            final isCurrent = index == firstIncompleteIndex;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step icon & vertical line
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: step.isCompleted
                            ? AppColors.success
                            : (isCurrent
                                  ? AppColors.primary
                                  : AppColors.surfaceSubtle),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: step.isCompleted || isCurrent
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        step.isCompleted
                            ? Icons.check_rounded
                            : (isCurrent
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.circle_outlined),
                        size: 15,
                        color: step.isCompleted || isCurrent
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: step.isCompleted
                            ? AppColors.success
                            : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Step details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: step.isCompleted || isCurrent
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                            if (step.timestamp.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                step.timestamp,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: step.isCompleted || isCurrent
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
