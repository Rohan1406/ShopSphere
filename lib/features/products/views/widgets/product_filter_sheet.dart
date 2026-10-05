import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/models/product_filter_state.dart';

/// Luxury Modal Bottom Sheet for e-commerce filtering and sorting.
class ProductFilterSheet extends ConsumerStatefulWidget {
  const ProductFilterSheet({super.key});

  /// Convenient static helper to display the sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFilterSheet(),
    );
  }

  @override
  ConsumerState<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<ProductFilterSheet> {
  late RangeValues _priceRange;
  late Set<String> _selectedBrands;
  late double _minRating;
  late bool _inStockOnly;
  late ProductSortOption _sortOption;

  static const double _maxAllowedPrice = 100000.0;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(productFilterProvider);
    _priceRange = RangeValues(
      currentFilter.priceRange.start.clamp(0.0, _maxAllowedPrice),
      currentFilter.priceRange.end.clamp(0.0, _maxAllowedPrice),
    );
    _selectedBrands = Set<String>.from(currentFilter.selectedBrands);
    _minRating = currentFilter.minRating;
    _inStockOnly = currentFilter.inStockOnly;
    _sortOption = currentFilter.sortOption;
  }

  void _resetLocalFilters() {
    setState(() {
      _priceRange = const RangeValues(0, _maxAllowedPrice);
      _selectedBrands.clear();
      _minRating = 0.0;
      _inStockOnly = false;
      _sortOption = ProductSortOption.featured;
    });
  }

  void _applyFilters() {
    final updated = ProductFilterState(
      priceRange: _priceRange,
      selectedBrands: _selectedBrands,
      minRating: _minRating,
      inStockOnly: _inStockOnly,
      sortOption: _sortOption,
    );
    ref.read(productFilterProvider.notifier).applyFilterState(updated);
    Navigator.of(context).pop();
  }

  int _calculateMatchingCount(List<Product> allProducts, String category, String search) {
    final query = search.trim().toLowerCase();
    return allProducts.where((product) {
      final matchesCategory =
          category == 'all' ||
          product.category.toLowerCase() == category.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          product.title.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query);
      final matchesPrice =
          product.price >= _priceRange.start && product.price <= _priceRange.end;
      final matchesBrand =
          _selectedBrands.isEmpty ||
          _selectedBrands.any(
            (b) => b.toLowerCase() == product.brand.toLowerCase(),
          );
      final matchesRating = product.rating >= _minRating;
      final matchesStock = !_inStockOnly || product.inStock;

      return matchesCategory &&
          matchesSearch &&
          matchesPrice &&
          matchesBrand &&
          matchesRating &&
          matchesStock;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allProducts = switch (ref.watch(productControllerProvider)) {
      ProductLoaded(:final products) => products,
      _ => DummyData.products,
    };
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(productSearchQueryProvider);

    final matchingCount = _calculateMatchingCount(
      allProducts,
      selectedCategory,
      searchQuery,
    );

    // Compute all unique brands from loaded products
    final availableBrands = allProducts.map((p) => p.brand).toSet().toList()
      ..sort();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filters & Sort',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _resetLocalFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. SORTING OPTIONS
                _buildSectionTitle(
                  title: 'Sort By',
                  icon: Icons.sort_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ProductSortOption.values.map((option) {
                    final isSelected = _sortOption == option;
                    return ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(
                        option.icon,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      label: Text(option.label),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceSubtle,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _sortOption = option);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 2. PRICE RANGE DUAL SLIDER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(
                      title: 'Price Range',
                      icon: Icons.currency_rupee_rounded,
                      theme: theme,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '₹${_priceRange.start.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} – ₹${_priceRange.end.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: _maxAllowedPrice,
                  divisions: 50,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.borderLight,
                  labels: RangeLabels(
                    '₹${_priceRange.start.toInt()}',
                    '₹${_priceRange.end.toInt()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),

                // Quick Price Preset Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPricePresetChip('Under ₹2,000', 0, 2000),
                    _buildPricePresetChip('₹2,000 – ₹10,000', 2000, 10000),
                    _buildPricePresetChip('₹10,000 – ₹30,000', 10000, 30000),
                    _buildPricePresetChip('₹30,000+', 30000, _maxAllowedPrice),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 3. BRAND SELECTION CHECKBOXES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(
                      title: 'Brands',
                      icon: Icons.verified_rounded,
                      theme: theme,
                    ),
                    if (_selectedBrands.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedBrands.clear());
                        },
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Clear', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableBrands.map((brand) {
                    final isSelected = _selectedBrands.any(
                      (b) => b.toLowerCase() == brand.toLowerCase(),
                    );
                    final brandCount = allProducts
                        .where(
                          (p) =>
                              p.brand.toLowerCase() == brand.toLowerCase() &&
                              (selectedCategory == 'all' ||
                                  p.category.toLowerCase() ==
                                      selectedCategory.toLowerCase()),
                        )
                        .length;

                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: true,
                      checkmarkColor: Colors.white,
                      avatar: !isSelected
                          ? const Icon(
                              Icons.check_box_outline_blank_rounded,
                              size: 16,
                              color: AppColors.textMuted,
                            )
                          : null,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(brand),
                          if (brandCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '($brandCount)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceSubtle,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBrands.add(brand);
                          } else {
                            _selectedBrands.removeWhere(
                              (b) => b.toLowerCase() == brand.toLowerCase(),
                            );
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 4. CUSTOMER RATING THRESHOLD
                _buildSectionTitle(
                  title: 'Customer Rating',
                  icon: Icons.star_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRatingChip('All Ratings', 0.0),
                    _buildRatingChip('4.5★ & above', 4.5),
                    _buildRatingChip('4.0★ & above', 4.0),
                    _buildRatingChip('3.5★ & above', 3.5),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),

                // 5. IN-STOCK ONLY TOGGLE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _inStockOnly
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: _inStockOnly
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'In-Stock Only',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Show items available for immediate shipping',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    activeTrackColor: AppColors.primary,
                    value: _inStockOnly,
                    onChanged: (val) {
                      setState(() => _inStockOnly = val);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Sticky Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              border: const Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _resetLocalFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Apply Filters ($matchingCount)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPricePresetChip(String label, double min, double max) {
    final isSelected = _priceRange.start == min && _priceRange.end == max;
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      backgroundColor:
          isSelected ? AppColors.primarySurface : AppColors.surfaceSubtle,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: () {
        setState(() {
          _priceRange = RangeValues(min, max);
        });
      },
    );
  }

  Widget _buildRatingChip(String label, double threshold) {
    final isSelected = _minRating == threshold;
    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: threshold > 0
          ? const Icon(
              Icons.star_rounded,
              size: 16,
              color: AppColors.amber,
            )
          : null,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceSubtle,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _minRating = threshold);
        }
      },
    );
  }
}
