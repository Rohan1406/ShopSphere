import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
