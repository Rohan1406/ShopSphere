import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/products/models/category.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.categories = Category.standardCategories,
    this.itemCounts,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final List<Category> categories;
  final Map<String, int>? itemCounts;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              selectedCategoryId.toLowerCase() == category.id.toLowerCase();
          final count = itemCounts?[category.id];

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Icon(
              category.iconData,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onSelected: (_) => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

