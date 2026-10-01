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
    final relatedProducts = ref.watch(
      relatedProductsProvider(widget.productId),
    );
    final isFavorite = ref.watch(favoritesProvider).contains(widget.productId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (state) {
        ProductDetailsInitial() => const SizedBox.shrink(),
        ProductDetailsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        ProductDetailsLoaded(:final product) => _ProductDetailsContent(
          product: product,
          quantity: _quantity,
          isFavorite: isFavorite,
          relatedProducts: relatedProducts,
          onFavoriteToggle: () {
            ref
                .read(favoritesProvider.notifier)
                .toggleFavorite(widget.productId);
          },
          onDecrease: _decreasedQuantity,
          onIncrease: _increaseQuantity,
          onAddToCart: () {
            ref
                .read(cartControllerProvider.notifier)
                .addProduct(product, quantity: _quantity);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added $_quantity x "${product.title}" to cart!'),
                action: SnackBarAction(
                  label: 'Go to Cart',
                  textColor: AppColors.amber,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.go('/cart');
                  },
                ),
                duration: const Duration(seconds: 3),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 14),
                Text(failure.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          productDetailsControllerProvider(
                            widget.productId,
                          ).notifier,
                        )
                        .fetchProduct();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
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
    required this.isFavorite,
    required this.relatedProducts,
    required this.onFavoriteToggle,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddToCart,
  });

  final Product product;
  final int quantity;
  final bool isFavorite;
  final List<Product> relatedProducts;
  final VoidCallback onFavoriteToggle;
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
    final originalPrice = product.price * 1.25;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 360,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                child: IconButton(
                  onPressed: onFavoriteToggle,
                  tooltip: 'Favorite',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: AppColors.textMuted,
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Category Pill & Rating Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (product.category.isNotEmpty &&
                      product.category != 'general') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
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
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amberLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '4.8 (124 reviews)',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                product.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              // Price Row with Savings Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹${originalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '20% OFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Trust & Highlights Grid
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(
                      Icons.local_shipping_outlined,
                      'Free Delivery',
                    ),
                    _buildFeatureDivider(),
                    _buildFeatureItem(
                      Icons.verified_user_outlined,
                      '1-Yr Warranty',
                    ),
                    _buildFeatureDivider(),
                    _buildFeatureItem(Icons.autorenew_rounded, '7-Day Return'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Description Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  _QuantitySelector(
                    quantity: quantity,
                    onDecrease: onDecrease,
                    onIncrease: onIncrease,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Add to Cart Button
              SizedBox(
                height: 54,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              // Related Products in same Category
              if (relatedProducts.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'More in ${product.category[0].toUpperCase()}${product.category.substring(1)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(
                        '/products?category=${product.category}',
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureDivider() {
    return Container(height: 24, width: 1, color: AppColors.border);
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: quantity > 1 ? onDecrease : null,
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onIncrease,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
