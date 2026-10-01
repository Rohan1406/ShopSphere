import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/profile/views/pages/profile_page.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('displays user profile information and options', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ProfilePage())),
      );

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Demo Shopper'), findsOneWidget);
      expect(find.text('demo@shopsphere.com'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
