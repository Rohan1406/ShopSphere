import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/notification_settings_page.dart';

void main() {
  group('NotificationSettingsPage', () {
    testWidgets('renders all notification sections and switches', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NotificationSettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Orders & Delivery Alerts'), findsOneWidget);
      expect(find.text('Offers & Promotions'), findsOneWidget);
      expect(find.text('Preferred Channels'), findsOneWidget);

      expect(find.text('Order Status Updates'), findsOneWidget);
      expect(find.text('Doorstep Delivery ETA'), findsOneWidget);
      expect(find.text('Promotional Offers & Sales'), findsOneWidget);
      expect(find.text('Price Drop Alerts'), findsOneWidget);
      expect(find.text('VIP Exclusive Perks'), findsOneWidget);
      expect(find.text('SMS Alerts'), findsOneWidget);
      expect(find.text('WhatsApp Notifications'), findsOneWidget);
      expect(find.text('Email Newsletter'), findsOneWidget);
    });

    testWidgets('toggles switch states', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: NotificationSettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      final firstSwitch = find.byType(Switch).first;
      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();
    });
  });
}
