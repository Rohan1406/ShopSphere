import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/services/geo_location_service.dart';
import 'package:shopsphere/features/profile/views/pages/addresses_page.dart';
import 'package:shopsphere/features/profile/views/widgets/address_map_thumbnail.dart';
import 'package:shopsphere/features/profile/views/widgets/geographic_map_picker.dart';

void main() {
  group('AddressesPage & Geographic Map', () {
    testWidgets('renders saved addresses, current GPS banner and mini maps', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddressesPage())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Shipping Addresses'), findsOneWidget);
      expect(
        find.text(GeoLocationService.currentLocation.locationName),
        findsOneWidget,
      );
      expect(find.text('GPS ACCURATE'), findsOneWidget);
      expect(find.text('Deliver to Current Location'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('HOME'), findsOneWidget);
      expect(find.byType(AddressMapThumbnail), findsWidgets);
      expect(find.text('Add Address'), findsOneWidget);
    });

    testWidgets('opens Add New Address modal with map action', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddressesPage())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.add_location_alt_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Add New Address'), findsWidgets);
      expect(find.text('Pinpoint on Geographic Map'), findsOneWidget);
      expect(find.text('Address Tag'), findsOneWidget);
      expect(find.text('Save Address'), findsOneWidget);
    });

    testWidgets('opens GeographicMapPicker from View Map button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddressesPage())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the top banner View Map button
      await tester.tap(find.text('View Map').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GeographicMapPicker), findsOneWidget);
      expect(find.text('Search locality, area, street...'), findsOneWidget);
      expect(find.text('GPS ACTIVE'), findsOneWidget);
      expect(find.text('Confirm Location & Fill Address'), findsOneWidget);
    });

    testWidgets('GeographicMapPicker switches map styles and searches', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GeographicMapPicker(
              initialLocation: GeoLocationService.currentLocation,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Test map style switch
      final styleBtn = find.byKey(const ValueKey('map_style_toggle'));
      expect(styleBtn, findsOneWidget);
      await tester.tap(styleBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Test search
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);
      await tester.enterText(searchInput, 'Bandra');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bandra West, Mumbai'), findsOneWidget);
    });

    test('Address model serializes and deserializes geolocation data', () {
      const address = Address(
        id: 'addr_test',
        fullName: 'Test Shopper',
        phone: '+91 98765 43210',
        apartment: 'Suite 100',
        streetAddress: 'MG Road',
        landmark: 'Near Metro',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        type: AddressType.home,
        isDefault: true,
        latitude: 12.9716,
        longitude: 77.5946,
        locationName: 'MG Road, Bengaluru',
      );

      expect(address.hasCoordinates, isTrue);
      expect(address.coordinatesDisplay, contains('12.9716° N'));
      expect(address.fullFormatted, contains('(Near Near Metro)'));

      final json = address.toJson();
      expect(json['latitude'], 12.9716);
      expect(json['longitude'], 77.5946);
      expect(json['landmark'], 'Near Metro');

      final fromJson = Address.fromJson(json);
      expect(fromJson.latitude, 12.9716);
      expect(fromJson.longitude, 77.5946);
      expect(fromJson.landmark, 'Near Metro');
      expect(fromJson.locationName, 'MG Road, Bengaluru');
    });

    test('GeoLocationService provides reverse geocoding fallback', () {
      final point = GeoLocationService.reverseGeocode(12.9784, 77.6408);
      expect(point.locationName, 'Indiranagar, Bengaluru');
      expect(point.city, 'Bengaluru');
      expect(point.pincode, '560038');

      final customPoint = GeoLocationService.reverseGeocode(25.0, 85.0);
      expect(customPoint.latitude, 25.0);
      expect(customPoint.longitude, 85.0);
      expect(customPoint.formattedCoordinates, '25.0000° N, 85.0000° E');
    });

    test(
      'GeoLocationService searchLocations returns location suggestions',
      () async {
        final results = await GeoLocationService.searchLocations('Indiranagar');
        expect(results, isNotEmpty);
        expect(results.first.locationName, contains('Indiranagar'));
      },
    );
  });
}
