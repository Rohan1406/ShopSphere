import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/cart/controllers/cart_controller.dart';
import 'package:shopsphere/features/checkout/models/delivery_option.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/address.dart';
import 'package:shopsphere/features/profile/models/coupon.dart';
import 'package:shopsphere/features/profile/models/order.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

enum PaymentMethodType {
  card,
  upi,
  cod;

  String get displayName {
    switch (this) {
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.upi:
        return 'UPI App (GPay / PhonePe / Paytm)';
      case PaymentMethodType.cod:
        return 'Cash on Delivery';
    }
  }
}

class CheckoutState {
  final int currentStep; // 0: Address, 1: Payment, 2: Summary/Review
  final Address? selectedAddress;
  final PaymentMethodType paymentType;
  final PaymentCard? selectedCard;
  final UpiPayment? selectedUpi;
  final DeliveryOption selectedDelivery;
  final Coupon? appliedCoupon;
  final String? promoError;
  final bool isPlacingOrder;
  final Order? placedOrder;

  const CheckoutState({
    this.currentStep = 0,
    this.selectedAddress,
    this.paymentType = PaymentMethodType.card,
    this.selectedCard,
    this.selectedUpi,
    required this.selectedDelivery,
    this.appliedCoupon,
    this.promoError,
    this.isPlacingOrder = false,
    this.placedOrder,
  });

  bool get isAddressValid => selectedAddress != null;

  bool get isPaymentValid {
    switch (paymentType) {
      case PaymentMethodType.card:
        return selectedCard != null;
      case PaymentMethodType.upi:
        return selectedUpi != null;
      case PaymentMethodType.cod:
        return true;
    }
  }

  String get paymentSummaryLabel {
    switch (paymentType) {
      case PaymentMethodType.card:
        if (selectedCard != null) {
          return '${selectedCard!.brand.displayName} (•••• ${selectedCard!.cardNumberLast4})';
        }
        return 'Credit / Debit Card';
      case PaymentMethodType.upi:
        if (selectedUpi != null) {
          return '${selectedUpi!.providerName} (${selectedUpi!.upiId})';
        }
        return 'UPI Payment';
      case PaymentMethodType.cod:
        return 'Cash on Delivery (Pay at Doorstep)';
    }
  }

  double calculateDiscount(double subtotal) {
    if (appliedCoupon == null) return 0.0;
    final calculated = subtotal * (appliedCoupon!.discountPercent / 100.0);
    return calculated > appliedCoupon!.maxDiscountAmount
        ? appliedCoupon!.maxDiscountAmount
        : calculated;
  }

  double calculateTaxes(double subtotal, double discount) {
    final taxable = (subtotal - discount).clamp(0.0, double.infinity);
    return taxable * 0.18; // 18% GST
  }

  double calculateTotal(double subtotal) {
    final discount = calculateDiscount(subtotal);
    final taxes = calculateTaxes(subtotal, discount);
    return (subtotal - discount + selectedDelivery.fee + taxes).clamp(
      0.0,
      double.infinity,
    );
  }

  CheckoutState copyWith({
    int? currentStep,
    Address? selectedAddress,
    PaymentMethodType? paymentType,
    PaymentCard? selectedCard,
    UpiPayment? selectedUpi,
    DeliveryOption? selectedDelivery,
    Coupon? appliedCoupon,
    bool clearCoupon = false,
    String? promoError,
    bool clearPromoError = false,
    bool? isPlacingOrder,
    Order? placedOrder,
  }) {
    return CheckoutState(
      currentStep: currentStep ?? this.currentStep,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentType: paymentType ?? this.paymentType,
      selectedCard: selectedCard ?? this.selectedCard,
      selectedUpi: selectedUpi ?? this.selectedUpi,
      selectedDelivery: selectedDelivery ?? this.selectedDelivery,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      promoError: clearPromoError ? null : (promoError ?? this.promoError),
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      placedOrder: placedOrder ?? this.placedOrder,
    );
  }
}

