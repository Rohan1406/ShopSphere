import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    return const AuthInitial();
  }

  Future<void> restoreSession() async {
    state = const AuthLoading();

    final result = await _authRepository.restoreSession();

    switch (result) {
      case Success(:final data):
        if (data == null) {
          state = const AuthUnauthenticated();
        } else {
          state = const AuthAuthenticated();
        }

      case Error(:final failure):
        state = AuthError(failure.message);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    switch (result) {
      case Success():
        state = const AuthAuthenticated();

      case Error(:final failure):
        state = AuthError(failure.message);
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();

    final result = await _authRepository.logout();

    switch (result) {
      case Success():
        state = const AuthUnauthenticated();

      case Error(:final failure):
        state = AuthError(failure.message);
    }
  }
}
