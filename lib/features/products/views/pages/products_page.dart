import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/views/widgets/category_filter_bar.dart';
import 'package:shopsphere/features/products/views/widgets/product_grid_card.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({this.initialCategory, super.key});

  final String? initialCategory;

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    Future.microtask(() {
      if (widget.initialCategory != null &&
          widget.initialCategory!.isNotEmpty) {
        ref
            .read(selectedCategoryProvider.notifier)
            .selectCategory(widget.initialCategory!);
      }
      ref.read(productControllerProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);

    // Calculate category product counts based on currently loaded products
    final allProducts = switch (state) {
      ProductLoaded(:final products) => products,
      _ => DummyData.products,
    };

    final Map<String, int> counts = {
      'all': allProducts.length,
      for (final cat in Category.standardCategories)
        if (cat.id != 'all')
          cat.id: allProducts
              .where((p) => p.category.toLowerCase() == cat.id.toLowerCase())
              .length,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          if (selectedCategory != 'all' || searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(productSearchQueryProvider.notifier).clear();
                ref
                    .read(selectedCategoryProvider.notifier)
                    .selectCategory('all');
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Container
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products or category...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productSearchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (val) {
                ref.read(productSearchQueryProvider.notifier).updateQuery(val);
              },
            ),
          ),

          // Categories Horizontal Filter Bar
          CategoryFilterBar(
            selectedCategoryId: selectedCategory,
            itemCounts: counts,
            onCategorySelected: (catId) {
              ref.read(selectedCategoryProvider.notifier).selectCategory(catId);
            },
          ),

          const SizedBox(height: 8),

          // Filter Summary Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == 'all'
                        ? 'Showing all items (${filteredProducts.length})'
                        : 'Category: ${selectedCategory.toUpperCase()} (${filteredProducts.length})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    Text(
                      'Search: "$searchQuery"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Verified Items',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),

          // Main Product List or States
          Expanded(
            child: switch (state) {
              ProductInitial() => const SizedBox.shrink(),
              ProductLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              ProductLoaded() =>
                filteredProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.category_outlined,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No products found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedCategory != 'all'
                                    ? 'No items available in "$selectedCategory".'
                                    : 'No items matching your search criteria.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(productSearchQueryProvider.notifier)
                                      .clear();
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .selectCategory('all');
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: const Text('View All Categories'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(productControllerProvider.notifier)
                              .fetchProducts();
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.65,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductGridCard(
                              product: filteredProducts[index],
                            );
                          },
                        ),
                      ),
              ProductError(:final failure) => Center(
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
                      Text(
                        failure.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(productControllerProvider.notifier)
                              .fetchProducts();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}
