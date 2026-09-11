import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

AppException mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutException();

    case DioExceptionType.connectionError:
      return const NetworkException();

    case DioExceptionType.badResponse:
      return _mapStatusCode(exception.response?.statusCode);

    case DioExceptionType.cancel:
      return const NetworkException(message: 'The request was cancelled.');

    case DioExceptionType.badCertificate:
      return const NetworkException(
        message: 'A secure connection could not be established.',
      );

    case DioExceptionType.unknown:
      return const NetworkException();
  }
}

AppException _mapStatusCode(int? statusCode) {
  switch (statusCode) {
    case 400:
      return const BadRequestException(statusCode: 400);

    case 401:
      return const UnauthorizedException(statusCode: 401);

    case 403:
      return const ForbiddenException(statusCode: 403);

    case 404:
      return const NotFoundException(statusCode: 404);

    case 408:
      return const TimeoutException();

    case 500:
    case 502:
    case 503:
    case 504:
      return ServerException(statusCode: statusCode);

    default:
      return ServerException(statusCode: statusCode);
  }
}
