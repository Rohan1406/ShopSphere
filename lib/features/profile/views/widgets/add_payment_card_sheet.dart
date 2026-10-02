import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

class AddPaymentCardSheet extends ConsumerStatefulWidget {
  const AddPaymentCardSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddPaymentCardSheet(),
    );
  }

  @override
  ConsumerState<AddPaymentCardSheet> createState() =>
      _AddPaymentCardSheetState();
}

class _AddPaymentCardSheetState extends ConsumerState<AddPaymentCardSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _monthCtrl;
  late final TextEditingController _yearCtrl;
  CardBrand _selectedBrand = CardBrand.visa;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController();
    _nameCtrl = TextEditingController(text: 'DEMO SHOPPER');
    _monthCtrl = TextEditingController(text: '12');
    _yearCtrl = TextEditingController(text: '28');
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;
    final raw = _numberCtrl.text.trim();
    final last4 = raw.length >= 4 ? raw.substring(raw.length - 4) : raw;

    ref
        .read(paymentMethodsControllerProvider.notifier)
        .addCard(
          PaymentCard(
            id: '',
            cardHolder: _nameCtrl.text.trim().toUpperCase(),
            cardNumberLast4: last4,
            brand: _selectedBrand,
            expiryMonth: _monthCtrl.text.trim(),
            expiryYear: _yearCtrl.text.trim(),
            isDefault: _isDefault,
          ),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card added securely!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add New Card',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 20, color: AppColors.border),

            // Card Brand selector
            const Text(
              'Card Network',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: CardBrand.values.map((brand) {
                final isSel = _selectedBrand == brand;
                return ChoiceChip(
                  label: Text(brand.displayName),
                  selected: isSel,
                  selectedColor: AppColors.primarySurface,
                  labelStyle: TextStyle(
                    color: isSel ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (sel) {
                    if (sel) setState(() => _selectedBrand = brand);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Card Number
            TextFormField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              maxLength: 16,
              decoration: const InputDecoration(
                labelText: 'Card Number *',
                hintText: '16-digit card number',
                prefixIcon: Icon(Icons.credit_card_rounded, size: 20),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().length < 4) {
                  return 'Enter valid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Cardholder Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name *',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter cardholder name'
                  : null,
            ),
            const SizedBox(height: 12),

            // Expiry & CVV
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _monthCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Month (MM) *',
                      counterText: '',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'MM' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(
                      labelText: 'Year (YY) *',
                      counterText: '',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'YY' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Set as Default Payment Method',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              value: _isDefault,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _isDefault = val),
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Card',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
