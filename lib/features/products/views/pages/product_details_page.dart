import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/views/widgets/product_card.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(productDetailsControllerProvider(widget.productId).notifier)
          .fetchProduct();
    });
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreasedQuantity() {
    if (_quantity <= 1) {
      return;
    }
    setState(() {
      _quantity--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsControllerProvider(widget.productId));
    final relatedProducts = ref.watch(relatedProductsProvider(widget.productId));

    return Scaffold(
      body: switch (state) {
        ProductDetailsInitial() => const SizedBox.shrink(),
        ProductDetailsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        ProductDetailsLoaded(:final product) => _ProductDetailsContent(
          product: product,
          quantity: _quantity,
          relatedProducts: relatedProducts,
          onDecrease: _decreasedQuantity,
          onIncrease: _increaseQuantity,
          onAddToCart: () {
            ref.read(cartControllerProvider.notifier).addProduct(product, quantity: _quantity);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added $_quantity x "${product.title}" to cart!'),
                action: SnackBarAction(
                  label: 'View Cart',
                  onPressed: () => context.push('/cart'),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        ProductDetailsError(:final failure) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failure.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(
                          productDetailsControllerProvider(
                            widget.productId,
                          ).notifier,
                        )
                        .fetchProduct();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  const _ProductDetailsContent({
    required this.product,
    required this.quantity,
    required this.relatedProducts,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final List<Product> relatedProducts;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAddToCart;

  IconData _getCategoryIcon(String catName) {
    return switch (catName.toLowerCase()) {
      'electronics' => Icons.devices_rounded,
      'fashion' => Icons.checkroom_rounded,
      'footwear' => Icons.directions_run_rounded,
      'accessories' => Icons.watch_rounded,
      'lifestyle' => Icons.local_cafe_rounded,
      _ => Icons.category_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 380,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton.filledTonal(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filledTonal(
                onPressed: () {},
                tooltip: 'Favorite',
                icon: const Icon(Icons.favorite_border),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: Colors.white,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Category Pill
              if (product.category.isNotEmpty && product.category != 'general') ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(product.category),
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Title
              Text(
                product.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Rating and Reviews
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '124 reviews',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price
              Text(
                '₹${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),

              // Description Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Quantity Selector
              Text(
                'Quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _QuantitySelector(
                quantity: quantity,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
              const SizedBox(height: 32),

              // Add to Cart Button
              SizedBox(
                height: 56,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // Related Products in same Category
              if (relatedProducts.isNotEmpty) ...[
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More in ${product.category[0].toUpperCase()}${product.category.substring(1)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/products?category=${product.category}'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: relatedProducts
                      .take(3)
                      .map((relProduct) => ProductCard(product: relProduct))
                      .toList(),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: quantity > 1 ? onDecrease : null,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 16),
        Text(
          '$quantity',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          onPressed: onIncrease,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
