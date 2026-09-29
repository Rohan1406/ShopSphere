import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';
import 'package:shopsphere/features/home/presentation/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('shows ShopSphere home content', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: HomePage())),
      );

      expect(find.text('ShopSphere'), findsOneWidget);

      expect(find.text('ShopSphere Home'), findsOneWidget);

      expect(find.byTooltip('Logout'), findsOneWidget);
    });

    testWidgets('calls logout when logout button is tapped', (tester) async {
      final notifier = _FakeAuthNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authNotifierProvider.overrideWith(() => notifier)],
          child: MaterialApp(home: HomePage()),
        ),
      );

      await tester.tap(find.byTooltip('Logout'));

      await tester.pump();

      expect(notifier.logoutCalled, isTrue);
    });

    testWidgets('disables logout while logging out', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(initialState: const AuthLoading()),
            ),
          ],
          child: MaterialApp(home: HomePage()),
        ),
      );

      final logoutButton = find.byIcon(Icons.logout);

      expect(logoutButton, findsOneWidget);

      final iconButton = tester.widget<IconButton>(
        find.ancestor(of: logoutButton, matching: find.byType(IconButton)),
      );

      expect(iconButton.onPressed, isNull);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({AuthState initialState = const AuthAuthenticated()})
    : _initialState = initialState;

  final AuthState _initialState;

  bool logoutCalled = false;

  @override
  AuthState build() {
    return _initialState;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}
