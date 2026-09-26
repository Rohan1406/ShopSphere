import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/storage/secure_token_storage.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

final tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(ref.watch(tokenStorageProvider));
});
