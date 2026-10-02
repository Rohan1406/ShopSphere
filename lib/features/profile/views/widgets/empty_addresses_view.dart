import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';

class EmptyAddressesView extends StatelessWidget {
  final VoidCallback onAddAddress;

  const EmptyAddressesView({super.key, required this.onAddAddress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved addresses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your delivery addresses for express 1-tap checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAddAddress,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add New Address'),
            ),
          ],
        ),
      ),
    );
  }
}
