import 'package:dio/dio.dart';
import 'package:shopsphere/core/network/interceptors/auth_interceptor.dart';

import 'api_endpoints.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(AuthInterceptor());
  }

  final Dio dio;
}
