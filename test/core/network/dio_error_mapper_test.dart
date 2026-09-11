import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/network/dio_error_mapper.dart';

void main() {
  group('mapDioException', () {
    test('maps connection timeout to TimeoutException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = mapDioException(exception);

      expect(result, isA<TimeoutException>());
    });

    test('maps send timeout to TimeoutException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      final result = mapDioException(exception);

      expect(result, isA<TimeoutException>());
    });

    test('maps receive timeout to TimeoutException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      final result = mapDioException(exception);

      expect(result, isA<TimeoutException>());
    });

    test('maps transform timeout to TimeoutException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.transformTimeout,
      );

      final result = mapDioException(exception);

      expect(result, isA<TimeoutException>());
    });

    test('maps connection error to NetworkException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final result = mapDioException(exception);

      expect(result, isA<NetworkException>());
    });

    test('maps 401 to UnauthorizedException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final result = mapDioException(exception);

      expect(result, isA<UnauthorizedException>());
      expect(result.statusCode, 401);
    });

    test('maps 403 to ForbiddenException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );

      final result = mapDioException(exception);

      expect(result, isA<ForbiddenException>());
      expect(result.statusCode, 403);
    });

    test('maps 404 to NotFoundException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final result = mapDioException(exception);

      expect(result, isA<NotFoundException>());
      expect(result.statusCode, 404);
    });

    test('maps 500 to ServerException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final result = mapDioException(exception);

      expect(result, isA<ServerException>());
      expect(result.statusCode, 500);
    });

    test('maps 502 to ServerException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 502,
        ),
      );

      final result = mapDioException(exception);

      expect(result, isA<ServerException>());
      expect(result.statusCode, 502);
    });

    test('maps unknown errors to NetworkException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );

      final result = mapDioException(exception);

      expect(result, isA<NetworkException>());
    });
  });
}