// ==========================================
// CHECKOUT CONTROLLER PROVIDER
// ==========================================

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    final addresses = ref.watch(addressesControllerProvider);
    final defaultAddress =
        addresses.where((a) => a.isDefault).firstOrNull ??
        (addresses.isNotEmpty ? addresses.first : null);

    final paymentMethods = ref.watch(paymentMethodsControllerProvider);
    final defaultCard =
        paymentMethods.cards.where((c) => c.isDefault).firstOrNull ??
        (paymentMethods.cards.isNotEmpty ? paymentMethods.cards.first : null);
    final defaultUpi =
        paymentMethods.upiList.where((u) => u.isDefault).firstOrNull ??
        (paymentMethods.upiList.isNotEmpty
            ? paymentMethods.upiList.first
            : null);

    final cartState = ref.watch(cartControllerProvider);
    final deliveryOptions = DeliveryOption.standardOptions(
      cartSubtotal: cartState.subtotal,
    );

    // If promo was already applied in CartState, find matching coupon or build one
    Coupon? initialCoupon;
    if (cartState.appliedPromo != null) {
      final coupons = ref.read(couponsControllerProvider);
      final clean = cartState.appliedPromo!.toUpperCase();
      initialCoupon = coupons.where((c) => clean.contains(c.code)).firstOrNull;
      if (initialCoupon == null && cartState.discountPercent > 0) {
        initialCoupon = Coupon(
          code: 'CARTPROMO',
          title: 'Applied Cart Discount',
          description: 'Special cart promotion discount applied.',
          discountPercent: (cartState.discountPercent * 100).round(),
          validUntil: 'Dec 31, 2026',
        );
      }
    }

    return CheckoutState(
      currentStep: 0,
      selectedAddress: defaultAddress,
      paymentType: PaymentMethodType.card,
      selectedCard: defaultCard,
      selectedUpi: defaultUpi,
      selectedDelivery: deliveryOptions.first,
      appliedCoupon: initialCoupon,
    );
  }

  void selectAddress(Address address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentType(PaymentMethodType type) {
    state = state.copyWith(paymentType: type);
  }

  void selectCard(PaymentCard card) {
    state = state.copyWith(
      paymentType: PaymentMethodType.card,
      selectedCard: card,
    );
  }

  void selectUpi(UpiPayment upi) {
    state = state.copyWith(
      paymentType: PaymentMethodType.upi,
      selectedUpi: upi,
    );
  }

  void selectCod() {
    state = state.copyWith(paymentType: PaymentMethodType.cod);
  }

  void selectDeliveryOption(DeliveryOption option) {
    state = state.copyWith(selectedDelivery: option);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  bool applyCoupon(Coupon coupon, double cartSubtotal) {
    if (cartSubtotal < coupon.minOrderAmount) {
      state = state.copyWith(
        promoError:
            'Minimum order amount of ₹${coupon.minOrderAmount.toStringAsFixed(0)} required for coupon ${coupon.code}.',
      );
      return false;
    }

    state = state.copyWith(appliedCoupon: coupon, clearPromoError: true);
    return true;
  }

  bool applyCouponCode(String code, double cartSubtotal) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      state = state.copyWith(promoError: 'Please enter a valid promo code.');
      return false;
    }

    final availableCoupons = ref.read(couponsControllerProvider);
    final match = availableCoupons
        .where((c) => c.code.toUpperCase() == cleanCode)
        .firstOrNull;

    if (match != null) {
      return applyCoupon(match, cartSubtotal);
    }

    // Dynamic fallback vouchers like TECH40, STYLE20, SAVE10
    if (cleanCode == 'SAVE10') {
      final coupon = Coupon(
        code: 'SAVE10',
        title: 'Special 10% Savings',
        description: 'Instant 10% discount on entire cart.',
        discountPercent: 10,
        minOrderAmount: 499.0,
        maxDiscountAmount: 1000.0,
        validUntil: 'Dec 31, 2026',
      );
      return applyCoupon(coupon, cartSubtotal);
    }

    state = state.copyWith(
      promoError: 'Coupon code "$cleanCode" is invalid or expired.',
    );
    return false;
  }

  void removeCoupon() {
    state = state.copyWith(clearCoupon: true, clearPromoError: true);
  }

  Future<Order?> placeOrder() async {
    final cartState = ref.read(cartControllerProvider);
    if (cartState.isEmpty ||
        state.selectedAddress == null ||
        !state.isPaymentValid) {
      return null;
    }

    state = state.copyWith(isPlacingOrder: true);

    // Simulate quick realistic payment gateway network verification delay
    await Future.delayed(const Duration(milliseconds: 900));

    final randomId = Random().nextInt(90000) + 10000;
    final orderId = 'SHP-$randomId';
    final trackingNumber = 'TRK-IND-${Random().nextInt(900000) + 100000}';

    final orderItems = cartState.items.map((cartItem) {
      return OrderItem(
        productId: cartItem.id,
        title: cartItem.title,
        price: cartItem.price,
        imageUrl: cartItem.imageUrl,
        quantity: cartItem.quantity,
        category: 'Fashion & Tech',
      );
    }).toList();

    final subtotal = cartState.subtotal;
    final discountAmount = state.calculateDiscount(subtotal);
    final shippingFee = state.selectedDelivery.fee;
    final taxAmount = state.calculateTaxes(subtotal, discountAmount);
    final totalAmount = state.calculateTotal(subtotal);

    final userProfile = ref.read(userProfileControllerProvider);

    final now = DateTime.now();

    final trackingSteps = [
      OrderTrackingStep(
        title: 'Order Placed & Confirmed',
        description: 'Payment authorized via ${state.paymentSummaryLabel}.',
        timestamp: 'Just now',
        isCompleted: true,
      ),
      const OrderTrackingStep(
        title: 'Processing & Quality Check',
        description: 'Order sent to ShopSphere central fulfillment facility.',
        timestamp: 'In progress',
        isCompleted: true,
      ),
      OrderTrackingStep(
        title: 'Dispatch & In Transit',
        description:
            'Assigned to courier partner with tracking $trackingNumber.',
        timestamp: 'Expected today',
        isCompleted: false,
      ),
      OrderTrackingStep(
        title: 'Out for Delivery',
        description:
            'Delivery executive will deliver to ${state.selectedAddress!.city}.',
        timestamp: state.selectedDelivery.estimatedDelivery,
        isCompleted: false,
      ),
      OrderTrackingStep(
        title: 'Delivered',
        description:
            'Package handed over to ${state.selectedAddress!.fullName}.',
        timestamp: state.selectedDelivery.estimatedDelivery,
        isCompleted: false,
      ),
    ];

    final newOrder = Order(
      id: orderId,
      orderDate: now,
      status: OrderStatus.processing,
      items: orderItems,
      subtotal: subtotal,
      discountAmount: discountAmount,
      shippingFee: shippingFee,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      deliveryAddress: state.selectedAddress!.fullFormatted,
      recipientName: state.selectedAddress!.fullName.isNotEmpty
          ? state.selectedAddress!.fullName
          : userProfile.name,
      recipientPhone: state.selectedAddress!.phone.isNotEmpty
          ? state.selectedAddress!.phone
          : userProfile.phone,
      paymentMethod: state.paymentSummaryLabel,
      trackingNumber: trackingNumber,
      estimatedDelivery: state.selectedDelivery.estimatedDelivery,
      trackingSteps: trackingSteps,
    );

    // Save order in orders controller
    ref.read(ordersControllerProvider.notifier).addOrder(newOrder);

    // Clear cart
    ref.read(cartControllerProvider.notifier).clearCart();

    state = state.copyWith(isPlacingOrder: false, placedOrder: newOrder);

    return newOrder;
  }

  void reset() {
    state = build();
  }
}
