import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async {
    return accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    return refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  group('TokenManager', () {
    test('returns false when access token does not exist', () async {
      final storage = FakeTokenStorage();
      final manager = TokenManager(storage);

      expect(
        await manager.hasValidAccessToken(),
        isFalse,
      );
    });

    test('saves tokens through token storage', () async {
      final storage = FakeTokenStorage();
      final manager = TokenManager(storage);

      await manager.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      expect(
        await manager.getAccessToken(),
        'access-token',
      );

      expect(
        await manager.getRefreshToken(),
        'refresh-token',
      );
    });

    test('clear removes stored tokens', () async {
      final storage = FakeTokenStorage();
      final manager = TokenManager(storage);

      await manager.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );

      await manager.clear();

      expect(
        await manager.getAccessToken(),
        isNull,
      );

      expect(
        await manager.getRefreshToken(),
        isNull,
      );
    });
  });
}