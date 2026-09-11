abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Unable to connect to the server.'});
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The request timed out. Please try again.',
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please log in again.',
    super.statusCode,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Something went wrong on the server.',
    super.statusCode,
  });
}

class BadRequestException extends AppException {
  const BadRequestException({
    super.message = 'The request could not be processed.',
    super.statusCode,
  });
}

class ParsingException extends AppException {
  const ParsingException({
    super.message = 'Unable to process the server response.',
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode,
  });
}
