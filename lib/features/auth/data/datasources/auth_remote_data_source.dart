import 'package:dio/dio.dart';
import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/dio_error_mapper.dart';
import 'package:shopsphere/features/auth/data/models/auth_session_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });
  Future<AuthSessionModel> refreshSession({required String refreshToken});

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      if (data == null) {
        throw const ParsingException(
          message: 'Authentication response was empty.',
        );
      }

      return AuthSessionModel.fromJson(data);
    } on DioException catch (exception) {
      throw mapDioException(exception);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ParsingException(
        message: 'Unable to process authentication response: $error',
      );
    }
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSessionModel> refreshSession({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skip_auth_refresh': true}),
      );
      final data = response.data;

      if (data == null) {
        throw const ParsingException(message: 'Refresh response was empty.');
      }
      return AuthSessionModel.fromJson(data);
    } on DioException catch(exception) {
      throw mapDioException(exception);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ParsingException(
        message: 'Unable to process refresh response:$error',
      );
    }
  }
}
