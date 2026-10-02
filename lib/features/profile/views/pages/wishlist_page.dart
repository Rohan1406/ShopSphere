import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/profile/views/widgets/empty_wishlist_view.dart';
import 'package:shopsphere/features/profile/views/widgets/wishlist_product_card.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final productState = ref.watch(productControllerProvider);

    final List<Product> allProducts = switch (productState) {
      ProductLoaded(:final products) => products,
      _ => DummyData.products,
    };

    final favoriteProducts = allProducts
        .where((product) => favoriteIds.contains(product.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Wishlist (${favoriteProducts.length})'),
        actions: [
          if (favoriteProducts.isNotEmpty)
            TextButton(
              onPressed: () {
                final cartNotifier = ref.read(cartControllerProvider.notifier);
                for (final prod in favoriteProducts) {
                  cartNotifier.addProduct(prod);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added ${favoriteProducts.length} items to your cart!',
                    ),
                    backgroundColor: AppColors.primary,
                    action: SnackBarAction(
                      label: 'GO TO CART',
                      textColor: Colors.white,
                      onPressed: () => context.go('/cart'),
                    ),
                  ),
                );
              },
              child: const Text(
                'Add All to Cart',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: favoriteProducts.isEmpty
          ? const EmptyWishlistView()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return WishlistProductCard(product: product);
              },
            ),
    );
  }
}
