import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/views/widgets/active_delivery_tracker_card.dart';
import 'package:shopsphere/features/profile/views/widgets/logout_dialog.dart';
import 'package:shopsphere/features/profile/views/widgets/profile_header_card.dart';
import 'package:shopsphere/features/profile/views/widgets/profile_menu_section.dart';
import 'package:shopsphere/features/profile/views/widgets/profile_stats_row.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await LogoutConfirmDialog.show(context);
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = ref.watch(userProfileControllerProvider);
    final orders = ref.watch(ordersControllerProvider);
    final coupons = ref.watch(couponsControllerProvider);
    final favoritesCount = ref.watch(favoritesProvider).length;
    final latestActiveOrder = ref.watch(latestActiveOrderProvider);
    final isLoggingOut = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: isLoggingOut ? null : () => _logout(context, ref),
            tooltip: 'Logout',
            icon: isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // VIP User Info Card
              ProfileHeaderCard(profile: profile),

              const SizedBox(height: 14),

              // Activity stats cards (Clickable)
              ProfileStatsRow(
                ordersCount: orders.length,
                favoritesCount: favoritesCount,
                couponsCount: coupons.length,
              ),

              const SizedBox(height: 16),

              // Active Delivery Banner
              if (latestActiveOrder != null) ...[
                ActiveDeliveryTrackerCard(order: latestActiveOrder),
                const SizedBox(height: 20),
              ],

              // Section 1: Orders & Commerce
              ProfileMenuSection(
                title: 'ORDERS & PAYMENTS',
                children: [
                  ProfileMenuTile(
                    icon: Icons.local_shipping_outlined,
                    iconColor: AppColors.primary,
                    title: 'My Orders',
                    subtitle: 'Track, return, or reorder purchased items',
                    badge: '${orders.length}',
                    onTap: () => context.push('/profile/orders'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.location_on_outlined,
                    iconColor: AppColors.accent,
                    title: 'Shipping Addresses',
                    subtitle: 'Manage home, work, and delivery points',
                    onTap: () => context.push('/profile/addresses'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.credit_card_outlined,
                    iconColor: AppColors.secondary,
                    title: 'Payment Methods',
                    subtitle: 'Cards, UPI VPAs, and saved gateways',
                    showDivider: false,
                    onTap: () => context.push('/profile/payments'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Section 2: Preferences & Perks
              ProfileMenuSection(
                title: 'PERKS & PREFERENCES',
                children: [
                  ProfileMenuTile(
                    icon: Icons.local_offer_outlined,
                    iconColor: AppColors.amber,
                    title: 'Coupons & Vouchers',
                    subtitle:
                        'VIP vouchers and ${profile.points} loyalty points',
                    badge: '${coupons.length} Active',
                    onTap: () => context.push('/profile/coupons'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.favorite_border_rounded,
                    iconColor: AppColors.secondary,
                    title: 'My Wishlist',
                    subtitle: 'Saved favorites and curated items',
                    badge: '$favoritesCount',
                    onTap: () => context.push('/profile/wishlist'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.info,
                    title: 'Push Notifications',
                    subtitle: 'Order tracking and flash sale alerts',
                    showDivider: false,
                    onTap: () => context.push('/profile/notifications'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Section 3: Support & Legal
              ProfileMenuSection(
                title: 'SUPPORT & SECURITY',
                children: [
                  ProfileMenuTile(
                    icon: Icons.headset_mic_outlined,
                    iconColor: AppColors.primary,
                    title: 'Customer Support',
                    subtitle: 'Live Concierge, FAQs, and ticket desk',
                    onTap: () => context.push('/profile/support'),
                  ),
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Privacy & Security',
                    subtitle: '2FA, active sessions, and password',
                    showDivider: false,
                    onTap: () => context.push('/profile/privacy'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Action Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoggingOut ? null : () => _logout(context, ref),
                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                  label: Text(
                    isLoggingOut ? 'Logging out...' : 'Logout',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
