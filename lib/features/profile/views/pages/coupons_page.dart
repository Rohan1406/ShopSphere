import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/views/widgets/coupon_claim_input_card.dart';
import 'package:shopsphere/features/profile/views/widgets/coupon_voucher_card.dart';
import 'package:shopsphere/features/profile/views/widgets/reward_points_card.dart';

class CouponsPage extends ConsumerStatefulWidget {
  const CouponsPage({super.key});

  @override
  ConsumerState<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends ConsumerState<CouponsPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _claimCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final success = ref
        .read(couponsControllerProvider.notifier)
        .claimCoupon(code);
    if (success) {
      _codeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon code $code claimed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon code $code is already in your rewards!'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupons = ref.watch(couponsControllerProvider);
    final profile = ref.watch(userProfileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Coupons & Rewards')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VIP Rewards Points Banner
            RewardPointsCard(points: profile.points),
            const SizedBox(height: 20),

            // Enter promo code input
            CouponClaimInputCard(
              controller: _codeController,
              onClaim: _claimCode,
            ),
            const SizedBox(height: 20),

            Text(
              'Available Coupons (${coupons.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...coupons.map((coupon) => CouponVoucherCard(coupon: coupon)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
