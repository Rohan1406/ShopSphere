import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/errors/failure.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/dio_error_mapper.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/features/auth/models/auth_session.dart';

// ==========================================
// AUTH STATE
// ==========================================

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ==========================================
// AUTH CONTROLLER PROVIDER
// ==========================================

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Alias for backwards compatibility with existing router & widgets
final authNotifierProvider = authControllerProvider;

// ==========================================
// AUTH CONTROLLER
// ==========================================

class AuthController extends Notifier<AuthState> {
  late final TokenManager _tokenManager;
  late final Dio _dio;

  @override
  AuthState build() {
    _tokenManager = ref.watch(tokenManagerProvider);
    _dio = ref.watch(dioProvider);
    return const AuthInitial();
  }

  /// Restores session on application startup
  Future<Result<AuthSession?>> restoreSession() async {
    state = const AuthLoading();

    try {
      final accessToken = await _tokenManager.getAccessToken();
      final refreshToken = await _tokenManager.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        state = const AuthUnauthenticated();
        return const Success(null);
      }

      final hasValidToken = await _tokenManager.hasValidAccessToken();
      if (!hasValidToken) {
        final refreshedResult = await refreshSession(
          refreshToken: refreshToken,
        );
        return switch (refreshedResult) {
          Success(:final data) => () {
            state = const AuthAuthenticated();
            return Success<AuthSession?>(data);
          }(),
          Error(:final failure) => () {
            state = AuthError(failure.message);
            return Error<AuthSession?>(failure);
          }(),
        };
      }

      state = const AuthAuthenticated();
      return Success(
        AuthSession(accessToken: accessToken, refreshToken: refreshToken),
      );
    } catch (_) {
      const failure = Failure(message: 'Unable to restore the authentication');
      state = const AuthError('Unable to restore the authentication');
      return const Error(failure);
    }
  }

  /// User login with email and password
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data == null) {
        throw const ParsingException(
          message: 'Authentication response was empty.',
        );
      }

      final session = AuthSession.fromJson(data);
      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      state = const AuthAuthenticated();
      return Success(session);
    } on DioException catch (exception) {
      final mappedException = mapDioException(exception);

      // Offline mock fallback: if network is unreachable, permit demo login
      if (mappedException is NetworkException ||
          mappedException is TimeoutException) {
        final mockToken = DummyData.generateMockJwt(email: email);
        final mockSession = AuthSession(
          accessToken: mockToken,
          refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
        );
        await _tokenManager.saveTokens(
          accessToken: mockSession.accessToken,
          refreshToken: mockSession.refreshToken,
        );
        state = const AuthAuthenticated();
        return Success(mockSession);
      }

      final failure = Failure(
        message: mappedException.message,
        statusCode: mappedException.statusCode,
      );
      state = AuthError(failure.message);
      return Error(failure);
    } on AppException catch (exception) {
      final failure = Failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
      state = AuthError(failure.message);
      return Error(failure);
    } catch (error) {
      // Offline fallback
      final mockToken = DummyData.generateMockJwt(email: email);
      final mockSession = AuthSession(
        accessToken: mockToken,
        refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _tokenManager.saveTokens(
        accessToken: mockSession.accessToken,
        refreshToken: mockSession.refreshToken,
      );
      state = const AuthAuthenticated();
      return Success(mockSession);
    }
  }

  /// Token refresh mechanism
  Future<Result<AuthSession>> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skip_auth_refresh': true}),
      );

      final data = response.data;
      if (data == null) {
        throw const ParsingException(message: 'Refresh response was empty.');
      }

      final session = AuthSession.fromJson(data);
      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return Success(session);
    } on DioException catch (exception) {
      final mappedException = mapDioException(exception);
      final failure = Failure(
        message: mappedException.message,
        statusCode: mappedException.statusCode,
      );
      return Error(failure);
    } on AppException catch (exception) {
      final failure = Failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
      return Error(failure);
    } catch (error) {
      final failure = Failure(message: 'Unable to process refresh: $error');
      return Error(failure);
    }
  }

  /// Logout and session cleanup
  Future<Result<void>> logout() async {
    state = const AuthLoading();

    try {
      await _tokenManager.clear();
      state = const AuthUnauthenticated();
      return const Success(null);
    } on AppException catch (exception) {
      final failure = Failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
      state = AuthError(failure.message);
      return Error(failure);
    } catch (error) {
      await _tokenManager.clear();
      state = const AuthUnauthenticated();
      return const Success(null);
    }
  }
}
