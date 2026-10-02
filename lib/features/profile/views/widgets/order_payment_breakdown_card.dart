import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/models/order.dart';

class OrderPaymentBreakdownCard extends StatelessWidget {
  final Order order;

  const OrderPaymentBreakdownCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Items Subtotal',
            '₹${order.subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Delivery Fee',
            order.shippingFee == 0
                ? 'FREE'
                : '₹${order.shippingFee.toStringAsFixed(0)}',
            isFree: order.shippingFee == 0,
          ),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Coupon Discount',
              '-₹${order.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Paid via ${order.paymentMethod}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isFree = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isFree
                ? AppColors.success
                : (isDiscount ? AppColors.success : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
