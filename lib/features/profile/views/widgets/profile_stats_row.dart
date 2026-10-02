import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

class ProfileStatsRow extends StatelessWidget {
  final int ordersCount;
  final int favoritesCount;
  final int couponsCount;

  const ProfileStatsRow({
    super.key,
    required this.ordersCount,
    required this.favoritesCount,
    required this.couponsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          label: 'Orders',
          value: '$ordersCount',
          icon: Icons.receipt_long_rounded,
          color: AppColors.primary,
          onTap: () => context.push('/profile/orders'),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          label: 'Wishlist',
          value: '$favoritesCount',
          icon: Icons.favorite_rounded,
          color: AppColors.secondary,
          onTap: () => context.push('/profile/wishlist'),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          label: 'Coupons',
          value: '$couponsCount',
          icon: Icons.local_offer_rounded,
          color: AppColors.amber,
          onTap: () => context.push('/profile/coupons'),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
