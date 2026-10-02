import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/profile/views/pages/profile_page.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('displays user profile information, stats, and options', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProfilePage())),
      );
      await tester.pump();

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Demo Shopper'), findsOneWidget);
      expect(find.text('demo@shopsphere.com'), findsOneWidget);
      expect(find.text('VIP Gold Member'), findsOneWidget);

      // Activity stats
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Coupons'), findsOneWidget);

      // Menu sections
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Shipping Addresses'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('My Wishlist'), findsOneWidget);
      expect(find.text('Coupons & Vouchers'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when logout button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProfilePage())),
      );
      await tester.pump();

      // Scroll to logout button
      final logoutButton = find.widgetWithText(OutlinedButton, 'Logout');
      await tester.scrollUntilVisible(logoutButton, 200);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to log out of ShopSphere?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
