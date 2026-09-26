import 'package:shopsphere/core/result/result.dart';

import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<AuthSession>> refreshSession({required String refreshToken});

  Future<Result<void>> logout();
}
