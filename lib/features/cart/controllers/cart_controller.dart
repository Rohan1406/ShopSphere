import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/features/cart/models/cart_item.dart';
import 'package:shopsphere/features/products/models/product.dart';

// ==========================================
// CART STATE
// ==========================================

class CartState {
  final List<CartItem> items;
  final double discountPercent;
  final String? appliedPromo;

  const CartState({
    required this.items,
    this.discountPercent = 0.0,
    this.appliedPromo,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => subtotal * discountPercent;
  double get total => subtotal - discountAmount;
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    double? discountPercent,
    String? appliedPromo,
    bool clearPromo = false,
  }) {
    return CartState(
      items: items ?? this.items,
      discountPercent: clearPromo
          ? 0.0
          : (discountPercent ?? this.discountPercent),
      appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
    );
  }
}

// ==========================================
// CART CONTROLLER PROVIDER
// ==========================================

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

// ==========================================
// CART CONTROLLER
// ==========================================

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    // Initial demo dummy cart items
    final initialItems = <CartItem>[
      if (DummyData.products.isNotEmpty)
        CartItem(
          id: DummyData.products[0].id,
          title: DummyData.products[0].title,
          price: DummyData.products[0].price,
          imageUrl: DummyData.products[0].imageUrl,
          quantity: 1,
        ),
      if (DummyData.products.length > 2)
        CartItem(
          id: DummyData.products[2].id,
          title: DummyData.products[2].title,
          price: DummyData.products[2].price,
          imageUrl: DummyData.products[2].imageUrl,
          quantity: 2,
        ),
    ];

    return CartState(items: initialItems);
  }

  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.id == product.id,
    );
    if (existingIndex != -1) {
      final updatedList = List<CartItem>.from(state.items);
      final current = updatedList[existingIndex];
      updatedList[existingIndex] = current.copyWith(
        quantity: current.quantity + quantity,
      );
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = CartItem(
        id: product.id,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    final updatedList = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedList);
  }

  void incrementQuantity(String id) {
    final item = state.items.firstWhere((i) => i.id == id);
    updateQuantity(id, item.quantity + 1);
  }

  void decrementQuantity(String id) {
    final item = state.items.firstWhere((i) => i.id == id);
    if (item.quantity > 1) {
      updateQuantity(id, item.quantity - 1);
    } else {
      removeItem(id);
    }
  }

  void removeItem(String id) {
    final updatedList = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedList);
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }

  bool applyPromo(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'TECH40') {
      state = state.copyWith(
        discountPercent: 0.40,
        appliedPromo: 'TECH40 (40% OFF)',
      );
      return true;
    } else if (cleanCode == 'STYLE20') {
      state = state.copyWith(
        discountPercent: 0.20,
        appliedPromo: 'STYLE20 (20% OFF)',
      );
      return true;
    }
    return false;
  }

  void removePromo() {
    state = state.copyWith(clearPromo: true);
  }
}
