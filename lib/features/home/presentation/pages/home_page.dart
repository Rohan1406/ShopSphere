import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _logout(WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoggingOut = authState is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(
            onPressed: isLoggingOut ? null : () => _logout(ref),
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('ShopSphere Home')),
    );
  }
}
