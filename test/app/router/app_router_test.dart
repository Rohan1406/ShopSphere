import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AppRouter authentication redirects', () {
    testWidgets('unauthenticated user is redirected to login', (tester) async {
      final router = _createRouter(
        const AuthUnauthenticated(),
        initialLocation: '/home',
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      expect(find.text('ShopSphere Login'), findsOneWidget);
    });

    testWidgets('authenticated user is redirected from login to home', (
      tester,
    ) async {
      final router = _createRouter(
        const AuthAuthenticated(),
        initialLocation: '/login',
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      expect(find.text('ShopSphere Home'), findsOneWidget);
    });

    testWidgets('authenticated user can access home', (tester) async {
      final router = _createRouter(
        const AuthAuthenticated(),
        initialLocation: '/home',
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      expect(find.text('ShopSphere Home'), findsOneWidget);
    });

    testWidgets('loading state redirects to startup', (tester) async {
      final router = _createRouter(
        const AuthLoading(),
        initialLocation: '/home',
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

GoRouter _createRouter(AuthState authState, {required String initialLocation}) {
  final isStartup = initialLocation == '/startup';
  final isLogin = initialLocation == '/login';
  final isAuthenticated = authState is AuthAuthenticated;
  final isLoading = authState is AuthInitial || authState is AuthLoading;

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
}
