import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

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
      ref.read(authNotifierProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) {
        return;
      }

      switch (next) {
        case AuthAuthenticated():
          context.go('/home');
        case AuthUnauthenticated():
        case AuthError():
          context.go('/login');
        case AuthInitial():
        case AuthLoading():
          break;
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
