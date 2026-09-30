import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/app.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/auth/views/pages/login_page.dart';

void main() {
  testWidgets('authenticated user is redirected to login after logout', (
    tester,
  ) async {
    final controller = _FakeAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(() => controller)],
        child: const ShopSphereApp(),
      ),
    );

    await tester.pump();

    // Initial state must be authenticated.
    expect(controller.currentState, isA<AuthAuthenticated>());

    expect(find.text('View Products'), findsOneWidget);

    // Logout.
    await tester.tap(find.byTooltip('Logout'));

    await tester.pumpAndSettle();

    // Verify logout was actually called.
    expect(controller.logoutCalled, isTrue);

    // Verify authentication state changed.
    expect(controller.currentState, isA<AuthUnauthenticated>());

    // Verify router redirected to login.
    expect(find.byType(LoginPage), findsOneWidget);

    expect(find.text('View Products'), findsNothing);
  });
}

class _FakeAuthController extends AuthController {
  bool logoutCalled = false;

  @override
  AuthState build() {
    return const AuthAuthenticated();
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalled = true;
    state = const AuthUnauthenticated();
    return const Success(null);
  }

  AuthState get currentState => state;
}
