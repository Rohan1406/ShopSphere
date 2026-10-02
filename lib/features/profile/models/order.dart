import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

enum OrderStatus {
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return AppColors.amber;
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.processing:
        return AppColors.amberLight;
      case OrderStatus.shipped:
        return AppColors.primarySurface;
      case OrderStatus.delivered:
        return AppColors.successSurface;
      case OrderStatus.cancelled:
        return AppColors.errorSurface;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.processing:
        return Icons.inventory_2_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

class OrderItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
  final String category;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.category = 'General',
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'category': category,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String,
    quantity: (json['quantity'] as num).toInt(),
    category: json['category'] as String? ?? 'General',
  );
}

class OrderTrackingStep {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;

  const OrderTrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'timestamp': timestamp,
    'isCompleted': isCompleted,
  };

  factory OrderTrackingStep.fromJson(Map<String, dynamic> json) =>
      OrderTrackingStep(
        title: json['title'] as String,
        description: json['description'] as String,
        timestamp: json['timestamp'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class Order {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;
  final String deliveryAddress;
  final String recipientName;
  final String recipientPhone;
  final String paymentMethod;
  final String trackingNumber;
  final String estimatedDelivery;
  final List<OrderTrackingStep> trackingSteps;

  const Order({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.shippingFee = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    required this.deliveryAddress,
    this.recipientName = 'Demo Shopper',
    this.recipientPhone = '+91 98765 43210',
    required this.paymentMethod,
    required this.trackingNumber,
    required this.estimatedDelivery,
    required this.trackingSteps,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  bool get isCancellable => status == OrderStatus.processing;

  Order copyWith({
    String? id,
    DateTime? orderDate,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? discountAmount,
    double? shippingFee,
    double? taxAmount,
    double? totalAmount,
    String? deliveryAddress,
    String? recipientName,
    String? recipientPhone,
    String? paymentMethod,
    String? trackingNumber,
    String? estimatedDelivery,
    List<OrderTrackingStep>? trackingSteps,
  }) {
    return Order(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingSteps: trackingSteps ?? this.trackingSteps,
    );
  }

  static List<Order> dummyOrders() {
    return [
      Order(
        id: 'SHP-9812',
        orderDate: DateTime.now().subtract(const Duration(hours: 18)),
        status: OrderStatus.shipped,
        subtotal: 37998.00,
        discountAmount: 4000.00,
        shippingFee: 0.0,
        taxAmount: 6119.64,
        totalAmount: 33998.00,
        recipientName: 'Demo Shopper',
        recipientPhone: '+91 98765 43210',
        deliveryAddress:
            'Flat 402, Signature Towers, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038',
        paymentMethod: 'Credit Card (•••• 4242)',
        trackingNumber: 'TRK-IND-9812044',
        estimatedDelivery: 'Tomorrow by 6:00 PM',
        items: const [
          OrderItem(
            productId: '1',
            title: 'Sony WH-1000XM5 Noise Cancelling Headphones',
            price: 29999.00,
            imageUrl:
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&q=80',
            quantity: 1,
            category: 'Electronics',
          ),
          OrderItem(
            productId: '3',
            title: 'Nike Air Max Performance Runners',
            price: 7999.00,
            imageUrl:
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80',
            quantity: 1,
            category: 'Footwear',
          ),
        ],
        trackingSteps: [
          OrderTrackingStep(
            title: 'Order Placed & Confirmed',
            description: 'Payment authorized and order received by ShopSphere',
            timestamp: 'Yesterday, 10:30 PM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Packed & Dispatched',
            description: 'Order packed at Bengaluru Central Fulfillment Hub',
            timestamp: 'Today, 08:15 AM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'In Transit',
            description:
                'Courier partner Bluedart Express is moving your package',
            timestamp: 'Today, 02:40 PM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Out for Delivery',
            description: 'Delivery agent assigned for doorstep drop',
            timestamp: 'Tomorrow, Morning',
            isCompleted: false,
          ),
          OrderTrackingStep(
            title: 'Delivered',
            description: 'Package delivered with OTP confirmation',
            timestamp: 'Tomorrow by 6:00 PM',
            isCompleted: false,
          ),
        ],
      ),
      Order(
        id: 'SHP-8431',
        orderDate: DateTime.now().subtract(const Duration(days: 4)),
        status: OrderStatus.delivered,
        subtotal: 6499.00,
        discountAmount: 1299.80,
        shippingFee: 0.0,
        taxAmount: 935.85,
        totalAmount: 5199.20,
        recipientName: 'Demo Shopper',
        recipientPhone: '+91 98765 43210',
        deliveryAddress:
            'Flat 402, Signature Towers, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038',
        paymentMethod: 'UPI (kanha@okaxis)',
        trackingNumber: 'TRK-IND-8431102',
        estimatedDelivery: 'Delivered on Oct 28',
        items: const [
          OrderItem(
            productId: '5',
            title: 'Keychron K2 Wireless Mechanical Keyboard',
            price: 6499.00,
            imageUrl:
                'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&q=80',
            quantity: 1,
            category: 'Electronics',
          ),
        ],
        trackingSteps: const [
          OrderTrackingStep(
            title: 'Order Placed',
            description: 'Payment verified via UPI',
            timestamp: '4 days ago, 11:00 AM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Dispatched',
            description: 'Dispatched from Mumbai Logistics Node',
            timestamp: '3 days ago, 04:20 PM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Out for Delivery',
            description: 'Courier agent was out for delivery',
            timestamp: '2 days ago, 09:10 AM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Delivered',
            description: 'Delivered to resident with signature verification',
            timestamp: '2 days ago, 01:45 PM',
            isCompleted: true,
          ),
        ],
      ),
      Order(
        id: 'SHP-7720',
        orderDate: DateTime.now().subtract(const Duration(days: 12)),
        status: OrderStatus.delivered,
        subtotal: 5498.00,
        discountAmount: 0.0,
        shippingFee: 0.0,
        taxAmount: 989.64,
        totalAmount: 5498.00,
        recipientName: 'Demo Shopper',
        recipientPhone: '+91 98765 43210',
        deliveryAddress:
            'Office 5B, Tech Vista Park, Whitefield Main Road, Bengaluru, Karnataka - 560066',
        paymentMethod: 'Credit Card (•••• 4242)',
        trackingNumber: 'TRK-IND-7720918',
        estimatedDelivery: 'Delivered on Oct 20',
        items: const [
          OrderItem(
            productId: '4',
            title: 'Handcrafted Vintage Leather Backpack',
            price: 3499.00,
            imageUrl:
                'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&q=80',
            quantity: 1,
            category: 'Fashion',
          ),
          OrderItem(
            productId: '7',
            title: 'Polarized Aviator Sunglasses',
            price: 1999.00,
            imageUrl:
                'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800&q=80',
            quantity: 1,
            category: 'Accessories',
          ),
        ],
        trackingSteps: const [
          OrderTrackingStep(
            title: 'Order Placed',
            description: 'Payment successful',
            timestamp: '12 days ago',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Delivered',
            description: 'Delivered to reception desk',
            timestamp: '10 days ago',
            isCompleted: true,
          ),
        ],
      ),
      Order(
        id: 'SHP-6105',
        orderDate: DateTime.now().subtract(const Duration(days: 22)),
        status: OrderStatus.cancelled,
        subtotal: 4499.00,
        discountAmount: 0.0,
        shippingFee: 0.0,
        taxAmount: 0.0,
        totalAmount: 4499.00,
        recipientName: 'Demo Shopper',
        recipientPhone: '+91 98765 43210',
        deliveryAddress:
            'Flat 402, Signature Towers, Indiranagar 100ft Road, Bengaluru, Karnataka - 560038',
        paymentMethod: 'UPI (kanha@okaxis)',
        trackingNumber: 'TRK-IND-6105490',
        estimatedDelivery: 'Cancelled upon user request',
        items: const [
          OrderItem(
            productId: '9',
            title: 'Pro ANC Wireless Earbuds with Spatial Audio',
            price: 4499.00,
            imageUrl:
                'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800&q=80',
            quantity: 1,
            category: 'Electronics',
          ),
        ],
        trackingSteps: const [
          OrderTrackingStep(
            title: 'Order Placed',
            description: 'Order created',
            timestamp: '22 days ago',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Order Cancelled',
            description:
                'Cancelled by customer before dispatch. Refund of ₹4,499 processed to source account.',
            timestamp: '22 days ago',
            isCompleted: true,
          ),
        ],
      ),
    ];
  }
}
