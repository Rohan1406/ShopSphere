import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _logout(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final favoritesCount = ref.watch(favoritesProvider).length;
    final isLoggingOut = authState is AuthLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: isLoggingOut ? null : () => _logout(ref),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.surface,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Demo Shopper',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'demo@shopsphere.com',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.amberLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: AppColors.amber,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'VIP Gold Member',
                                  style: TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Activity stats cards
              Row(
                children: [
                  _buildStatItem('Orders', '12', Icons.receipt_long_rounded, AppColors.primary),
                  const SizedBox(width: 10),
                  _buildStatItem('Wishlist', '$favoritesCount', Icons.favorite_rounded, AppColors.secondary),
                  const SizedBox(width: 10),
                  _buildStatItem('Coupons', '3', Icons.local_offer_rounded, AppColors.amber),
                ],
              ),

              const SizedBox(height: 16),

              // Active Delivery Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #SHP-9812 on the way',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Estimated delivery: Tomorrow by 6 PM',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Menu Section 1: Account
              _buildMenuSection(
                title: 'Account Settings',
                items: [
                  _MenuItem(
                    icon: Icons.shopping_bag_rounded,
                    iconColor: AppColors.primary,
                    title: 'My Orders',
                    subtitle: 'Track, view, and reorder past purchases',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Shipping Addresses',
                    subtitle: 'Manage saved delivery addresses',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.credit_card_rounded,
                    iconColor: AppColors.accent,
                    title: 'Payment Methods',
                    subtitle: 'Saved credit cards & UPI options',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Menu Section 2: Preferences
              _buildMenuSection(
                title: 'Preferences & Support',
                items: [
                  _MenuItem(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppColors.amber,
                    title: 'Push Notifications',
                    subtitle: 'Order updates and promotional offers',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.success,
                    title: 'Customer Support',
                    subtitle: '24/7 Live chat & FAQ help center',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.security_rounded,
                    iconColor: AppColors.primaryDark,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your data and active sessions',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: isLoggingOut ? null : () => _logout(ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.error,
                            ),
                          ),
                        )
                      : const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: item.iconColor),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
              onTap: item.onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

