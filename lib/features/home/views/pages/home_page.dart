import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/products/views/widgets/category_filter_bar.dart';
import 'package:shopsphere/features/products/views/widgets/product_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedCategory = 'all';

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
  }

  void _navigateToCatalog([String? category]) {
    final cat = category ?? _selectedCategory;
    if (cat == 'all') {
      context.push('/products');
    } else {
      context.push('/products?category=$cat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState is AuthLoading;
    final theme = Theme.of(context);

    // Filter products dynamically based on selected category
    final displayedProducts = _selectedCategory == 'all'
        ? DummyData.products.take(4).toList()
        : DummyData.findProductsByCategory(_selectedCategory);

    // Compute item counts for the category chips
    final Map<String, int> counts = {
      'all': DummyData.products.length,
      for (final cat in DummyData.categoryList)
        if (cat.id != 'all')
          cat.id: DummyData.findProductsByCategory(cat.id).length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(
            onPressed: isLoggingOut ? null : _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to ShopSphere',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => _navigateToCatalog(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text(
                              'Search products by name or category...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Promo Banners
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: DummyData.promoBanners.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final banner = DummyData.promoBanners[index];
                    final gradients = [
                      [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                      [const Color(0xFF0D9488), const Color(0xFF059669)],
                      [const Color(0xFFEA580C), const Color(0xFFD97706)],
                    ];
                    final gradient = gradients[index % gradients.length];

                    return Container(
                      width: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner['badge'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CODE: ${banner['code']}',
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            banner['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            banner['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Categories Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Browse by Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedCategory != 'all')
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'all';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Category Filter Bar
              CategoryFilterBar(
                selectedCategoryId: _selectedCategory,
                categories: DummyData.categoryList,
                itemCounts: counts,
                onCategorySelected: (catId) {
                  setState(() {
                    _selectedCategory = catId;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'all'
                          ? 'Featured Products'
                          : '${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)} Products (${displayedProducts.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToCatalog(),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Dynamic items list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: displayedProducts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No products available in this category.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : Column(
                        children: displayedProducts
                            .map((product) => ProductCard(product: product))
                            .toList(),
                      ),
              ),

              const SizedBox(height: 16),

              // Main CTA Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _navigateToCatalog(),
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    label: Text(
                      _selectedCategory == 'all'
                          ? 'View Products'
                          : 'Explore All ${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)} (${counts[_selectedCategory] ?? 0})',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
