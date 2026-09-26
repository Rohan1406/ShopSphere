import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class TokenManager {
  final TokenStorage _tokenStorage;

  TokenManager(this._tokenStorage);

  Future<String?> getAccessToken() {
    return _tokenStorage.getAccessToken();
  }

  Future<String?> getRefreshToken() {
    return _tokenStorage.getRefreshToken();
  }

  Future<bool> hasValidAccessToken() async {
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    return !JwtDecoder.isExpired(accessToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    return _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clear() {
    return _tokenStorage.clear();
  }
}
