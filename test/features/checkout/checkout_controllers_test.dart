import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/checkout/controllers/checkout_controller.dart';
import 'package:shopsphere/features/checkout/models/delivery_option.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/models/order.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

void main() {
  group('CheckoutController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'initial state initializes with default address, payment, and delivery',
      () {
        final state = container.read(checkoutControllerProvider);
        expect(state.currentStep, 0);
        expect(state.selectedAddress, isNotNull);
        expect(state.selectedDelivery, isNotNull);
        expect(state.paymentType, PaymentMethodType.card);
        expect(state.isAddressValid, isTrue);
        expect(state.isPaymentValid, isTrue);
      },
    );

    test('selectAddress updates selected address correctly', () {
      final notifier = container.read(checkoutControllerProvider.notifier);
      const newAddress = Address(
        id: 'custom_addr_1',
        fullName: 'Jane Doe',
        phone: '+91 9988776655',
        streetAddress: '123 Baker Street',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
      );

      notifier.selectAddress(newAddress);
      final state = container.read(checkoutControllerProvider);
      expect(state.selectedAddress?.id, 'custom_addr_1');
      expect(state.selectedAddress?.fullName, 'Jane Doe');
    });

    test(
      'selectPaymentType, selectCard, selectUpi, and selectCod update state correctly',
      () {
        final notifier = container.read(checkoutControllerProvider.notifier);

        // Select UPI
        const testUpi = UpiPayment(
          id: 'upi_test',
          upiId: 'test@okaxis',
          providerName: 'Google Pay',
        );
        notifier.selectUpi(testUpi);
        var state = container.read(checkoutControllerProvider);
        expect(state.paymentType, PaymentMethodType.upi);
        expect(state.selectedUpi?.upiId, 'test@okaxis');
        expect(state.paymentSummaryLabel, contains('Google Pay'));

        // Select Card
        const testCard = PaymentCard(
          id: 'card_test',
          cardHolder: 'JANE DOE',
          cardNumberLast4: '9999',
          brand: CardBrand.mastercard,
          expiryMonth: '11',
          expiryYear: '29',
        );
        notifier.selectCard(testCard);
        state = container.read(checkoutControllerProvider);
        expect(state.paymentType, PaymentMethodType.card);
        expect(state.selectedCard?.cardNumberLast4, '9999');
        expect(state.paymentSummaryLabel, contains('Mastercard'));

        // Select COD
        notifier.selectCod();
        state = container.read(checkoutControllerProvider);
        expect(state.paymentType, PaymentMethodType.cod);
        expect(state.paymentSummaryLabel, contains('Cash on Delivery'));
        expect(state.isPaymentValid, isTrue);
      },
    );

    test('navigation step methods work within bounds', () {
      final notifier = container.read(checkoutControllerProvider.notifier);

      expect(container.read(checkoutControllerProvider).currentStep, 0);

      notifier.nextStep();
      expect(container.read(checkoutControllerProvider).currentStep, 1);

      notifier.nextStep();
      expect(container.read(checkoutControllerProvider).currentStep, 2);

      // Bound check
      notifier.nextStep();
      expect(container.read(checkoutControllerProvider).currentStep, 2);

      notifier.previousStep();
      expect(container.read(checkoutControllerProvider).currentStep, 1);

      notifier.goToStep(0);
      expect(container.read(checkoutControllerProvider).currentStep, 0);
    });

    test('delivery speed option selection updates delivery fee and total', () {
      final notifier = container.read(checkoutControllerProvider.notifier);
      const express = DeliveryOption(
        id: 'express',
        title: 'Express Delivery',
        subtitle: 'Next day delivery',
        fee: 99.0,
        estimatedDelivery: 'Tomorrow',
        icon: Icons.local_shipping_rounded,
      );

      notifier.selectDeliveryOption(express);
      final state = container.read(checkoutControllerProvider);
      expect(state.selectedDelivery.fee, 99.0);
      expect(state.selectedDelivery.id, 'express');
    });

    test('coupon code application calculates discount and taxes properly', () {
      final notifier = container.read(checkoutControllerProvider.notifier);
      const subtotal = 10000.0;

      // Apply TECH40 (40% discount, max 4000)
      final applied = notifier.applyCouponCode('TECH40', subtotal);
      expect(applied, isTrue);

      final state = container.read(checkoutControllerProvider);
      expect(state.appliedCoupon?.code, 'TECH40');

      final discount = state.calculateDiscount(subtotal);
      expect(discount, 4000.0);

      final taxes = state.calculateTaxes(subtotal, discount);
      expect(taxes, (10000.0 - 4000.0) * 0.18);

      final total = state.calculateTotal(subtotal);
      expect(total, (10000.0 - 4000.0 + state.selectedDelivery.fee + taxes));

      // Remove coupon
      notifier.removeCoupon();
      final stateWithoutCoupon = container.read(checkoutControllerProvider);
      expect(stateWithoutCoupon.appliedCoupon, isNull);
      expect(stateWithoutCoupon.calculateDiscount(subtotal), 0.0);
    });

    test('coupon code application respects minimum order value', () {
      final notifier = container.read(checkoutControllerProvider.notifier);
      // Min order for VIPGOLD50 is 4999
      final applied = notifier.applyCouponCode('VIPGOLD50', 500.0);
      expect(applied, isFalse);

      final state = container.read(checkoutControllerProvider);
      expect(state.promoError, isNotNull);
    });

    test(
      'placeOrder creates order in OrdersController and clears cart',
      () async {
        final notifier = container.read(checkoutControllerProvider.notifier);

        // Ensure cart has items
        expect(container.read(cartControllerProvider).isNotEmpty, isTrue);

        final initialOrderCount = container
            .read(ordersControllerProvider)
            .length;

        final placedOrder = await notifier.placeOrder();
        expect(placedOrder, isNotNull);
        expect(placedOrder!.id, startsWith('SHP-'));
        expect(placedOrder.status, OrderStatus.processing);
        expect(placedOrder.items, isNotEmpty);

        // OrdersController should have increased
        final updatedOrders = container.read(ordersControllerProvider);
        expect(updatedOrders.length, initialOrderCount + 1);
        expect(updatedOrders.first.id, placedOrder.id);

        // Cart should be cleared
        final updatedCart = container.read(cartControllerProvider);
        expect(updatedCart.isEmpty, isTrue);
      },
    );
  });
}
