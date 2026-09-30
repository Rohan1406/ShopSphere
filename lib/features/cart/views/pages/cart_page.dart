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

  void _applyPromo() {
    final code = _promoController.text;
    final success = ref.read(cartControllerProvider.notifier).applyPromo(code);

    if (success) {
      final applied = ref.read(cartControllerProvider).appliedPromo;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Promo $applied applied successfully! 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid promo code. Try TECH40 or STYLE20')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
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
                    const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 72,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Looks like you haven\'t added anything to your cart yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/products'),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Explore Catalog'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                                    color: Colors.black12,
                                    child: SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: Icon(Icons.image_not_supported_outlined),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            ref
                                                .read(cartControllerProvider.notifier)
                                                .decrementQuantity(item.id);
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black26),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.remove, size: 16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            ref
                                                .read(cartControllerProvider.notifier)
                                                .incrementQuantity(item.id);
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black26),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.add, size: 16),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(cartControllerProvider.notifier)
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
                        ),
                      );
                    },
                  ),
                ),

                // Promo code and summary bottom sheet container
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Promo Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Promo Code (e.g. TECH40)',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: _applyPromo,
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                        if (cartState.appliedPromo != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                cartState.appliedPromo!,
                                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                            Text('₹${cartState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (cartState.discountPercent > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Discount', style: TextStyle(color: Colors.green)),
                              Text('-₹${cartState.discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipping', style: TextStyle(color: AppColors.textSecondary)),
                            Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '₹${cartState.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully! Thank you for shopping.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
