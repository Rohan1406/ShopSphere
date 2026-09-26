import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/app/startup/auth_startup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/startup',
  routes: [
    GoRoute(
      path: '/startup',
      builder: (context, state) {
        return const AuthStartupScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text('ShopSphere Home')));
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const Scaffold(body: Center(child: Text('ShopSphere Login')));
      },
    ),
  ],
);
