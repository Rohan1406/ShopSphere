class AuthSession {
  final String accessToken;
  final String refreshToken;

  const AuthSession({required this.accessToken, required this.refreshToken});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }

  AuthSession copyWith({String? accessToken, String? refreshToken}) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;
}
