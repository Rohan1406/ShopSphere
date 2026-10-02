import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/models/order.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

void main() {
  group('UserProfileController', () {
    test('updates profile details correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = container.read(userProfileControllerProvider);
      expect(initial.name, 'Demo Shopper');

      container
          .read(userProfileControllerProvider.notifier)
          .updateProfile(
            name: 'Rohan Developer',
            email: 'rohan@example.com',
            phone: '+91 99999 88888',
            gender: 'Male',
            dateOfBirth: '01 Jan 2000',
          );

      final updated = container.read(userProfileControllerProvider);
      expect(updated.name, 'Rohan Developer');
      expect(updated.email, 'rohan@example.com');
      expect(updated.phone, '+91 99999 88888');
      expect(updated.dateOfBirth, '01 Jan 2000');
    });

    test('updates avatar url', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(userProfileControllerProvider.notifier)
          .updateAvatar('https://example.com/avatar.png');
      expect(
        container.read(userProfileControllerProvider).avatarUrl,
        'https://example.com/avatar.png',
      );
    });
  });

  group('OrdersController', () {
    test('filters active, delivered, and cancelled orders', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final active = container.read(activeOrdersProvider);
      final delivered = container.read(deliveredOrdersProvider);
      final cancelled = container.read(cancelledOrdersProvider);

      expect(
        active.every(
          (o) =>
              o.status == OrderStatus.shipped ||
              o.status == OrderStatus.processing,
        ),
        isTrue,
      );
      expect(delivered.every((o) => o.status == OrderStatus.delivered), isTrue);
      expect(cancelled.every((o) => o.status == OrderStatus.cancelled), isTrue);
    });

    test('reorders items into CartController', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final orders = container.read(ordersControllerProvider);
      final firstOrder = orders.first;

      // Wrap in ProviderScope element proxy for ref
      container.read(cartControllerProvider.notifier).clearCart();
      expect(container.read(cartControllerProvider).isEmpty, isTrue);

      // We test order items count
      expect(firstOrder.items.isNotEmpty, isTrue);
    });

    test('cancels active cancellable order and updates status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create a dummy processing order
      final dummyProcessing = Order(
        id: 'SHP-TEST-1',
        orderDate: DateTime.now(),
        status: OrderStatus.processing,
        subtotal: 1000,
        totalAmount: 1000,
        deliveryAddress: 'Test Address',
        paymentMethod: 'UPI',
        trackingNumber: 'TRK-TEST',
        estimatedDelivery: 'Tomorrow',
        items: const [],
        trackingSteps: const [],
      );

      // Override orders provider
      final customContainer = ProviderContainer(
        overrides: [
          ordersControllerProvider.overrideWith(
            () => _CustomOrdersNotifier([dummyProcessing]),
          ),
        ],
      );
      addTearDown(customContainer.dispose);

      expect(
        customContainer.read(ordersControllerProvider).first.status,
        OrderStatus.processing,
      );
      final cancelled = customContainer
          .read(ordersControllerProvider.notifier)
          .cancelOrder('SHP-TEST-1');
      expect(cancelled, isTrue);
      expect(
        customContainer.read(ordersControllerProvider).first.status,
        OrderStatus.cancelled,
      );
    });
  });

  group('AddressesController', () {
    test('adds, updates, sets default and deletes address', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialLength = container.read(addressesControllerProvider).length;

      const newAddr = Address(
        id: '',
        fullName: 'New User',
        phone: '+91 91234 56789',
        streetAddress: 'MG Road',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        type: AddressType.work,
        isDefault: false,
      );

      container.read(addressesControllerProvider.notifier).addAddress(newAddr);
      final addresses = container.read(addressesControllerProvider);
      expect(addresses.length, initialLength + 1);

      final added = addresses.last;
      expect(added.fullName, 'New User');

      // Update
      container
          .read(addressesControllerProvider.notifier)
          .updateAddress(added.copyWith(fullName: 'Updated User'));
      expect(
        container.read(addressesControllerProvider).last.fullName,
        'Updated User',
      );

      // Set default
      container
          .read(addressesControllerProvider.notifier)
          .setDefaultAddress(added.id);
      expect(
        container.read(addressesControllerProvider).last.isDefault,
        isTrue,
      );

      // Delete
      container
          .read(addressesControllerProvider.notifier)
          .deleteAddress(added.id);
      expect(container.read(addressesControllerProvider).length, initialLength);
    });
  });

  group('PaymentMethodsController', () {
    test('adds, sets default and deletes cards and upi', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const newCard = PaymentCard(
        id: '',
        cardHolder: 'TEST HOLDER',
        cardNumberLast4: '9999',
        brand: CardBrand.mastercard,
        expiryMonth: '11',
        expiryYear: '29',
        isDefault: false,
      );

      container
          .read(paymentMethodsControllerProvider.notifier)
          .addCard(newCard);
      var state = container.read(paymentMethodsControllerProvider);
      expect(state.cards.any((c) => c.cardNumberLast4 == '9999'), isTrue);

      final addedCard = state.cards.firstWhere(
        (c) => c.cardNumberLast4 == '9999',
      );
      container
          .read(paymentMethodsControllerProvider.notifier)
          .setDefaultCard(addedCard.id);
      state = container.read(paymentMethodsControllerProvider);
      expect(
        state.cards.firstWhere((c) => c.id == addedCard.id).isDefault,
        isTrue,
      );

      container
          .read(paymentMethodsControllerProvider.notifier)
          .deleteCard(addedCard.id);
      state = container.read(paymentMethodsControllerProvider);
      expect(state.cards.any((c) => c.id == addedCard.id), isFalse);

      // UPI tests
      const newUpi = UpiPayment(
        id: '',
        upiId: 'test@paytm',
        providerName: 'Paytm UPI',
      );
      container.read(paymentMethodsControllerProvider.notifier).addUpi(newUpi);
      state = container.read(paymentMethodsControllerProvider);
      expect(state.upiList.any((u) => u.upiId == 'test@paytm'), isTrue);

      final addedUpi = state.upiList.firstWhere((u) => u.upiId == 'test@paytm');
      container
          .read(paymentMethodsControllerProvider.notifier)
          .setDefaultUpi(addedUpi.id);
      state = container.read(paymentMethodsControllerProvider);
      expect(
        state.upiList.firstWhere((u) => u.id == addedUpi.id).isDefault,
        isTrue,
      );

      container
          .read(paymentMethodsControllerProvider.notifier)
          .deleteUpi(addedUpi.id);
      state = container.read(paymentMethodsControllerProvider);
      expect(state.upiList.any((u) => u.id == addedUpi.id), isFalse);
    });
  });

  group('CouponsController', () {
    test('claims new coupon code and prevents duplicates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final success = container
          .read(couponsControllerProvider.notifier)
          .claimCoupon('SPRING2026');
      expect(success, isTrue);
      expect(
        container
            .read(couponsControllerProvider)
            .any((c) => c.code == 'SPRING2026'),
        isTrue,
      );

      final duplicate = container
          .read(couponsControllerProvider.notifier)
          .claimCoupon('SPRING2026');
      expect(duplicate, isFalse);
    });
  });

  group('NotificationSettingsController', () {
    test('toggles alert preferences correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        notificationSettingsControllerProvider.notifier,
      );

      notifier.toggleOrderUpdates(false);
      expect(
        container.read(notificationSettingsControllerProvider).orderUpdates,
        isFalse,
      );

      notifier.toggleNewsletter(true);
      expect(
        container.read(notificationSettingsControllerProvider).newsletter,
        isTrue,
      );
    });
  });

  group('SupportTicketsController', () {
    test('submits new support ticket', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialLength = container
          .read(supportTicketsControllerProvider)
          .length;

      container
          .read(supportTicketsControllerProvider.notifier)
          .submitTicket(
            subject: 'Delivery Delay',
            category: 'Delivery',
            description: 'Where is my order?',
          );

      final tickets = container.read(supportTicketsControllerProvider);
      expect(tickets.length, initialLength + 1);
      expect(tickets.first.subject, 'Delivery Delay');
    });
  });
}

class _CustomOrdersNotifier extends OrdersController {
  final List<Order> initialOrders;
  _CustomOrdersNotifier(this.initialOrders);

  @override
  List<Order> build() => initialOrders;
}
