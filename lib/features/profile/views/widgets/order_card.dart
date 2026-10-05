import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/order.dart';

class OrderCard extends ConsumerWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/profile/orders/${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID, Date, and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(order.orderDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.status.icon,
                            size: 13,
                            color: order.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status.displayName,
                            style: TextStyle(
                              color: order.status.color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),

                // Order items preview
                Row(
                  children: [
                    // Item thumbnail list
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: order.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final item = order.items[i];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surfaceSubtle,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 20,
                                        color: AppColors.textMuted,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${order.totalItemCount} item${order.totalItemCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ETA or Status subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.status == OrderStatus.delivered
                            ? Icons.task_alt_rounded
                            : Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.estimatedDelivery,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.push('/profile/orders/${order.id}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final count = ref
                              .read(ordersControllerProvider.notifier)
                              .reorder(order.id, ref);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$count items added to your cart!'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: Colors.white,
                                onPressed: () => context.go('/cart'),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 15),
                        label: const Text('Reorder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primarySurface,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
