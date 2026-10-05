import 'package:flutter/material.dart';

/// Supported sorting strategies for the product catalog.
enum ProductSortOption {
  featured('Featured', Icons.auto_awesome_rounded),
  priceLowToHigh('Price: Low to High', Icons.arrow_upward_rounded),
  priceHighToLow('Price: High to Low', Icons.arrow_downward_rounded),
  rating('Customer Rating', Icons.star_rounded),
  newestArrivals('Newest Arrivals', Icons.fiber_new_rounded);

  const ProductSortOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Immutable state container holding all active filter criteria.
class ProductFilterState {
  static const double defaultMinPrice = 0.0;
  static const double defaultMaxPrice = 100000.0;
  static const RangeValues defaultPriceRange = RangeValues(
    defaultMinPrice,
    defaultMaxPrice,
  );

  final RangeValues priceRange;
  final Set<String> selectedBrands;
  final double minRating;
  final bool inStockOnly;
  final ProductSortOption sortOption;

  const ProductFilterState({
    this.priceRange = defaultPriceRange,
    this.selectedBrands = const {},
    this.minRating = 0.0,
    this.inStockOnly = false,
    this.sortOption = ProductSortOption.featured,
  });

  /// Factory for a clean initial state
  factory ProductFilterState.initial() => const ProductFilterState();

  /// Total count of active filter constraints (excluding default sort)
  int get activeFiltersCount {
    int count = 0;
    if (priceRange.start > defaultMinPrice ||
        priceRange.end < defaultMaxPrice) {
      count++;
    }
    if (selectedBrands.isNotEmpty) {
      count += selectedBrands.length;
    }
    if (minRating > 0.0) {
      count++;
    }
    if (inStockOnly) {
      count++;
    }
    if (sortOption != ProductSortOption.featured) {
      count++;
    }
    return count;
  }

  /// Whether any filtering or custom sorting is currently active
  bool get hasActiveFilters => activeFiltersCount > 0;

  /// Check if a specific brand is selected
  bool isBrandSelected(String brand) =>
      selectedBrands.any((b) => b.toLowerCase() == brand.toLowerCase());

  ProductFilterState copyWith({
    RangeValues? priceRange,
    Set<String>? selectedBrands,
    double? minRating,
    bool? inStockOnly,
    ProductSortOption? sortOption,
  }) {
    return ProductFilterState(
      priceRange: priceRange ?? this.priceRange,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      minRating: minRating ?? this.minRating,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  /// Returns a clean default state with all filters cleared
  ProductFilterState reset() => const ProductFilterState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilterState &&
          runtimeType == other.runtimeType &&
          priceRange == other.priceRange &&
          _setEquals(selectedBrands, other.selectedBrands) &&
          minRating == other.minRating &&
          inStockOnly == other.inStockOnly &&
          sortOption == other.sortOption;

  @override
  int get hashCode =>
      priceRange.hashCode ^
      selectedBrands.hashCode ^
      minRating.hashCode ^
      inStockOnly.hashCode ^
      sortOption.hashCode;

  static bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
