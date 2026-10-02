import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/checkout/views/pages/order_success_page.dart';
import 'package:shopsphere/features/checkout/views/widgets/confetti_celebration.dart';

void main() {
  group('OrderSuccessPage Widget', () {
    testWidgets(
      'renders celebration heading, order ID, delivery tracker, and action buttons',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OrderSuccessPage())),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ConfettiCelebration), findsOneWidget);
        expect(find.text('Woohoo! Order Confirmed! 🎉'), findsOneWidget);
        expect(find.text('ORDER REFERENCE ID'), findsOneWidget);
        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('ESTIMATED DELIVERY'), findsOneWidget);
        expect(find.text('Order Snapshot'), findsOneWidget);
        expect(find.text('Track Live Order'), findsOneWidget);
        expect(find.text('Continue Shopping'), findsOneWidget);
      },
    );
  });
}
