import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

class ChangePasswordModalSheet extends StatefulWidget {
  const ChangePasswordModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ChangePasswordModalSheet(),
    );
  }

  @override
  State<ChangePasswordModalSheet> createState() =>
      _ChangePasswordModalSheetState();
}

class _ChangePasswordModalSheetState extends State<ChangePasswordModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _oldPassCtrl;
  late final TextEditingController _newPassCtrl;
  late final TextEditingController _confirmPassCtrl;
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _oldPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully!'),
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
              'Change Password',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const Divider(height: 20, color: AppColors.border),

            // Old Password
            TextFormField(
              controller: _oldPassCtrl,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Current Password *',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter current password' : null,
            ),
            const SizedBox(height: 12),

            // New Password
            TextFormField(
              controller: _newPassCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: 'New Password (min 8 chars) *',
                prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Confirm Password
            TextFormField(
              controller: _confirmPassCtrl,
              obscureText: _obscureNew,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password *',
                prefixIcon: Icon(Icons.check_circle_outline_rounded, size: 20),
              ),
              validator: (v) {
                if (v != _newPassCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Password',
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
