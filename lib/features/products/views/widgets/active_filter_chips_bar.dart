import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product_filter_state.dart';

/// Horizontal active filter badges bar with one-tap removal.
class ActiveFilterChipsBar extends ConsumerWidget {
  const ActiveFilterChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(productFilterProvider);

    if (!filterState.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    // Price Range Chip
    if (filterState.priceRange.start > ProductFilterState.defaultMinPrice ||
        filterState.priceRange.end < ProductFilterState.defaultMaxPrice) {
      chips.add(
        _buildActiveChip(
          label:
              '₹${filterState.priceRange.start.toInt()} – ₹${filterState.priceRange.end.toInt()}',
          icon: Icons.currency_rupee_rounded,
          onDeleted: () {
            ref
                .read(productFilterProvider.notifier)
                .updatePriceRange(ProductFilterState.defaultPriceRange);
          },
        ),
      );
    }

    // Selected Brands Chips
    for (final brand in filterState.selectedBrands) {
      chips.add(
        _buildActiveChip(
          label: brand,
          icon: Icons.verified_rounded,
          onDeleted: () {
            ref.read(productFilterProvider.notifier).toggleBrand(brand);
          },
        ),
      );
    }

    // Min Rating Chip
    if (filterState.minRating > 0.0) {
      chips.add(
        _buildActiveChip(
          label: '${filterState.minRating}★ & up',
          icon: Icons.star_rounded,
          iconColor: AppColors.amber,
          onDeleted: () {
            ref.read(productFilterProvider.notifier).setMinRating(0.0);
          },
        ),
      );
    }

    // In Stock Only Chip
    if (filterState.inStockOnly) {
      chips.add(
        _buildActiveChip(
          label: 'In-Stock Only',
          icon: Icons.inventory_2_rounded,
          iconColor: AppColors.success,
          onDeleted: () {
            ref.read(productFilterProvider.notifier).setInStockOnly(false);
          },
        ),
      );
    }

    // Custom Sort Option Chip
    if (filterState.sortOption != ProductSortOption.featured) {
      chips.add(
        _buildActiveChip(
          label: 'Sort: ${filterState.sortOption.label}',
          icon: filterState.sortOption.icon,
          onDeleted: () {
            ref
                .read(productFilterProvider.notifier)
                .setSortOption(ProductSortOption.featured);
          },
        ),
      );
    }

    // Clear All Action
    chips.add(
      ActionChip(
        label: const Text('Clear All'),
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
        backgroundColor: AppColors.errorSurface,
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: () {
          ref.read(productFilterProvider.notifier).resetFilters();
        },
      ),
    );

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }

  Widget _buildActiveChip({
    required String label,
    required IconData icon,
    required VoidCallback onDeleted,
    Color? iconColor,
  }) {
    return InputChip(
      avatar: Icon(icon, size: 13, color: iconColor ?? AppColors.primary),
      label: Text(label),
      labelStyle: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      backgroundColor: AppColors.primarySurface,
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.25),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      deleteIcon: const Icon(Icons.close_rounded, size: 13),
      deleteIconColor: AppColors.primary,
      onDeleted: onDeleted,
    );
  }
}
