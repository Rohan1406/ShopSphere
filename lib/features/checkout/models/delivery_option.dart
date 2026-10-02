import 'package:flutter/material.dart';

class DeliveryOption {
  final String id;
  final String title;
  final String subtitle;
  final double fee;
  final String estimatedDelivery;
  final IconData icon;
  final bool isPopular;

  const DeliveryOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.estimatedDelivery,
    required this.icon,
    this.isPopular = false,
  });

  bool get isFree => fee == 0.0;

  static List<DeliveryOption> standardOptions({double cartSubtotal = 0.0}) {
    // Free standard delivery if cart >= ₹999, else ₹49
    final standardFee = cartSubtotal >= 999 ? 0.0 : 49.0;

    return [
      DeliveryOption(
        id: 'standard',
        title: 'Standard Delivery',
        subtitle: standardFee == 0.0
            ? 'Free on orders above ₹999 (3-5 business days)'
            : 'Standard courier delivery (3-5 business days)',
        fee: standardFee,
        estimatedDelivery: '3-5 Business Days',
        icon: Icons.local_shipping_outlined,
      ),
      const DeliveryOption(
        id: 'express',
        title: 'Express Delivery',
        subtitle: 'Priority dispatch with live tracking (Tomorrow by 6 PM)',
        fee: 99.0,
        estimatedDelivery: 'Tomorrow by 6:00 PM',
        icon: Icons.electric_bolt_rounded,
        isPopular: true,
      ),
      const DeliveryOption(
        id: 'priority_vip',
        title: 'VIP Same-Day Delivery',
        subtitle: 'Guaranteed ultra-fast delivery within 4-6 hours',
        fee: 149.0,
        estimatedDelivery: 'Today by 9:00 PM',
        icon: Icons.rocket_launch_rounded,
      ),
    ];
  }
}
