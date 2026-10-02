import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/payment_methods_page.dart';

void main() {
  group('PaymentMethodsPage', () {
    testWidgets('renders saved credit cards and UPI list', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PaymentMethodsPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Saved Cards'), findsOneWidget);
      expect(find.text('UPI & Digital Wallets'), findsOneWidget);
      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Add UPI'), findsOneWidget);
      expect(find.text('VISA'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('kanha@okaxis'), findsOneWidget);
    });

    testWidgets('opens Add Card bottom sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PaymentMethodsPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Card'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Card'), findsOneWidget);
      expect(find.text('Card Network'), findsOneWidget);
      expect(find.text('Save Card'), findsOneWidget);
    });

    testWidgets('opens Add UPI bottom sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PaymentMethodsPage())),
      );
      await tester.pumpAndSettle();

      final addUpiBtn = find.text('Add UPI');
      await tester.scrollUntilVisible(addUpiBtn, 200);
      await tester.tap(addUpiBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add UPI ID'), findsOneWidget);
      expect(find.text('UPI App'), findsOneWidget);
      expect(find.text('Verify & Save UPI ID'), findsOneWidget);
    });

    testWidgets('displays security information banner', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: PaymentMethodsPage())),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('256-bit AES banking-grade security'),
        findsOneWidget,
      );
    });
  });
}
