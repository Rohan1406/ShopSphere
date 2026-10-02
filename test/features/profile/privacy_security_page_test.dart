import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/privacy_security_page.dart';

void main() {
  group('PrivacySecurityPage', () {
    testWidgets('renders security toggles, sessions, and data controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PrivacySecurityPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Account Security'), findsOneWidget);
      expect(find.text('Two-Factor Authentication (2FA)'), findsOneWidget);
      expect(find.text('Biometric Quick Unlock'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Logged-in Devices & Sessions'), findsOneWidget);
      expect(find.text('iPhone 15 Pro (Current Device)'), findsOneWidget);
      expect(find.text('Data & Privacy Control'), findsOneWidget);
      expect(find.text('Download Personal Data Archive'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('opens change password modal sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PrivacySecurityPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Current Password *'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
    });

    testWidgets('opens delete account confirmation dialog', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PrivacySecurityPage())),
      );
      await tester.pumpAndSettle();

      final deleteAccountTile = find.text('Delete Account');
      await tester.scrollUntilVisible(deleteAccountTile, 200);
      await tester.tap(deleteAccountTile);
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(find.text('Delete Permanently'), findsOneWidget);
    });
  });
}
