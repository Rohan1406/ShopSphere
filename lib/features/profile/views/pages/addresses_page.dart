import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/services/geo_location_service.dart';
import 'package:shopsphere/features/profile/views/widgets/add_edit_address_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/current_location_gps_banner.dart';
import 'package:shopsphere/features/profile/views/widgets/empty_addresses_view.dart';
import 'package:shopsphere/features/profile/views/widgets/geographic_map_picker.dart';
import 'package:shopsphere/features/profile/views/widgets/saved_address_card.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  void _openMapAndFillAddress(
    BuildContext context,
    WidgetRef ref, [
    GeoPoint? initialPoint,
  ]) async {
    final selectedPoint = await GeographicMapPicker.show(
      context,
      initialLocation: initialPoint,
    );

    if (selectedPoint != null && context.mounted) {
      AddEditAddressSheet.show(context, ref, null, selectedPoint);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesControllerProvider);
    final liveLocationAsync = ref.watch(liveLocationProvider);
    final currentGeo =
        liveLocationAsync.value ?? GeoLocationService.currentLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        actions: [
          IconButton(
            onPressed: () => _openMapAndFillAddress(context, ref, currentGeo),
            tooltip: 'Choose on Map',
            icon: const Icon(Icons.map_outlined),
          ),
          IconButton(
            onPressed: () => AddEditAddressSheet.show(context, ref),
            tooltip: 'Add Address',
            icon: const Icon(Icons.add_location_alt_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Current GPS Location Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CurrentLocationGpsBanner(
                onDeliverToCurrentLocation: () =>
                    _openMapAndFillAddress(context, ref, currentGeo),
              ),
            ),
          ),

          // 2. Saved Addresses List
          if (addresses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyAddressesView(
                onAddAddress: () => AddEditAddressSheet.show(context, ref),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final address = addresses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SavedAddressCard(address: address),
                  );
                }, childCount: addresses.length),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _openMapAndFillAddress(context, ref),
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text(
                      'Use GPS Location',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => AddEditAddressSheet.show(context, ref),
                    icon: const Icon(Icons.add_location_rounded, size: 18),
                    label: const Text(
                      'Add Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
