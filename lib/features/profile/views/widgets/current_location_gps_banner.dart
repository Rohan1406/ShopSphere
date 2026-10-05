import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/services/geo_location_service.dart';
import 'package:shopsphere/features/profile/views/widgets/geographic_map_picker.dart';

class CurrentLocationGpsBanner extends ConsumerWidget {
  final VoidCallback onDeliverToCurrentLocation;

  const CurrentLocationGpsBanner({
    super.key,
    required this.onDeliverToCurrentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveLocationAsync = ref.watch(liveLocationProvider);
    final currentGeo =
        liveLocationAsync.value ?? GeoLocationService.currentLocation;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            currentGeo.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        if (liveLocationAsync.isLoading) ...[
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentGeo.streetAddress}, ${currentGeo.city} (${currentGeo.formattedCoordinates})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'GPS ACCURATE',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDeliverToCurrentLocation,
                  icon: const Icon(Icons.pin_drop_rounded, size: 16),
                  label: const Text('Deliver to Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  GeographicMapPicker.show(
                    context,
                    initialLocation: currentGeo,
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 16),
                label: const Text('View Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF475569)),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
