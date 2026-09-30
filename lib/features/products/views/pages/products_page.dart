import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/views/widgets/category_filter_bar.dart';
import 'package:shopsphere/features/products/views/widgets/product_card.dart';

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
      if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
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
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          if (selectedCategory != 'all' || searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(productSearchQueryProvider.notifier).clear();
                ref.read(selectedCategoryProvider.notifier).selectCategory('all');
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
              label: const Text('Reset'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products or category...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
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

          // Filter Summary Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == 'all'
                      ? 'Showing all items (${filteredProducts.length})'
                      : 'Category: ${selectedCategory.toUpperCase()} (${filteredProducts.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  Text(
                    'Search: "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Main Product List or States
          Expanded(
            child: switch (state) {
              ProductInitial() => const SizedBox.shrink(),
              ProductLoading() => const Center(child: CircularProgressIndicator()),
              ProductLoaded() => filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                              icon: const Icon(Icons.refresh),
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
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: filteredProducts[index]);
                        },
                      ),
                    ),
              ProductError(:final failure) => Center(
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
                                .read(productControllerProvider.notifier)
                                .fetchProducts();
                          },
                          child: const Text('Retry'),
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
