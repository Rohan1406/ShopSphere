import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/startup/auth_startup_screen.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

final appRouterProvider = Provider((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/startup',
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isStartup = location == '/startup';
      final isLogin = location == '/login';
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading = authState is AuthInitial || authState is AuthLoading;

      if (isLoading) {
        return isStartup ? null : '/startup';
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isLogin ? null : '/login';
      }

      if (isAuthenticated) {
        if (isLogin || isStartup) {
          return '/home';
        }
        return null;
      }
      return '/startup';
    },
    routes: [
      GoRoute(
        path: '/startup',
        builder: (context, state) {
          return const AuthStartupScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('ShopSphere Login')));
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('ShopSphere Home')));
        },
      ),
    ],
  );
});
