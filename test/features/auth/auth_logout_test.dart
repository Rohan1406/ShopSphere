import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  group('AuthController logout', () {
    test('changes state to unauthenticated and clears storage on logout', () async {
      final mockStorage = MockTokenStorage();
      final tokenManager = TokenManager(mockStorage);

      when(() => mockStorage.clear()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          tokenStorageProvider.overrideWithValue(mockStorage),
          tokenManagerProvider.overrideWithValue(tokenManager),
        ],
      );

      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);

      expect(container.read(authControllerProvider), isA<AuthInitial>());

      await controller.logout();

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
      verify(() => mockStorage.clear()).called(1);
    });
  });
}
