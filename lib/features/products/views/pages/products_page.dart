import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/models/product_filter_state.dart';
import 'package:shopsphere/features/products/views/widgets/active_filter_chips_bar.dart';
import 'package:shopsphere/features/products/views/widgets/category_filter_bar.dart';
import 'package:shopsphere/features/products/views/widgets/product_filter_sheet.dart';
import 'package:shopsphere/features/products/views/widgets/product_grid_card.dart';
import 'package:shopsphere/features/products/views/widgets/search_suggestions_view.dart';
import 'package:shopsphere/features/products/views/widgets/voice_search_modal.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({
    this.initialCategory,
    this.autoFocusSearch = false,
    this.autoOpenVoiceSearch = false,
    this.autoOpenFilters = false,
    super.key,
  });

  final String? initialCategory;
  final bool autoFocusSearch;
  final bool autoOpenVoiceSearch;
  final bool autoOpenFilters;

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSuggestions = _searchFocusNode.hasFocus &&
              _searchController.text.trim().isEmpty;
        });
      }
    });

    Future.microtask(() {
      if (widget.initialCategory != null &&
          widget.initialCategory!.isNotEmpty) {
        ref
            .read(selectedCategoryProvider.notifier)
            .selectCategory(widget.initialCategory!);
      }
      ref.read(productControllerProvider.notifier).fetchProducts();

      if (widget.autoOpenVoiceSearch) {
        _openVoiceSearch();
      } else if (widget.autoOpenFilters) {
        _openFilterSheet();
      } else if (widget.autoFocusSearch) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openVoiceSearch() {
    VoiceSearchModal.show(
      context,
      onQueryRecognized: (query) {
        _onSearchQuerySubmitted(query);
      },
    );
  }

  void _openFilterSheet() {
    ProductFilterSheet.show(context);
  }

  void _onSearchQuerySubmitted(String query) {
    _searchController.text = query;
    ref.read(productSearchQueryProvider.notifier).updateQuery(query);
    if (query.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(query.trim());
    }
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _resetAllFilters() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(productSearchQueryProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).selectCategory('all');
    ref.read(productFilterProvider.notifier).resetFilters();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);
    final filterState = ref.watch(productFilterProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);

    final hasAnyFilter = selectedCategory != 'all' ||
        searchQuery.isNotEmpty ||
        filterState.hasActiveFilters;

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
          // Filter button with active count badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _openFilterSheet,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filters & Sort',
              ),
              if (filterState.activeFiltersCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.coral,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${filterState.activeFiltersCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (hasAnyFilter)
            TextButton.icon(
              onPressed: _resetAllFilters,
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
          // Search & Voice Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: widget.autoFocusSearch,
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Search products, brands, category...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(productSearchQueryProvider.notifier)
                                    .clear();
                                setState(() {
                                  _showSuggestions = false;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.mic_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            tooltip: 'Voice Search Simulation',
                            onPressed: _openVoiceSearch,
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    onSubmitted: (val) {
                      _onSearchQuerySubmitted(val);
                    },
                    onChanged: (val) {
                      ref
                          .read(productSearchQueryProvider.notifier)
                          .updateQuery(val);
                      setState(() {
                        _showSuggestions =
                            _searchFocusNode.hasFocus && val.trim().isEmpty;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Modal Sheet Quick Launcher
                InkWell(
                  onTap: _openFilterSheet,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: filterState.hasActiveFilters
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filterState.hasActiveFilters
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                      boxShadow: [
                        if (filterState.hasActiveFilters)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: filterState.hasActiveFilters
                          ? Colors.white
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories Horizontal Filter Bar
          CategoryFilterBar(
            selectedCategoryId: selectedCategory,
            itemCounts: counts,
            onCategorySelected: (catId) {
              _searchFocusNode.unfocus();
              setState(() {
                _showSuggestions = false;
              });
              ref.read(selectedCategoryProvider.notifier).selectCategory(catId);
            },
          ),

          // Active Multi-Facet Filters Bar
          const SizedBox(height: 6),
          const ActiveFilterChipsBar(),

          const SizedBox(height: 6),

          // Filter Summary Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  Expanded(
                    child: Text(
                      selectedCategory == 'all'
                          ? 'Showing all items (${filteredProducts.length})'
                          : 'Category: ${selectedCategory.toUpperCase()} (${filteredProducts.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
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
                  else if (filterState.sortOption != ProductSortOption.featured)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filterState.sortOption.icon,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          filterState.sortOption.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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

          // Main View (Search Suggestions OR Product Grid OR Error/Empty States)
          Expanded(
            child: _showSuggestions
                ? SearchSuggestionsView(
                    onQuerySelected: (query) {
                      _onSearchQuerySubmitted(query);
                    },
                    onVoiceSearchTap: _openVoiceSearch,
                  )
                : switch (state) {
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
                                        Icons.filter_list_off_rounded,
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
                                      hasAnyFilter
                                          ? 'No items matched your search and filter criteria. Try adjusting or clearing filters.'
                                          : 'No items available at this moment.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton.tonalIcon(
                                      onPressed: _resetAllFilters,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Reset All Filters'),
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  24,
                                ),
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
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
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
