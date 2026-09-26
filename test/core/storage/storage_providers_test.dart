import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/core/storage/secure_token_storage.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

void main() {
  test('token storage provider resolves secure token storage', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final storage = container.read(tokenStorageProvider);

    expect(storage, isA<TokenStorage>());
    expect(storage, isA<SecureTokenStorage>());
  });
}
