import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/payment_method.dart';

class AddUpiSheet extends ConsumerStatefulWidget {
  const AddUpiSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddUpiSheet(),
    );
  }

  @override
  ConsumerState<AddUpiSheet> createState() => _AddUpiSheetState();
}

class _AddUpiSheetState extends ConsumerState<AddUpiSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _upiCtrl;
  String _provider = 'Google Pay';

  @override
  void initState() {
    super.initState();
    _upiCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _upiCtrl.dispose();
    super.dispose();
  }

  void _saveUpi() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(paymentMethodsControllerProvider.notifier)
        .addUpi(
          UpiPayment(
            id: '',
            upiId: _upiCtrl.text.trim().toLowerCase(),
            providerName: _provider,
          ),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID added successfully!'),
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
              'Add UPI ID',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(height: 20, color: AppColors.border),

            // App Provider
            const Text(
              'UPI App',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Google Pay', 'PhonePe', 'Paytm', 'BHIM UPI'].map((p) {
                final isSel = _provider == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSel,
                  selectedColor: AppColors.primarySurface,
                  labelStyle: TextStyle(
                    color: isSel ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (sel) {
                    if (sel) setState(() => _provider = p);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _upiCtrl,
              decoration: const InputDecoration(
                labelText: 'UPI ID / VPA *',
                hintText: 'e.g. mobile@upi or name@okhdfcbank',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (v) {
                if (v == null || !v.contains('@')) {
                  return 'Enter valid UPI ID (e.g. name@bank)';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveUpi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verify & Save UPI ID',
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
