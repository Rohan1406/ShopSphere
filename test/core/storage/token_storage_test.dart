import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return _refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

void main() {
  group('TokenStorage', () {
    late TokenStorage storage;

    setUp(() {
      storage = FakeTokenStorage();
    });

    test('saves and retrieves access token', () async {
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(await storage.getAccessToken(), 'access-token');
    });

    test('saves and retrieves refresh token', () async {
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(await storage.getRefreshToken(), 'refresh-token');
    });

    test('returns null when no tokens exist', () async {
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('clear removes both tokens', () async {
      await storage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      await storage.clear();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });
}
