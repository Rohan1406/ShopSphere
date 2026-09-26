import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/network/interceptors/auth_interceptor.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    return accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter({this.returnUnauthorizedOnce = false});

  final bool returnUnauthorizedOnce;

  int requestCount = 0;
  final List<String?> authorizationHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;

    authorizationHeaders.add(options.headers['Authorization'] as String?);

    if (returnUnauthorizedOnce && requestCount == 1) {
      return ResponseBody.fromString(
        '{"message":"Unauthorized"}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      '{"message":"Success"}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    late Dio dio;
    late FakeTokenStorage storage;
    late TokenManager tokenManager;
    late FakeHttpAdapter adapter;

    setUp(() {
      storage = FakeTokenStorage();
      tokenManager = TokenManager(storage);

      adapter = FakeHttpAdapter();

      dio = Dio(BaseOptions(baseUrl: 'https://example.com'));

      dio.httpClientAdapter = adapter;

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenManager: tokenManager,
          refreshToken: () async {
            await storage.saveTokens(
              accessToken: 'new-access-token',
              refreshToken: 'new-refresh-token',
            );

            return 'new-access-token';
          },
        ),
      );
    });

    test('adds access token to request', () async {
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      await dio.get('/products');

      expect(adapter.authorizationHeaders.first, 'Bearer access-token');
    });

    test('refreshes and retries after 401', () async {
      adapter = FakeHttpAdapter(returnUnauthorizedOnce: true);

      dio.httpClientAdapter = adapter;

      await storage.saveTokens(
        accessToken: 'expired-token',
        refreshToken: 'refresh-token',
      );

      final response = await dio.get('/products');

      expect(response.statusCode, 200);
      expect(adapter.requestCount, 2);

      expect(adapter.authorizationHeaders[0], 'Bearer expired-token');

      expect(adapter.authorizationHeaders[1], 'Bearer new-access-token');
    });

    test('does not refresh a request already marked as retried', () async {
      await storage.saveTokens(
        accessToken: 'expired-token',
        refreshToken: 'refresh-token',
      );

      var refreshCount = 0;

      dio.interceptors.clear();

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenManager: tokenManager,
          refreshToken: () async {
            refreshCount++;
            return 'new-access-token';
          },
        ),
      );

      final response = await dio.get(
        '/products',
        options: Options(extra: {'retried': true}),
      );

      expect(response.statusCode, 200);
      expect(refreshCount, 0);
    });
  });
}
