import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/my_orders_page.dart';

void main() {
  group('MyOrdersPage', () {
    testWidgets('renders tab bar and order cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: MyOrdersPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Orders'), findsOneWidget);
      expect(find.textContaining('All ('), findsOneWidget);
      expect(find.textContaining('Active ('), findsOneWidget);
      expect(find.textContaining('Delivered ('), findsOneWidget);
      expect(find.textContaining('Cancelled ('), findsOneWidget);

      expect(find.text('Order #SHP-9812'), findsOneWidget);
      expect(find.text('View Details'), findsWidgets);
      expect(find.text('Reorder'), findsWidgets);
    });

    testWidgets('switches tabs to Delivered and Cancelled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: MyOrdersPage())),
      );
      await tester.pumpAndSettle();

      // Tap Delivered tab
      await tester.tap(find.textContaining('Delivered ('));
      await tester.pumpAndSettle();

      expect(find.text('Order #SHP-8431'), findsOneWidget);

      // Tap Cancelled tab
      await tester.tap(find.textContaining('Cancelled ('));
      await tester.pumpAndSettle();

      expect(find.text('Order #SHP-6105'), findsOneWidget);
    });
  });
}
