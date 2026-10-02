import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/checkout/controllers/checkout_controller.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/views/widgets/add_edit_address_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/geographic_map_picker.dart';

class CheckoutAddressStep extends ConsumerWidget {
  const CheckoutAddressStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Action Bar for Adding / Map Pinning
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  AddEditAddressSheet.show(context, ref);
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Add Address'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  final geoPoint = await GeographicMapPicker.show(context);
                  if (geoPoint != null && context.mounted) {
                    await AddEditAddressSheet.show(
                      context,
                      ref,
                      null,
                      geoPoint,
                    );
                  }
                },
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('Drop Pin'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (addresses.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Saved Addresses Found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please add a delivery destination or drop a pin on the map to proceed with checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const Row(
            children: [
              Text(
                'Select Delivery Address',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'Step 1 of 3',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          for (final address in addresses) ...[
            _AddressOptionCard(
              address: address,
              isSelected: checkoutState.selectedAddress?.id == address.id,
              onSelect: () => checkoutNotifier.selectAddress(address),
              onEdit: () => AddEditAddressSheet.show(context, ref, address),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  const _AddressOptionCard({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Type chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: address.type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        address.type.icon,
                        size: 13,
                        color: address.type.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.type.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: address.type.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit Address',
                  color: AppColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Recipient & Phone
            Text(
              address.fullName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              address.phone,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),

            // Formatted address
            Text(
              address.fullFormatted,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),

            if (address.hasCoordinates) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.pin_drop_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    address.coordinatesDisplay,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
