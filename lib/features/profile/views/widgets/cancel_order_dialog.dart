import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';

class CancelOrderDialog extends ConsumerWidget {
  final String orderId;

  const CancelOrderDialog({super.key, required this.orderId});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => CancelOrderDialog(orderId: orderId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('Cancel Order?'),
        ],
      ),
      content: const Text(
        'Are you sure you want to cancel this order? Any payment made will be refunded to your original payment method.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep Order'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            final success = ref
                .read(ordersControllerProvider.notifier)
                .cancelOrder(orderId);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Order cancelled successfully. Refund initiated.',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Cancel'),
        ),
      ],
    );
  }
}
