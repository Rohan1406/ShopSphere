import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/home/views/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('shows ShopSphere home content', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: HomePage())),
      );

      expect(find.text('ShopSphere'), findsOneWidget);
      expect(find.text('View Products'), findsOneWidget);
      expect(find.byTooltip('Logout'), findsOneWidget);
    });

    testWidgets('calls logout when logout button is tapped', (tester) async {
      final controller = _FakeAuthController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith(() => controller)],
          child: const MaterialApp(home: HomePage()),
        ),
      );

      await tester.tap(find.byTooltip('Logout'));
      await tester.pump();

      expect(controller.logoutCalled, isTrue);
    });

    testWidgets('disables logout while logging out', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              () => _FakeAuthController(initialState: const AuthLoading()),
            ),
          ],
          child: const MaterialApp(home: HomePage()),
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

class _FakeAuthController extends AuthController {
  _FakeAuthController({AuthState initialState = const AuthAuthenticated()})
    : _initialState = initialState;

  final AuthState _initialState;
  bool logoutCalled = false;

  @override
  AuthState build() {
    return _initialState;
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalled = true;
    return const Success(null);
  }
}
