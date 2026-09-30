import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';

class AuthStartupScreen extends ConsumerStatefulWidget {
  const AuthStartupScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthStartupScreen();
}

class _AuthStartupScreen extends ConsumerState<AuthStartupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authControllerProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
