import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/views/widgets/notification_section_card.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsControllerProvider);
    final notifier = ref.read(notificationSettingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Push Notifications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Orders & Delivery
            NotificationSectionCard(
              title: 'Orders & Delivery Alerts',
              children: [
                NotificationSwitchTile(
                  icon: Icons.local_shipping_rounded,
                  iconColor: AppColors.primary,
                  title: 'Order Status Updates',
                  subtitle:
                      'Real-time notifications when order is packed, shipped, and out for delivery',
                  value: settings.orderUpdates,
                  onChanged: notifier.toggleOrderUpdates,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                NotificationSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: AppColors.info,
                  title: 'Doorstep Delivery ETA',
                  subtitle:
                      'Instant alerts when delivery courier is arriving near your address',
                  value: settings.deliveryAlerts,
                  onChanged: notifier.toggleDeliveryAlerts,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Sales & Promotions
            NotificationSectionCard(
              title: 'Offers & Promotions',
              children: [
                NotificationSwitchTile(
                  icon: Icons.local_offer_rounded,
                  iconColor: AppColors.amber,
                  title: 'Promotional Offers & Sales',
                  subtitle:
                      'Get notified about seasonal mega sales, flash discounts, and promo codes',
                  value: settings.promotionalOffers,
                  onChanged: notifier.togglePromotionalOffers,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                NotificationSwitchTile(
                  icon: Icons.trending_down_rounded,
                  iconColor: AppColors.secondary,
                  title: 'Price Drop Alerts',
                  subtitle:
                      'Receive alerts when items in your Wishlist go on sale',
                  value: settings.priceDropAlerts,
                  onChanged: notifier.togglePriceDropAlerts,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                NotificationSwitchTile(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.primaryDark,
                  title: 'VIP Exclusive Perks',
                  subtitle:
                      'Early access passes to member-only drops and double reward days',
                  value: settings.exclusiveDeals,
                  onChanged: notifier.toggleExclusiveDeals,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Notification Channels
            NotificationSectionCard(
              title: 'Preferred Channels',
              children: [
                NotificationSwitchTile(
                  icon: Icons.sms_rounded,
                  iconColor: AppColors.success,
                  title: 'SMS Alerts',
                  subtitle:
                      'Critical OTP verification codes and dispatch confirmation via text message',
                  value: settings.smsUpdates,
                  onChanged: notifier.toggleSmsUpdates,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                NotificationSwitchTile(
                  icon: Icons.chat_rounded,
                  iconColor: AppColors.success,
                  title: 'WhatsApp Notifications',
                  subtitle:
                      'Order receipts and customer care support updates over WhatsApp',
                  value: settings.whatsappAlerts,
                  onChanged: notifier.toggleWhatsappAlerts,
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                NotificationSwitchTile(
                  icon: Icons.email_rounded,
                  iconColor: AppColors.accent,
                  title: 'Email Newsletter',
                  subtitle:
                      'Weekly curation of trending fashion and new tech releases',
                  value: settings.newsletter,
                  onChanged: notifier.toggleNewsletter,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
