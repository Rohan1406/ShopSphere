import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/models/coupon.dart';
import 'package:shopsphere/features/profile/models/notification_settings.dart';
import 'package:shopsphere/features/profile/models/order.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';
import 'package:shopsphere/features/profile/models/support_item.dart';
import 'package:shopsphere/features/profile/models/user_profile.dart';

// ==========================================
// 1. USER PROFILE CONTROLLER
// ==========================================

final userProfileControllerProvider =
    NotifierProvider<UserProfileController, UserProfile>(
      UserProfileController.new,
    );

class UserProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return UserProfile.defaultDemo();
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? dateOfBirth,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }

  void updateAvatar(String? avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
  }
}

// ==========================================
// 2. ORDERS CONTROLLER & COMPUTED PROVIDERS
// ==========================================

final ordersControllerProvider =
    NotifierProvider<OrdersController, List<Order>>(OrdersController.new);

class OrdersController extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    return Order.dummyOrders();
  }

  void addOrder(Order order) {
    state = [order, ...state];
  }

  bool cancelOrder(String orderId) {
    final index = state.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final currentOrder = state[index];
    if (!currentOrder.isCancellable) return false;

    final updatedSteps = [
      ...currentOrder.trackingSteps,
      const OrderTrackingStep(
        title: 'Order Cancelled',
        description: 'Order cancelled by customer. Refund initiated.',
        timestamp: 'Just now',
        isCompleted: true,
      ),
    ];

    final updatedOrder = currentOrder.copyWith(
      status: OrderStatus.cancelled,
      trackingSteps: updatedSteps,
    );

    final updatedList = List<Order>.from(state);
    updatedList[index] = updatedOrder;
    state = updatedList;
    return true;
  }

  int reorder(String orderId, WidgetRef ref) {
    final order = state.where((o) => o.id == orderId).firstOrNull;
    if (order == null) return 0;

    final cartNotifier = ref.read(cartControllerProvider.notifier);
    int addedCount = 0;

    for (final item in order.items) {
      final product = Product(
        id: item.productId,
        title: item.title,
        description: 'Reordered item from ${order.id}',
        price: item.price,
        imageUrl: item.imageUrl,
        category: item.category.toLowerCase(),
      );
      cartNotifier.addProduct(product, quantity: item.quantity);
      addedCount += item.quantity;
    }

    return addedCount;
  }
}

final activeOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersControllerProvider);
  return orders
      .where(
        (o) =>
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipped,
      )
      .toList();
});

final deliveredOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersControllerProvider);
  return orders.where((o) => o.status == OrderStatus.delivered).toList();
});

final cancelledOrdersProvider = Provider<List<Order>>((ref) {
  final orders = ref.watch(ordersControllerProvider);
  return orders.where((o) => o.status == OrderStatus.cancelled).toList();
});

final latestActiveOrderProvider = Provider<Order?>((ref) {
  final active = ref.watch(activeOrdersProvider);
  return active.isNotEmpty ? active.first : null;
});

final orderByIdProvider = Provider.family<Order?, String>((ref, orderId) {
  final orders = ref.watch(ordersControllerProvider);
  return orders.where((o) => o.id == orderId).firstOrNull;
});

// ==========================================
// 3. ADDRESSES CONTROLLER
// ==========================================

final addressesControllerProvider =
    NotifierProvider<AddressesController, List<Address>>(
      AddressesController.new,
    );

class AddressesController extends Notifier<List<Address>> {
  @override
  List<Address> build() {
    return Address.dummyAddresses();
  }

  void addAddress(Address address) {
    if (address.isDefault || state.isEmpty) {
      final resetList = state.map((a) => a.copyWith(isDefault: false)).toList();
      state = [
        ...resetList,
        address.copyWith(
          id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
          isDefault: true,
        ),
      ];
    } else {
      state = [
        ...state,
        address.copyWith(id: 'addr_${DateTime.now().millisecondsSinceEpoch}'),
      ];
    }
  }

  void updateAddress(Address address) {
    if (address.isDefault) {
      state = state.map((a) {
        if (a.id == address.id) return address;
        return a.copyWith(isDefault: false);
      }).toList();
    } else {
      state = state.map((a) => a.id == address.id ? address : a).toList();
    }
  }

  void deleteAddress(String addressId) {
    final remaining = state.where((a) => a.id != addressId).toList();
    if (remaining.isNotEmpty && !remaining.any((a) => a.isDefault)) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = remaining;
  }

  void setDefaultAddress(String addressId) {
    state = state.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();
  }
}

// ==========================================
// 4. PAYMENT METHODS CONTROLLER
// ==========================================

class PaymentMethodsState {
  final List<PaymentCard> cards;
  final List<UpiPayment> upiList;

  const PaymentMethodsState({required this.cards, required this.upiList});

  PaymentMethodsState copyWith({
    List<PaymentCard>? cards,
    List<UpiPayment>? upiList,
  }) {
    return PaymentMethodsState(
      cards: cards ?? this.cards,
      upiList: upiList ?? this.upiList,
    );
  }
}

final paymentMethodsControllerProvider =
    NotifierProvider<PaymentMethodsController, PaymentMethodsState>(
      PaymentMethodsController.new,
    );

