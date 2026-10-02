import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/edit_profile_page.dart';

void main() {
  group('EditProfilePage', () {
    testWidgets('renders edit profile form with prefilled values', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: EditProfilePage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Demo Shopper'), findsOneWidget);
      expect(find.text('demo@shopsphere.com'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('edits full name and saves changes', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: EditProfilePage())),
      );
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Demo Shopper');
      await tester.enterText(nameField, 'Updated Shopper Name');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();
    });
  });
}
