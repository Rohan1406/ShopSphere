import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

class UpiPaymentTile extends ConsumerWidget {
  final UpiPayment upi;

  const UpiPaymentTile({super.key, required this.upi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.account_balance_wallet_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            upi.upiId,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          if (upi.isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DEFAULT',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        upi.providerName,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, size: 18),
        onSelected: (val) {
          if (val == 'default') {
            ref
                .read(paymentMethodsControllerProvider.notifier)
                .setDefaultUpi(upi.id);
          } else if (val == 'delete') {
            ref
                .read(paymentMethodsControllerProvider.notifier)
                .deleteUpi(upi.id);
          }
        },
        itemBuilder: (_) => [
          if (!upi.isDefault)
            const PopupMenuItem(
              value: 'default',
              child: Text('Set as Default'),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Text(
              'Delete UPI ID',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
