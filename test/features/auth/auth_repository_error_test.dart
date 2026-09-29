import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/auth_session_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';

void main() {
  late FakeAuthRemoteDataSource dataSource;
  late FakeTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = FakeAuthRemoteDataSource();
    tokenStorage = FakeTokenStorage();

    final tokenManager = TokenManager(tokenStorage);

    repository = AuthRepositoryImpl(dataSource, tokenManager);
  });

  group('login', () {
    test('returns Success and saves tokens when login succeeds', () async {
      dataSource.loginResult = AuthSessionModel(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      final result = await repository.login(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, isA<Success<AuthSession>>());

      expect(tokenStorage.savedAccessToken, 'access-token');

      expect(tokenStorage.savedRefreshToken, 'refresh-token');
    });

    test('returns Error when login throws NetworkException', () async {
      dataSource.loginException = const NetworkException(
        message: 'No internet connection.',
      );

      final result = await repository.login(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, isA<Error<AuthSession>>());

      final error = result as Error<AuthSession>;

      expect(error.failure.message, 'No internet connection.');
    });

    test('preserves status code for unauthorized login failure', () async {
      dataSource.loginException = const UnauthorizedException(
        message: 'Invalid credentials.',
        statusCode: 401,
      );

      final result = await repository.login(
        email: 'user@example.com',
        password: 'password',
      );

      expect(result, isA<Error<AuthSession>>());

      final error = result as Error<AuthSession>;

      expect(error.failure.message, 'Invalid credentials.');

      expect(error.failure.statusCode, 401);
    });
  });

  group('refreshSession', () {
    test('returns Success and saves refreshed tokens', () async {
      dataSource.refreshResult = AuthSessionModel(
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      );

      final result = await repository.refreshSession(
        refreshToken: 'old-refresh-token',
      );

      expect(result, isA<Success<AuthSession>>());

      expect(tokenStorage.savedAccessToken, 'new-access-token');

      expect(tokenStorage.savedRefreshToken, 'new-refresh-token');
    });

    test('returns Error when refresh throws NetworkException', () async {
      dataSource.refreshException = const NetworkException(
        message: 'Refresh failed.',
      );

      final result = await repository.refreshSession(
        refreshToken: 'refresh-token',
      );

      expect(result, isA<Error<AuthSession>>());

      final error = result as Error<AuthSession>;

      expect(error.failure.message, 'Refresh failed.');
    });
  });
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  AuthSessionModel? loginResult;
  AppException? loginException;

  AuthSessionModel? refreshResult;
  AppException? refreshException;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    if (loginException != null) {
      throw loginException!;
    }

    return loginResult!;
  }

  @override
  Future<AuthSessionModel> refreshSession({
    required String refreshToken,
  }) async {
    if (refreshException != null) {
      throw refreshException!;
    }

    return refreshResult!;
  }

  @override
  Future<void> logout() async {}
}

class FakeTokenStorage implements TokenStorage {
  String? savedAccessToken;
  String? savedRefreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    savedAccessToken = accessToken;
    savedRefreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    return savedAccessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return savedRefreshToken;
  }

  @override
  Future<void> clear() async {
    savedAccessToken = null;
    savedRefreshToken = null;
  }
}
