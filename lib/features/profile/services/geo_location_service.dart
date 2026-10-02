import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final liveLocationProvider = FutureProvider.autoDispose<GeoPoint>((ref) async {
  return GeoLocationService.fetchLiveLocation();
});

class GeoPoint {
  final double latitude;
  final double longitude;
  final String locationName;
  final String streetAddress;
  final String apartment;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isLiveGps;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.streetAddress,
    this.apartment = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isLiveGps = false,
  });

  String get formattedCoordinates =>
      '${latitude.abs().toStringAsFixed(4)}° ${latitude >= 0 ? 'N' : 'S'}, ${longitude.abs().toStringAsFixed(4)}° ${longitude >= 0 ? 'E' : 'W'}';

  String get fullAddress =>
      '${apartment.isNotEmpty ? '$apartment, ' : ''}$streetAddress, $city, $state - $pincode';

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'streetAddress': streetAddress,
    'apartment': apartment,
    'landmark': landmark,
    'city': city,
    'state': state,
    'pincode': pincode,
    'isLiveGps': isLiveGps,
  };

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    locationName: json['locationName'] as String? ?? 'Pinned Location',
    streetAddress: json['streetAddress'] as String? ?? '',
    apartment: json['apartment'] as String? ?? '',
    landmark: json['landmark'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    pincode: json['pincode'] as String? ?? '',
    isLiveGps: json['isLiveGps'] as bool? ?? false,
  );

  GeoPoint copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    String? streetAddress,
    String? apartment,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    bool? isLiveGps,
  }) {
    return GeoPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      streetAddress: streetAddress ?? this.streetAddress,
      apartment: apartment ?? this.apartment,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isLiveGps: isLiveGps ?? this.isLiveGps,
    );
  }
}

