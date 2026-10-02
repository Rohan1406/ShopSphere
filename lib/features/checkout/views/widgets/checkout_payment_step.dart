import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/checkout/controllers/checkout_controller.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';
import 'package:shopsphere/features/profile/views/widgets/add_payment_card_sheet.dart';
import 'package:shopsphere/features/profile/views/widgets/add_upi_sheet.dart';

class CheckoutPaymentStep extends ConsumerWidget {
  const CheckoutPaymentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsState = ref.watch(paymentMethodsControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final checkoutNotifier = ref.read(checkoutControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Spacer(),
            Text(
              'Step 2 of 3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 1. Credit & Debit Cards Section
        _PaymentCategoryHeader(
          title: 'Credit & Debit Cards',
          icon: Icons.credit_card_rounded,
          actionLabel: '+ Add Card',
          onAction: () => AddPaymentCardSheet.show(context),
        ),
        const SizedBox(height: 8),

        if (paymentMethodsState.cards.isEmpty) ...[
          _EmptyCategoryPlaceholder(
            message:
                'No saved cards found. Add a credit or debit card for instant payment.',
            onAdd: () => AddPaymentCardSheet.show(context),
            buttonText: 'Add New Card',
          ),
        ] else ...[
          for (final card in paymentMethodsState.cards) ...[
            _CardSelectionTile(
              card: card,
              isSelected:
                  checkoutState.paymentType == PaymentMethodType.card &&
                  checkoutState.selectedCard?.id == card.id,
              onSelect: () => checkoutNotifier.selectCard(card),
            ),
            const SizedBox(height: 10),
          ],
        ],

        const SizedBox(height: 20),

        // 2. UPI Applications Section
        _PaymentCategoryHeader(
          title: 'UPI (GPay, PhonePe, Paytm)',
          icon: Icons.account_balance_wallet_rounded,
          actionLabel: '+ Add UPI',
          onAction: () => AddUpiSheet.show(context),
        ),
        const SizedBox(height: 8),

        if (paymentMethodsState.upiList.isEmpty) ...[
          _EmptyCategoryPlaceholder(
            message:
                'No UPI IDs saved. Link your Google Pay, PhonePe or Paytm VPA.',
            onAdd: () => AddUpiSheet.show(context),
            buttonText: 'Add UPI ID',
          ),
        ] else ...[
          for (final upi in paymentMethodsState.upiList) ...[
            _UpiSelectionTile(
              upi: upi,
              isSelected:
                  checkoutState.paymentType == PaymentMethodType.upi &&
                  checkoutState.selectedUpi?.id == upi.id,
              onSelect: () => checkoutNotifier.selectUpi(upi),
            ),
            const SizedBox(height: 10),
          ],
        ],

        const SizedBox(height: 20),

        // 3. Cash on Delivery Section
        const _PaymentCategoryHeader(
          title: 'Pay on Delivery',
          icon: Icons.local_atm_rounded,
        ),
        const SizedBox(height: 8),

        _CodSelectionTile(
          isSelected: checkoutState.paymentType == PaymentMethodType.cod,
          onSelect: () => checkoutNotifier.selectCod(),
        ),

        const SizedBox(height: 24),

        // Security Assurance Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: AppColors.success),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'End-to-End 256-bit Bank Grade Encryption. Your payment credentials are never stored on public servers.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PaymentCategoryHeader({
    required this.title,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CardSelectionTile extends StatelessWidget {
  final PaymentCard card;
  final bool isSelected;
  final VoidCallback onSelect;

  const _CardSelectionTile({
    required this.card,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Card Mini Visual Preview
            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                gradient: card.brand.gradient,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  card.brand.displayName.substring(
                    0,
                    card.brand.displayName.length > 4 ? 4 : null,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card.brand.displayName} ending in ${card.cardNumberLast4}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Expires ${card.formattedExpiry} • ${card.cardHolder}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (card.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpiSelectionTile extends StatelessWidget {
  final UpiPayment upi;
  final bool isSelected;
  final VoidCallback onSelect;

  const _UpiSelectionTile({
    required this.upi,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    Color providerColor = AppColors.primary;
    if (upi.providerName.contains('PhonePe')) {
      providerColor = const Color(0xFF5F259F);
    } else if (upi.providerName.contains('Paytm')) {
      providerColor = const Color(0xFF002970);
    } else if (upi.providerName.contains('Google')) {
      providerColor = const Color(0xFF1A73E8);
    }

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                color: providerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: providerColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 18,
                  color: providerColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upi.providerName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    upi.upiId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (upi.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CodSelectionTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onSelect;

  const _CodSelectionTile({required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            Container(
              width: 44,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.handshake_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pay in cash or scan delivery partner QR at your doorstep',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onAdd;
  final String buttonText;

  const _EmptyCategoryPlaceholder({
    required this.message,
    required this.onAdd,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
