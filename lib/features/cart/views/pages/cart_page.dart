import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo([String? codeOverride]) {
    final code = codeOverride ?? _promoController.text;
    final success = ref.read(cartControllerProvider.notifier).applyPromo(code);

    if (success) {
      final applied = ref.read(cartControllerProvider).appliedPromo;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo $applied applied successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code. Try TECH40 or STYLE20'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cartState.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                ref.read(cartControllerProvider.notifier).clearCart();
              },
            ),
        ],
      ),
      body: cartState.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your cart is empty',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Looks like you haven\'t added anything to your cart yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/products'),
                      icon: const Icon(Icons.explore_outlined, size: 18),
                      label: const Text(
                        'Explore Catalog',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Top Free Shipping Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppColors.successSurface,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '🎉 Free Express Delivery unlocked!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Items list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const ColoredBox(
                                        color: AppColors.surfaceSubtle,
                                        child: Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppColors.textMuted,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: AppColors.textPrimary,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '₹${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      // Quantity Stepper
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                ref
                                                    .read(
                                                      cartControllerProvider
                                                          .notifier,
                                                    )
                                                    .decrementQuantity(item.id);
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(
                                                  Icons.remove_rounded,
                                                  size: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                ref
                                                    .read(
                                                      cartControllerProvider
                                                          .notifier,
                                                    )
                                                    .incrementQuantity(item.id);
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: const Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  size: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(
                                                cartControllerProvider.notifier,
                                              )
                                              .removeItem(item.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Promo code and summary bottom container
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Coupon Suggestion Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text(
                                'Coupons:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  _promoController.text = 'TECH40';
                                  _applyPromo('TECH40');
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save 40% (TECH40)',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  _promoController.text = 'STYLE20';
                                  _applyPromo('STYLE20');
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save 20% (STYLE20)',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Promo Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Promo Code (e.g. TECH40)',
                                  prefixIcon: const Icon(
                                    Icons.local_offer_outlined,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: _applyPromo,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        if (cartState.appliedPromo != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cartState.appliedPromo!,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Pricing Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              '₹${cartState.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (cartState.discountPercent > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Discount',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                '-₹${cartState.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              'FREE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: AppColors.border),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '₹${cartState.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(cartControllerProvider.notifier)
                                  .clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '🎉 Order placed successfully! Thank you for shopping.',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
