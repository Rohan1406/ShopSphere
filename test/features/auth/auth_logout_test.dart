import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/core/errors/failure.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AuthNotifier logout', () {
    test('changes state to unauthenticated when logout succeeds', () async {
      final repository = _FakeAuthRepository();

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);

      expect(container.read(authNotifierProvider), isA<AuthInitial>());

      await notifier.logout();

      expect(repository.logoutCalled, isTrue);

      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });

    test('changes state to error when logout fails', () async {
      final repository = _FakeAuthRepository(
        logoutResult: const Error<void>(Failure(message: 'Unable to logout.')),
      );

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      addTearDown(container.dispose);

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.logout();

      final state = container.read(authNotifierProvider);

      expect(state, isA<AuthError>());

      expect((state as AuthError).message, 'Unable to logout.');
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.logoutResult = const Success<void>(null)});

  final Result<void> logoutResult;

  bool logoutCalled = false;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession?>> restoreSession() {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> refreshSession({required String refreshToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalled = true;
    return logoutResult;
  }
}
