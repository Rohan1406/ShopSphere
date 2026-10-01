import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/cart/views/pages/cart_page.dart';

void main() {
  group('CartController', () {
    test('initial state has dummy items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(cartControllerProvider);
      expect(state.items, isNotEmpty);
      expect(state.subtotal, greaterThan(0));
    });

    test('addProduct adds new product or increments quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(cartControllerProvider.notifier);
      final product = DummyData.products[1];

      controller.addProduct(product, quantity: 2);
      final state = container.read(cartControllerProvider);

      expect(state.items.any((i) => i.id == product.id), isTrue);
    });

    test('applyPromo calculates correct discount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(cartControllerProvider.notifier);
      final success = controller.applyPromo('TECH40');

      expect(success, isTrue);
      final state = container.read(cartControllerProvider);
      expect(state.discountPercent, 0.40);
      expect(state.discountAmount, state.subtotal * 0.40);
      expect(state.total, state.subtotal - state.discountAmount);
    });

    test('clearCart empties all items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(cartControllerProvider.notifier);
      controller.clearCart();

      final state = container.read(cartControllerProvider);
      expect(state.isEmpty, isTrue);
      expect(state.subtotal, 0.0);
    });
  });

  group('CartPage Widget', () {
    testWidgets('displays cart items, total and promo input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CartPage())),
      );

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Proceed to Checkout'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('applies promo code successfully', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CartPage())),
      );

      await tester.enterText(find.byType(TextField), 'TECH40');
      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(find.text('TECH40 (40% OFF)'), findsOneWidget);
      expect(find.text('Discount'), findsOneWidget);
    });
  });
}