class PaymentMethodsController extends Notifier<PaymentMethodsState> {
  @override
  PaymentMethodsState build() {
    return PaymentMethodsState(
      cards: PaymentCard.dummyCards(),
      upiList: UpiPayment.dummyUpi(),
    );
  }

  void addCard(PaymentCard card) {
    final newId = 'card_${DateTime.now().millisecondsSinceEpoch}';
    if (card.isDefault || state.cards.isEmpty) {
      final updatedCards = state.cards
          .map((c) => c.copyWith(isDefault: false))
          .toList();
      state = state.copyWith(
        cards: [
          ...updatedCards,
          card.copyWith(id: newId, isDefault: true),
        ],
      );
    } else {
      state = state.copyWith(
        cards: [
          ...state.cards,
          card.copyWith(id: newId),
        ],
      );
    }
  }

  void deleteCard(String cardId) {
    final remaining = state.cards.where((c) => c.id != cardId).toList();
    if (remaining.isNotEmpty && !remaining.any((c) => c.isDefault)) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = state.copyWith(cards: remaining);
  }

  void setDefaultCard(String cardId) {
    final updated = state.cards.map((c) {
      return c.copyWith(isDefault: c.id == cardId);
    }).toList();
    state = state.copyWith(cards: updated);
  }

  void addUpi(UpiPayment upi) {
    final newId = 'upi_${DateTime.now().millisecondsSinceEpoch}';
    if (upi.isDefault || state.upiList.isEmpty) {
      final updatedUpi = state.upiList
          .map((u) => u.copyWith(isDefault: false))
          .toList();
      state = state.copyWith(
        upiList: [
          ...updatedUpi,
          upi.copyWith(id: newId, isDefault: true),
        ],
      );
    } else {
      state = state.copyWith(
        upiList: [
          ...state.upiList,
          upi.copyWith(id: newId),
        ],
      );
    }
  }

  void deleteUpi(String upiId) {
    final remaining = state.upiList.where((u) => u.id != upiId).toList();
    if (remaining.isNotEmpty && !remaining.any((u) => u.isDefault)) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = state.copyWith(upiList: remaining);
  }

  void setDefaultUpi(String upiId) {
    final updated = state.upiList.map((u) {
      return u.copyWith(isDefault: u.id == upiId);
    }).toList();
    state = state.copyWith(upiList: updated);
  }
}

// ==========================================
// 5. COUPONS CONTROLLER
// ==========================================

final couponsControllerProvider =
    NotifierProvider<CouponsController, List<Coupon>>(CouponsController.new);

class CouponsController extends Notifier<List<Coupon>> {
  @override
  List<Coupon> build() {
    return Coupon.dummyCoupons();
  }

  bool claimCoupon(String code) {
    final upper = code.trim().toUpperCase();
    final exists = state.any((c) => c.code.toUpperCase() == upper);
    if (exists) return false;

    // Add dynamically claimed promo
    final newCoupon = Coupon(
      code: upper,
      title: '$upper Promo Reward',
      description: 'Special coupon claimed for your account.',
      discountPercent: 15,
      minOrderAmount: 999.0,
      maxDiscountAmount: 1500.0,
      validUntil: 'Dec 31, 2026',
      terms: const ['Valid on all full-price items'],
    );
    state = [newCoupon, ...state];
    return true;
  }
}

// ==========================================
// 6. NOTIFICATION SETTINGS CONTROLLER
// ==========================================

final notificationSettingsControllerProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettings>(
      NotificationSettingsController.new,
    );

class NotificationSettingsController extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    return const NotificationSettings();
  }

  void toggleOrderUpdates(bool value) =>
      state = state.copyWith(orderUpdates: value);

  void toggleDeliveryAlerts(bool value) =>
      state = state.copyWith(deliveryAlerts: value);

  void togglePromotionalOffers(bool value) =>
      state = state.copyWith(promotionalOffers: value);

  void togglePriceDropAlerts(bool value) =>
      state = state.copyWith(priceDropAlerts: value);

  void toggleExclusiveDeals(bool value) =>
      state = state.copyWith(exclusiveDeals: value);

  void toggleNewsletter(bool value) =>
      state = state.copyWith(newsletter: value);

  void toggleSmsUpdates(bool value) =>
      state = state.copyWith(smsUpdates: value);

  void toggleWhatsappAlerts(bool value) =>
      state = state.copyWith(whatsappAlerts: value);
}

// ==========================================
// 7. SUPPORT TICKETS CONTROLLER
// ==========================================

final supportTicketsControllerProvider =
    NotifierProvider<SupportTicketsController, List<SupportTicket>>(
      SupportTicketsController.new,
    );

class SupportTicketsController extends Notifier<List<SupportTicket>> {
  @override
  List<SupportTicket> build() {
    return SupportTicket.dummyTickets();
  }

  void submitTicket({
    required String subject,
    required String category,
    required String description,
  }) {
    final newTicket = SupportTicket(
      id: 'TCK-${1000 + state.length + 1}',
      subject: subject,
      category: category,
      status: 'Open',
      createdAt: 'Just now',
      description: description,
    );
    state = [newTicket, ...state];
  }
}
