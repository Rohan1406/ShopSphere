import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/checkout/views/pages/checkout_page.dart';
import 'package:shopsphere/features/checkout/views/widgets/checkout_stepper.dart';

void main() {
  group('CheckoutPage Widget', () {
    testWidgets('renders Stepper and Step 1 Address Selection initially', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CheckoutPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Express Checkout'), findsOneWidget);
      expect(find.byType(CheckoutStepper), findsOneWidget);
      expect(find.text('Select Delivery Address'), findsOneWidget);
      expect(find.text('Deliver to this Address'), findsOneWidget);
    });

    testWidgets(
      'advances to Step 2 Payment Selection on tapping Deliver button',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: CheckoutPage())),
        );
        await tester.pumpAndSettle();

        // Tap Deliver to this Address
        await tester.tap(find.text('Deliver to this Address'));
        await tester.pumpAndSettle();

        expect(find.text('Select Payment Method'), findsOneWidget);
        expect(find.text('Credit & Debit Cards'), findsOneWidget);
        expect(find.text('UPI (GPay, PhonePe, Paytm)'), findsOneWidget);
        expect(find.text('Pay on Delivery'), findsOneWidget);
        expect(find.text('Proceed to Summary'), findsOneWidget);
      },
    );

    testWidgets(
      'advances to Step 3 Review & Confirm Order on tapping Proceed',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: CheckoutPage())),
        );
        await tester.pumpAndSettle();

        // Step 0 -> Step 1
        await tester.tap(find.text('Deliver to this Address'));
        await tester.pumpAndSettle();

        // Step 1 -> Step 2
        await tester.tap(find.text('Proceed to Summary'));
        await tester.pumpAndSettle();

        expect(find.text('Review & Confirm Order'), findsOneWidget);
        expect(find.text('Deliver To'), findsOneWidget);
        expect(find.text('Payment Method'), findsOneWidget);
        expect(find.text('Choose Delivery Speed'), findsOneWidget);
        expect(find.text('Order Items'), findsOneWidget);
        expect(find.text('Coupons & Promos'), findsOneWidget);
        expect(find.text('Price Details'), findsOneWidget);
        expect(find.textContaining('Place Order'), findsOneWidget);
      },
    );
  });
}
