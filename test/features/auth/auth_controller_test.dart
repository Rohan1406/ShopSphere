import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/core/storage/token_manager.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';
import 'package:shopsphere/features/auth/models/auth_session.dart';

class MockDio extends Mock implements Dio {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockDio mockDio;
  late MockTokenStorage mockStorage;
  late TokenManager tokenManager;
  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockTokenStorage();
    tokenManager = TokenManager(mockStorage);

    when(() => mockStorage.saveTokens(
      accessToken: any(named: 'accessToken'),
      refreshToken: any(named: 'refreshToken'),
    )).thenAnswer((_) async {});

    when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => mockStorage.clear()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
        tokenStorageProvider.overrideWithValue(mockStorage),
        tokenManagerProvider.overrideWithValue(tokenManager),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    test('initial state is AuthInitial', () {
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthInitial>());
    });

    test('login succeeds and saves tokens', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any(named: 'data'),
      )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          statusCode: 200,
          data: {
            'access_token': 'test_access_jwt',
            'refresh_token': 'test_refresh_jwt',
          },
        ),
      );

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.login(
        email: 'user@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<AuthSession>>());
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());

      verify(() => mockStorage.saveTokens(
        accessToken: 'test_access_jwt',
        refreshToken: 'test_refresh_jwt',
      )).called(1);
    });

    test('login falls back to demo offline mode on connection error', () async {
      when(() => mockDio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: any(named: 'data'),
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          type: DioExceptionType.connectionError,
        ),
      );

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.login(
        email: 'demo@shopsphere.com',
        password: 'password',
      );

      expect(result, isA<Success<AuthSession>>());
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
    });

    test('restoreSession emits AuthUnauthenticated when no tokens are stored', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);
      when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);

      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.restoreSession();

      expect(result, isA<Success<AuthSession?>>());
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthUnauthenticated>());
    });

    test('logout clears tokens and emits AuthUnauthenticated', () async {
      final controller = container.read(authControllerProvider.notifier);
      final result = await controller.logout();

      expect(result, isA<Success<void>>());
      final state = container.read(authControllerProvider);
      expect(state, isA<AuthUnauthenticated>());

      verify(() => mockStorage.clear()).called(1);
    });
  });
}