class GeoLocationService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {'User-Agent': 'ShopSphere-Flutter-App/1.0.0'},
    ),
  );

  /// Default simulated current GPS location (Indiranagar, Bengaluru)
  static const GeoPoint currentLocation = GeoPoint(
    latitude: 12.9784,
    longitude: 77.6408,
    locationName: 'Indiranagar 100ft Road',
    streetAddress: '100ft Road, HAL 2nd Stage, Indiranagar',
    apartment: 'Flat 402, Signature Towers',
    landmark: 'Near Indiranagar Metro Station',
    city: 'Bengaluru',
    state: 'Karnataka',
    pincode: '560038',
    isLiveGps: true,
  );

  /// Preset landmarks for quick offline matching & test reliability
  static const List<GeoPoint> presetLocations = [
    GeoPoint(
      latitude: 12.9784,
      longitude: 77.6408,
      locationName: 'Indiranagar, Bengaluru',
      streetAddress: '100ft Road, HAL 2nd Stage, Indiranagar',
      apartment: 'Flat 402, Signature Towers',
      landmark: 'Near Indiranagar Metro Station',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560038',
      isLiveGps: true,
    ),
    GeoPoint(
      latitude: 12.9352,
      longitude: 77.6245,
      locationName: 'Koramangala, Bengaluru',
      streetAddress: '80 Feet Road, 4th Block, Koramangala',
      apartment: 'Villa 12, Green Palms',
      landmark: 'Opposite Sony World Signal',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560034',
    ),
    GeoPoint(
      latitude: 12.9698,
      longitude: 77.7499,
      locationName: 'Whitefield, Bengaluru',
      streetAddress: 'ITPB Main Road, Whitefield',
      apartment: 'Building 4, Tech Vista Park',
      landmark: 'Behind Inorbit Mall',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560066',
    ),
    GeoPoint(
      latitude: 19.0596,
      longitude: 72.8295,
      locationName: 'Bandra West, Mumbai',
      streetAddress: 'Hill Road, Bandra West',
      apartment: 'Apt 10B, Sea Breeze Heights',
      landmark: 'Near Mehboob Studio',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400050',
    ),
    GeoPoint(
      latitude: 28.6315,
      longitude: 77.2167,
      locationName: 'Connaught Place, New Delhi',
      streetAddress: 'Inner Circle, Block C, Connaught Place',
      apartment: 'Suite 204, Regal Building',
      landmark: 'Near Rajiv Chowk Metro Gate 2',
      city: 'New Delhi',
      state: 'Delhi',
      pincode: '110001',
    ),
    GeoPoint(
      latitude: 17.4399,
      longitude: 78.3808,
      locationName: 'HITEC City, Hyderabad',
      streetAddress: 'Cyber Towers Road, Madhapur',
      apartment: 'Cyber Pearl, Block B',
      landmark: 'Near Mindspace IT Park',
      city: 'Hyderabad',
      state: 'Telangana',
      pincode: '500081',
    ),
  ];

  /// Real-time location search via Photon & Nominatim OpenStreetMap with preset fallback
  static Future<List<GeoPoint>> searchLocations(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = <GeoPoint>[];
    final qLower = cleanQuery.toLowerCase();

    // 1. Check local preset landmarks
    for (final loc in presetLocations) {
      if (loc.locationName.toLowerCase().contains(qLower) ||
          loc.city.toLowerCase().contains(qLower) ||
          loc.streetAddress.toLowerCase().contains(qLower) ||
          loc.landmark.toLowerCase().contains(qLower)) {
        results.add(loc);
      }
    }

    // 2. Perform live online search via Photon API (Fast, OpenStreetMap-backed)
    try {
      final response = await _dio.get(
        'https://photon.komoot.io/api/',
        queryParameters: {'q': cleanQuery, 'limit': 6},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final features = (data['features'] as List<dynamic>?) ?? [];

        for (final feature in features) {
          final props = (feature['properties'] as Map<String, dynamic>?) ?? {};
          final geom = (feature['geometry'] as Map<String, dynamic>?) ?? {};
          final coords = (geom['coordinates'] as List<dynamic>?) ?? [];

          if (coords.length >= 2) {
            final lng = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();

            final name = props['name'] ?? props['street'] ?? cleanQuery;
            final street = props['street'] ?? name;
            final city =
                props['city'] ??
                props['town'] ??
                props['county'] ??
                props['district'] ??
                '';
            final state = props['state'] ?? '';
            final postcode = props['postcode'] ?? '';
            final country = props['country'] ?? '';

            final locationName = [
              name,
              if (city.toString().isNotEmpty && city != name) city,
              if (state.toString().isNotEmpty) state,
            ].join(', ');

            // Avoid adding duplicates
            final isDuplicate = results.any(
              (r) =>
                  (r.latitude - lat).abs() < 0.001 &&
                  (r.longitude - lng).abs() < 0.001,
            );

            if (!isDuplicate) {
              results.add(
                GeoPoint(
                  latitude: lat,
                  longitude: lng,
                  locationName: locationName,
                  streetAddress: street.toString(),
                  apartment: props['housenumber'] ?? '',
                  landmark: country.toString(),
                  city: city.toString().isNotEmpty ? city.toString() : 'City',
                  state: state.toString().isNotEmpty
                      ? state.toString()
                      : 'State',
                  pincode: postcode.toString().isNotEmpty
                      ? postcode.toString()
                      : '560001',
                  isLiveGps: false,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[GeoLocation] Online Photon geocoding query failed: $e');
    }

    // 3. If still empty, try Nominatim search fallback
    if (results.isEmpty) {
      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'format': 'json',
            'q': cleanQuery,
            'addressdetails': 1,
            'limit': 5,
          },
        );

        if (response.statusCode == 200 && response.data is List) {
          for (final item in response.data) {
            final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
            final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
            final address = (item['address'] as Map<String, dynamic>?) ?? {};

            final road = address['road'] ?? address['suburb'] ?? cleanQuery;
            final city =
                address['city'] ??
                address['town'] ??
                address['county'] ??
                'City';
            final state = address['state'] ?? 'State';
            final postcode = address['postcode'] ?? '560001';

            results.add(
              GeoPoint(
                latitude: lat,
                longitude: lon,
                locationName: item['display_name'] ?? cleanQuery,
                streetAddress: road.toString(),
                apartment: address['house_number'] ?? '',
                landmark: '',
                city: city.toString(),
                state: state.toString(),
                pincode: postcode.toString(),
                isLiveGps: false,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[GeoLocation] Nominatim search query failed: $e');
      }
    }

    return results;
  }

  /// Fetches real device / iOS simulator GPS location with permissions and reverse-geocoding
  static Future<GeoPoint> fetchLiveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[GeoLocation] Location services disabled, using fallback');
        return currentLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[GeoLocation] Location permission denied');
          return currentLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[GeoLocation] Location permission permanently denied');
        return currentLocation;
      }

      // Query GPS position with high accuracy and a 4s timeout for simulator responsiveness
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      debugPrint(
        '[GeoLocation] Real GPS coordinates acquired: ${position.latitude}, ${position.longitude}',
      );

      // Perform real online reverse geocoding to resolve street address
      return await reverseGeocodeOnline(position.latitude, position.longitude);
    } catch (e) {
      debugPrint(
        '[GeoLocation] Error fetching live location: $e, using default fallback',
      );
      return currentLocation;
    }
  }

  /// Performs online reverse geocoding via OpenStreetMap Nominatim with local fallback
  static Future<GeoPoint> reverseGeocodeOnline(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final address = (data['address'] as Map<String, dynamic>?) ?? {};

        final road =
            address['road'] ??
            address['pedestrian'] ??
            address['street'] ??
            address['suburb'] ??
            'Street Area';
        final houseNumber = address['house_number'] ?? '';
        final suburb = address['suburb'] ?? address['neighbourhood'] ?? '';
        final city =
            address['city'] ??
            address['town'] ??
            address['county'] ??
            address['state_district'] ??
            'Bengaluru';
        final state = address['state'] ?? 'Karnataka';
        final postcode = address['postcode'] ?? '560001';
        final displayName = data['name'] ?? (suburb.isNotEmpty ? suburb : road);

        return GeoPoint(
          latitude: lat,
          longitude: lng,
          locationName: displayName.toString().isNotEmpty
              ? displayName.toString()
              : '$road, $city',
          streetAddress: houseNumber.isNotEmpty ? '$houseNumber, $road' : road,
          apartment: suburb.isNotEmpty ? '$suburb' : '',
          landmark: address['amenity'] ?? address['landmark'] ?? '',
          city: city,
          state: state,
          pincode: postcode,
          isLiveGps: true,
        );
      }
    } catch (e) {
      debugPrint('[GeoLocation] Online reverse geocoding failed: $e');
    }

    // Fall back to local reverse geocode
    return reverseGeocode(lat, lng).copyWith(isLiveGps: true);
  }

  /// Simulates reverse geocoding based on lat/lng coordinate proximity
  static GeoPoint reverseGeocode(double lat, double lng) {
    // Check if close to Cupertino / Apple Park (default iOS Simulator location)
    final dCupertino = (lat - 37.3323).abs() + (lng - (-122.0312)).abs();
    if (dCupertino < 1.0) {
      return GeoPoint(
        latitude: lat,
        longitude: lng,
        locationName: 'Apple Park (iOS Simulator)',
        streetAddress: '1 Apple Park Way',
        apartment: 'Building 1',
        landmark: 'Near Steve Jobs Theater',
        city: 'Cupertino',
        state: 'California',
        pincode: '95014',
        isLiveGps: true,
      );
    }

    // Find closest preset or synthesize realistic address
    GeoPoint closest = presetLocations.first;
    double minDistance = double.infinity;

    for (final loc in presetLocations) {
      final dLat = loc.latitude - lat;
      final dLng = loc.longitude - lng;
      final dist = dLat * dLat + dLng * dLng;
      if (dist < minDistance) {
        minDistance = dist;
        closest = loc;
      }
    }

    if (minDistance < 0.1) {
      return GeoPoint(
        latitude: lat,
        longitude: lng,
        locationName: closest.locationName,
        streetAddress: closest.streetAddress,
        apartment: closest.apartment,
        landmark: closest.landmark,
        city: closest.city,
        state: closest.state,
        pincode: closest.pincode,
        isLiveGps: true,
      );
    }

    return GeoPoint(
      latitude: lat,
      longitude: lng,
      locationName:
          'Pinned Location (${lat.toStringAsFixed(3)}°, ${lng.toStringAsFixed(3)}°)',
      streetAddress:
          'Near Main Avenue, Sector ${(lat * 10).abs().toInt() % 20 + 1}',
      apartment: 'Plot No. ${(lat * 100).abs().toInt() % 100 + 1}',
      landmark: 'Near City Center',
      city: lat.abs() > 30 ? 'New Delhi' : 'Bengaluru',
      state: lat.abs() > 30 ? 'Delhi' : 'Karnataka',
      pincode: '560001',
      isLiveGps: true,
    );
  }
}
