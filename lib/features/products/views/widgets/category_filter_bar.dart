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
      height: 44,
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
                Text(category.name),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : Colors.black.withValues(alpha: 0.08),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}
