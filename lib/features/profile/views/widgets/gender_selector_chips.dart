import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

class GenderSelectorChips extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSelectorChips({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    const genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

    return Wrap(
      spacing: 8,
      children: genders.map((gender) {
        final isSelected = selectedGender == gender;
        return ChoiceChip(
          label: Text(gender),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onGenderSelected(gender);
            }
          },
          selectedColor: AppColors.primarySurface,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          backgroundColor: AppColors.background,
        );
      }).toList(),
    );
  }
}
