import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/app/app.dart';
import 'package:shopsphere/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

void main() {
  testWidgets('authenticated user is redirected to login after logout', (
    tester,
  ) async {
    final notifier = _FakeAuthNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authNotifierProvider.overrideWith(() => notifier)],
        child: const ShopSphereApp(),
      ),
    );

    await tester.pump();

    // Initial state must be authenticated.
    expect(notifier.currentState, isA<AuthAuthenticated>());

    expect(find.text('ShopSphere Home'), findsOneWidget);

    // Logout.
    await tester.tap(find.byTooltip('Logout'));

    await tester.pumpAndSettle();

    // Verify logout was actually called.
    expect(notifier.logoutCalled, isTrue);

    // Verify authentication state changed.
    expect(notifier.currentState, isA<AuthUnauthenticated>());

    // Verify router redirected to login.
    expect(find.byType(LoginPage), findsOneWidget);

    expect(find.text('ShopSphere Home'), findsNothing);
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  bool logoutCalled = false;

  @override
  AuthState build() {
    return const AuthAuthenticated();
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;

    state = const AuthUnauthenticated();
  }

  AuthState get currentState => state;
}
