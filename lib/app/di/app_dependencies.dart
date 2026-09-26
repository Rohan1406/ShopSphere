import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/network/interceptors/auth_interceptor.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';

final appDioProvider = Provider((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenManager = ref.watch(tokenManagerProvider);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient.dio);

  final interceptor = AuthInterceptor(
    dio: dioClient.dio,
    tokenManager: tokenManager,
    refreshToken: () async {
      final refreshToken = await tokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      try {
        final session = await authRemoteDataSource.refreshSession(
          refreshToken: refreshToken,
        );

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

  dioClient.addInterceptor(interceptor);

  return dioClient.dio;
});
