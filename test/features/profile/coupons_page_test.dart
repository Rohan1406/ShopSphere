import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/coupons_page.dart';

void main() {
  group('CouponsPage', () {
    testWidgets('renders reward points banner and coupon cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CouponsPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coupons & Rewards'), findsOneWidget);
      expect(find.text('ShopSphere Reward Points'), findsOneWidget);
      expect(find.textContaining('pts available'), findsOneWidget);
      expect(find.text('Have a Promotional Voucher?'), findsOneWidget);
      expect(find.text('Claim'), findsOneWidget);
      expect(find.text('TECH40'), findsOneWidget);
      expect(find.text('STYLE20'), findsOneWidget);
      expect(find.text('COPY'), findsWidgets);
      expect(find.text('Apply on Cart'), findsWidgets);
    });

    testWidgets('claims entered coupon voucher', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CouponsPage())),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, ''),
        'FESTIVE50',
      );
      await tester.tap(find.text('Claim'));
      await tester.pumpAndSettle();

      expect(find.text('FESTIVE50'), findsOneWidget);
    });
  });
}
