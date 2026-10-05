import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

class CheckoutStepper extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const CheckoutStepper({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    const steps = [
      {
        'title': 'Address',
        'subtitle': 'Delivery',
        'icon': Icons.location_on_rounded,
      },
      {'title': 'Payment', 'subtitle': 'Method', 'icon': Icons.payment_rounded},
      {
        'title': 'Summary',
        'subtitle': 'Review',
        'icon': Icons.receipt_long_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              flex: 3,
              child: _StepItem(
                index: i,
                title: steps[i]['title'] as String,
                subtitle: steps[i]['subtitle'] as String,
                icon: steps[i]['icon'] as IconData,
                isActive: currentStep == i,
                isCompleted: currentStep > i,
                onTap: () {
                  if (i <= currentStep && onStepTapped != null) {
                    onStepTapped!(i);
                  }
                },
              ),
            ),
            if (i < steps.length - 1)
              Expanded(
                flex: 2,
                child: _StepConnector(isCompleted: currentStep > i),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const _StepItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeFg;
    Color titleColor;

    if (isCompleted) {
      badgeBg = AppColors.success;
      badgeFg = Colors.white;
      titleColor = AppColors.textPrimary;
    } else if (isActive) {
      badgeBg = AppColors.primary;
      badgeFg = Colors.white;
      titleColor = AppColors.primary;
    } else {
      badgeBg = AppColors.surfaceSubtle;
      badgeFg = AppColors.textMuted;
      titleColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: badgeFg,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isCompleted;

  const _StepConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 22, left: 4, right: 4),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
