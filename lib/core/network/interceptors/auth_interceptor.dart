import 'package:dio/dio.dart';

import '../../storage/token_manager.dart';
import '../auth_refresh_coordinator.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenManager tokenManager,
    required Future<String?> Function() refreshToken,
  })  : _dio = dio,
        _tokenManager = tokenManager,
        _refreshToken = refreshToken;

  final Dio _dio;
  final TokenManager _tokenManager;
  final Future<String?> Function() _refreshToken;

  final AuthRefreshCoordinator _refreshCoordinator =
      AuthRefreshCoordinator();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenManager.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;

    // Only handle 401 responses.
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Never refresh the refresh request itself.
    if (request.extra['skip_auth_refresh'] == true) {
      handler.next(err);
      return;
    }

    // Never retry the same request more than once.
    if (request.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshCoordinator.refresh(
      _refreshToken,
    );

    if (newAccessToken == null || newAccessToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final retryOptions = request.copyWith(
        headers: {
          ...request.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
        extra: {
          ...request.extra,
          'retried': true,
        },
      );

      final response = await _dio.fetch<dynamic>(
        retryOptions,
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }
}