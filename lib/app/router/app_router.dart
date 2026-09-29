import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../startup/auth_startup_screen.dart';
import 'auth_router_refresh.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRouterRefresh = AuthRouterRefresh(ref);

  ref.onDispose(authRouterRefresh.dispose);

  return GoRouter(
    initialLocation: '/startup',
    refreshListenable: authRouterRefresh,

    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
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
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomePage();
        },
      ),
    ],
  );
});
