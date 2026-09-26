import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/errors/failure.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenManager);

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return Success(session);
    } on AppException catch (exception) {
      return Error(_mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    try {
      final accessToken = await _tokenManager.getAccessToken();
      final refreshToken = await _tokenManager.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return const Success(null);
      }

      if (!await _tokenManager.hasValidAccessToken()) {
        final refreshedResult = await refreshSession(
          refreshToken: refreshToken,
        );
        return switch (refreshedResult) {
          Success(:final data) => Success<AuthSession?>(data),
          Error(:final failure) => Error<AuthSession?>(failure),
        };
      }

      return Success(
        AuthSession(accessToken: accessToken, refreshToken: refreshToken),
      );
    } catch (exception) {
      return Error(Failure(message: 'Unable to restore the authentication'));
    }
  }

  @override
  Future<Result<AuthSession>> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final session = await _remoteDataSource.refreshSession(
        refreshToken: refreshToken,
      );

      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return Success(session);
    } on AppException catch (exception) {
      return Error(_mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();

      return const Success(null);
    } on AppException catch (exception) {
      return Error(_mapExceptionToFailure(exception));
    }
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return Failure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }
}
