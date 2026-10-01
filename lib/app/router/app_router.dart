import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/auth/views/pages/login_page.dart';
import 'package:shopsphere/features/cart/views/pages/cart_page.dart';
import 'package:shopsphere/features/home/views/pages/home_page.dart';
import 'package:shopsphere/features/products/views/pages/product_details_page.dart';
import 'package:shopsphere/features/products/views/pages/products_page.dart';
import 'package:shopsphere/features/profile/views/pages/profile_page.dart';

import '../startup/auth_startup_screen.dart';
import 'auth_router_refresh.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRouterRefresh = AuthRouterRefresh(ref);

  ref.onDispose(authRouterRefresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/startup',
    refreshListenable: authRouterRefresh,

    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      final isStartup = location == '/startup';
      final isLogin = location == '/login';

      final isAuthenticated = authState is AuthAuthenticated;

      final isLoading = authState is AuthInitial || authState is AuthLoading;

      if (isLoading) {
        return isStartup ? null : '/startup';
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        if (isLogin) return null;
        final target = state.uri.toString();
        if (target.isNotEmpty && target != '/' && target != '/startup' && target != '/login') {
          return '/login?from=${Uri.encodeComponent(target)}';
        }
        return '/login';
      }

      if (isAuthenticated) {
        if (isLogin) {
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty && from.startsWith('/')) {
            return from;
          }
          return '/home';
        }
        if (isStartup) {
          return '/home';
        }

        return null;
      }

      return '/startup';
    },

    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/startup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AuthStartupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.04),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // Main tabbed shell with persistent bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return const HomePage();
                },
              ),
            ],
          ),

          // Branch 1: Explore / Catalog
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  return ProductsPage(initialCategory: category);
                },
              ),
            ],
          ),

          // Branch 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) {
                  return const CartPage();
                },
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfilePage();
                },
              ),
            ],
          ),
        ],
      ),

      // Product Details Page (fullscreen)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/products/:id',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailsPage(productId: productId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.08),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    ],
  );
});
