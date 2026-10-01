import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/interceptors/auth_interceptor.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/features/auth/models/auth_session.dart';

final appDioProvider = Provider((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenManager = ref.watch(tokenManagerProvider);

  final interceptor = AuthInterceptor(
    dio: dioClient.dio,
    tokenManager: tokenManager,
    refreshToken: () async {
      final refreshToken = await tokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      try {
        final response = await dioClient.dio.post<Map<String, dynamic>>(
          ApiEndpoints.refreshToken,
          data: {'refresh_token': refreshToken},
          options: Options(extra: {'skip_auth_refresh': true}),
        );

        final data = response.data;
        if (data == null) {
          await tokenManager.clear();
          return null;
        }

        final session = AuthSession.fromJson(data);
        await tokenManager.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );

        return session.accessToken;
      } catch (_) {
        await tokenManager.clear();
        return null;
      }
    },
  );

  if (!dioClient.dio.interceptors.any((i) => i is AuthInterceptor)) {
    dioClient.addInterceptor(interceptor);
  }

  return dioClient.dio;
});
