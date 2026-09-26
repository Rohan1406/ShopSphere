import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  AuthSessionModel({required super.accessToken, required super.refreshToken});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
