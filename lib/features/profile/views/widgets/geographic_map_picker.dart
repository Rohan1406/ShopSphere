import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/services/geo_location_service.dart';

enum MapStyle {
  standard('OpenStreetMap', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
  voyager(
    'Modern Light',
    'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
  ),
  dark(
    'Dark Matter',
    'https://basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png',
  ),
  satellite(
    'Satellite Imagery',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  );

  final String label;
  final String tileUrl;
  const MapStyle(this.label, this.tileUrl);
}

class GeographicMapPicker extends StatefulWidget {
  final GeoPoint? initialLocation;
  final ValueChanged<GeoPoint>? onLocationConfirmed;

  const GeographicMapPicker({
    super.key,
    this.initialLocation,
    this.onLocationConfirmed,
  });

  static Future<GeoPoint?> show(
    BuildContext context, {
    GeoPoint? initialLocation,
  }) {
    return showModalBottomSheet<GeoPoint>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GeographicMapPicker(initialLocation: initialLocation),
    );
  }

  @override
  State<GeographicMapPicker> createState() => _GeographicMapPickerState();
}

class _GeographicMapPickerState extends State<GeographicMapPicker>
    with SingleTickerProviderStateMixin {
  late GeoPoint _selectedLocation;
  late final MapController _mapController;
  late final AnimationController _pulseController;
  MapStyle _mapStyle = MapStyle.voyager;
  bool _isLocating = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<GeoPoint> _searchResults = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ?? GeoLocationService.currentLocation;
    _mapController = MapController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    if (widget.initialLocation == null) {
      Future.microtask(() => _locateMe());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pulseController.dispose();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // 1. Instant local filter for zero latency
    final qLower = clean.toLowerCase();
    final immediatePresets = GeoLocationService.presetLocations.where((loc) {
      return loc.locationName.toLowerCase().contains(qLower) ||
          loc.city.toLowerCase().contains(qLower) ||
          loc.streetAddress.toLowerCase().contains(qLower) ||
          loc.landmark.toLowerCase().contains(qLower);
    }).toList();

    setState(() {
      _searchResults = immediatePresets;
      _isSearching = true;
    });

    // 2. Debounced real-world online search
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final onlineResults = await GeoLocationService.searchLocations(clean);
      if (mounted) {
        setState(() {
          _searchResults = onlineResults;
          _isSearching = false;
        });
      }
    });
  }

  void _onSearchSubmitted(String query) async {
    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() => _isSearching = true);
    final results = await GeoLocationService.searchLocations(clean);
    if (!mounted) return;

    setState(() => _isSearching = false);
    if (results.isNotEmpty) {
      _selectLocation(results.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No location results found for "$clean"'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _selectLocation(GeoPoint point) {
    setState(() {
      _selectedLocation = point;
      _searchResults = [];
      _searchController.text = point.locationName;
    });
    _searchFocusNode.unfocus();

    try {
      _mapController.move(LatLng(point.latitude, point.longitude), 16.0);
    } catch (_) {}
  }

  void _onMapTapped(LatLng point) async {
    _searchFocusNode.unfocus();
    setState(() {
      _selectedLocation = _selectedLocation.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
        locationName: 'Fetching address...',
      );
      _searchResults = [];
    });

    final geocoded = await GeoLocationService.reverseGeocodeOnline(
      point.latitude,
      point.longitude,
    );

    if (mounted) {
      setState(() {
        _selectedLocation = geocoded;
        _searchController.text = geocoded.locationName;
      });
    }
  }

  void _locateMe() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final liveLocation = await GeoLocationService.fetchLiveLocation();
      if (!mounted) return;
      setState(() {
        _selectedLocation = liveLocation;
        _isLocating = false;
        _searchResults = [];
        _searchController.text = liveLocation.locationName;
      });

      try {
        _mapController.move(
          LatLng(liveLocation.latitude, liveLocation.longitude),
          16.5,
        );
      } catch (_) {}
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom + 1.0).clamp(3.0, 19.0),
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom - 1.0).clamp(3.0, 19.0),
    );
  }

  void _cycleMapStyle() {
    setState(() {
      final nextIndex = (_mapStyle.index + 1) % MapStyle.values.length;
      _mapStyle = MapStyle.values[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        _mapStyle == MapStyle.dark ||
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(
          children: [
            // 1. Real-Time Interactive FlutterMap
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    _selectedLocation.latitude,
                    _selectedLocation.longitude,
                  ),
                  initialZoom: 15.5,
                  minZoom: 3.0,
                  maxZoom: 19.0,
                  onTap: (tapPosition, point) => _onMapTapped(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _mapStyle.tileUrl,
                    userAgentPackageName: 'com.shopsphere.app',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          _selectedLocation.latitude,
                          _selectedLocation.longitude,
                        ),
                        width: 70,
                        height: 70,
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing radar ring
                                Container(
                                  width: 38 + (_pulseController.value * 22),
                                  height: 38 + (_pulseController.value * 22),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(
                                      alpha:
                                          (1.0 - _pulseController.value) * 0.4,
                                    ),
                                  ),
                                ),
                                // Center Pin
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Top Header & Search Bar with Autocomplete Suggestions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle & Header Row
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search Input Card
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearchSubmitted,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search locality, area, street...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSearching)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchResults = []);
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),

                      // Autocomplete Suggestions Dropdown List
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : AppColors.border,
                            ),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : AppColors.borderLight,
                            ),
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.pin_drop_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  item.locationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  item.fullAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                onTap: () => _selectLocation(item),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Floating Quick Action Controls (Zoom, Map Style, GPS Locate Me)
            Positioned(
              right: 16,
              bottom: 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Style Toggle
                  FloatingActionButton.small(
                    key: const ValueKey('map_style_toggle'),
                    heroTag: 'map_style_btn',
                    onPressed: _cycleMapStyle,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    foregroundColor: AppColors.primary,
                    tooltip: 'Switch Map Style (${_mapStyle.label})',
                    child: const Icon(Icons.layers_rounded, size: 20),
                  ),
                  const SizedBox(height: 10),

                  // Zoom In Button
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_btn',
                    onPressed: _zoomIn,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    foregroundColor: isDark
                        ? Colors.white
                        : AppColors.textPrimary,
                    tooltip: 'Zoom In',
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                  const SizedBox(height: 6),

                  // Zoom Out Button
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_btn',
                    onPressed: _zoomOut,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    foregroundColor: isDark
                        ? Colors.white
                        : AppColors.textPrimary,
                    tooltip: 'Zoom Out',
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                  const SizedBox(height: 10),

                  // GPS / Locate Me
                  FloatingActionButton.small(
                    heroTag: 'locate_me_btn',
                    onPressed: _locateMe,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    tooltip: 'Current GPS Location',
                    child: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                  ),
                ],
              ),
            ),

            // 4. Map Style Pill Overlay Badge
            Positioned(
              left: 16,
              bottom: 220,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _mapStyle.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Bottom Selected Location Summary Card & Confirm Action
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedLocation.locationName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'GPS ACTIVE',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedLocation.streetAddress}, ${_selectedLocation.city} (${_selectedLocation.formattedCoordinates})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Confirm & Fill Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onLocationConfirmed?.call(_selectedLocation);
                            Navigator.of(context).pop(_selectedLocation);
                          },
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Confirm Location & Fill Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
