import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/auth/models/auth_session.dart';
import 'package:shopsphere/features/auth/views/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets(
      'shows validation errors when submitted empty',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginPage(),
            ),
          ),
        );

        await tester.tap(
          find.widgetWithText(FilledButton, 'Login'),
        );

        await tester.pump();

        expect(
          find.text('Enter your email'),
          findsOneWidget,
        );

        expect(
          find.text('Enter your password'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows invalid email validation error',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginPage(),
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'invalid-email',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          'password123',
        );

        await tester.tap(
          find.widgetWithText(FilledButton, 'Login'),
        );

        await tester.pump();

        expect(
          find.text('Enter a valid email'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'calls login when form is valid',
      (tester) async {
        final controller = _FakeAuthController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(
                () => controller,
              ),
            ],
            child: const MaterialApp(
              home: LoginPage(),
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'rohan@example.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          'password123',
        );

        await tester.tap(
          find.widgetWithText(FilledButton, 'Login'),
        );

        await tester.pump();

        expect(controller.loginCalled, isTrue);
        expect(controller.email, 'rohan@example.com');
        expect(controller.password, 'password123');
      },
    );

    testWidgets(
      'shows loading state while login is in progress',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(
                () => _FakeAuthController(
                  initialState: const AuthLoading(),
                ),
              ),
            ],
            child: const MaterialApp(
              home: LoginPage(),
            ),
          ),
        );

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        expect(
          find.widgetWithText(FilledButton, 'Login'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'calls login with demo credentials when Quick Demo Login is tapped',
      (tester) async {
        final controller = _FakeAuthController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(
                () => controller,
              ),
            ],
            child: const MaterialApp(
              home: LoginPage(),
            ),
          ),
        );

        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Quick Demo Login'),
        );

        await tester.pump();

        expect(controller.loginCalled, isTrue);
        expect(controller.email, 'demo@shopsphere.com');
        expect(controller.password, 'demo123456');
      },
    );
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController({
    AuthState initialState = const AuthInitial(),
  }) : _initialState = initialState;

  final AuthState _initialState;

  bool loginCalled = false;
  String? email;
  String? password;

  @override
  AuthState build() {
    return _initialState;
  }

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    this.email = email;
    this.password = password;
    return const Success(
      AuthSession(accessToken: 'mock_token', refreshToken: 'mock_refresh'),
    );
  }
}