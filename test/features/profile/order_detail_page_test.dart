import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/order_detail_page.dart';

void main() {
  group('OrderDetailPage', () {
    testWidgets('renders order details, tracking steps, and summary', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OrderDetailPage(orderId: 'SHP-9812')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order #SHP-9812'), findsWidgets);
      expect(find.text('Status: In Transit'), findsOneWidget);
      expect(find.text('Tracking Timeline'), findsOneWidget);
      expect(find.text('TRK: TRK-IND-9812044'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Payment Summary'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('Reorder All Items'), findsOneWidget);
    });

    testWidgets('opens tax invoice modal sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OrderDetailPage(orderId: 'SHP-9812')),
        ),
      );
      await tester.pumpAndSettle();

      // Tap invoice button in AppBar
      await tester.tap(find.byIcon(Icons.receipt_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tax Invoice / Receipt'), findsOneWidget);
      expect(find.text('Download PDF Invoice'), findsOneWidget);
    });

    testWidgets('handles non-existent order gracefully', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OrderDetailPage(orderId: 'INVALID_ID')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order #INVALID_ID not found'), findsOneWidget);
    });
  });
}
