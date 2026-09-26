import 'package:dio/dio.dart';

import '../config/app_config.dart';

class DioClient {
  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio dio;

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
