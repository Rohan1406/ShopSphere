import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio);
  });

  group('login', () {
    test(
      'maps connection error to NetworkException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            ApiEndpoints.login,
            data: {
              'email': 'user@example.com',
              'password': 'password',
            },
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiEndpoints.login,
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(
          () => dataSource.login(
            email: 'user@example.com',
            password: 'password',
          ),
          throwsA(
            isA<NetworkException>(),
          ),
        );
      },
    );

    test(
      'maps timeout to TimeoutException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            ApiEndpoints.login,
            data: {
              'email': 'user@example.com',
              'password': 'password',
            },
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiEndpoints.login,
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        expect(
          () => dataSource.login(
            email: 'user@example.com',
            password: 'password',
          ),
          throwsA(
            isA<TimeoutException>(),
          ),
        );
      },
    );

    test(
      'maps 401 response to UnauthorizedException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            ApiEndpoints.login,
            data: {
              'email': 'user@example.com',
              'password': 'password',
            },
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiEndpoints.login,
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: ApiEndpoints.login,
              ),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => dataSource.login(
            email: 'user@example.com',
            password: 'password',
          ),
          throwsA(
            isA<UnauthorizedException>(),
          ),
        );
      },
    );
  });

  group('refreshSession', () {
    test(
      'maps connection error to NetworkException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            ApiEndpoints.refreshToken,
            data: {
              'refresh_token': 'refresh-token',
            },
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiEndpoints.refreshToken,
            ),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(
          () => dataSource.refreshSession(
            refreshToken: 'refresh-token',
          ),
          throwsA(
            isA<NetworkException>(),
          ),
        );
      },
    );

    test(
      'maps 401 response to UnauthorizedException',
      () async {
        when(
          () => dio.post<Map<String, dynamic>>(
            ApiEndpoints.refreshToken,
            data: {
              'refresh_token': 'refresh-token',
            },
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: ApiEndpoints.refreshToken,
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: ApiEndpoints.refreshToken,
              ),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => dataSource.refreshSession(
            refreshToken: 'refresh-token',
          ),
          throwsA(
            isA<UnauthorizedException>(),
          ),
        );
      },
    );
  });
}