import 'package:dio/dio.dart';
import 'package:shopsphere/core/config/app_config.dart';
import 'package:shopsphere/core/network/interceptors/auth_interceptor.dart';


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
      ) {
    dio.interceptors.add(AuthInterceptor());
  }

  final Dio dio;
}
