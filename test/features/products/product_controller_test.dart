import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(mockDio)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProductController', () {
    test('initial state is ProductInitial', () {
      final state = container.read(productControllerProvider);
      expect(state, isA<ProductInitial>());
    });

    test('fetchProducts succeeds and emits ProductLoaded when API returns list', () async {
      when(() => mockDio.get(ApiEndpoints.products)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.products),
          statusCode: 200,
          data: [
            {
              'id': '1',
              'title': 'Test Headphone',
              'description': 'Noise cancelling',
              'price': 199.99,
              'imageUrl': 'https://example.com/img.jpg',
            }
          ],
        ),
      );

      final controller = container.read(productControllerProvider.notifier);
      final result = await controller.fetchProducts();

      expect(result, isA<Success<List<Product>>>());
      final state = container.read(productControllerProvider);
      expect(state, isA<ProductLoaded>());
      final loaded = state as ProductLoaded;
      expect(loaded.products, hasLength(1));
      expect(loaded.products.first.id, '1');
      expect(loaded.products.first.title, 'Test Headphone');
    });

    test('fetchProducts falls back to dummy products on connection error', () async {
      when(() => mockDio.get(ApiEndpoints.products)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.products),
          type: DioExceptionType.connectionError,
        ),
      );

      final controller = container.read(productControllerProvider.notifier);
      final result = await controller.fetchProducts();

      expect(result, isA<Success<List<Product>>>());
      final state = container.read(productControllerProvider);
      expect(state, isA<ProductLoaded>());
      final loaded = state as ProductLoaded;
      expect(loaded.products.isNotEmpty, isTrue);
    });
  });

  group('ProductDetailsController', () {
    test('initial state is ProductDetailsInitial', () {
      final state = container.read(productDetailsControllerProvider('1'));
      expect(state, isA<ProductDetailsInitial>());
    });

    test('fetchProduct loads specific product', () async {
      when(() => mockDio.get(ApiEndpoints.product('1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.product('1')),
          statusCode: 200,
          data: {
            'id': '1',
            'title': 'Test Item',
            'description': 'Description',
            'price': 49.99,
            'imageUrl': 'https://example.com/item.jpg',
          },
        ),
      );

      final controller = container.read(productDetailsControllerProvider('1').notifier);
      final result = await controller.fetchProduct();

      expect(result, isA<Success<Product>>());
      final state = container.read(productDetailsControllerProvider('1'));
      expect(state, isA<ProductDetailsLoaded>());
      final loaded = state as ProductDetailsLoaded;
      expect(loaded.product.title, 'Test Item');
    });

    test('fetchProduct falls back to dummy product on offline error', () async {
      when(() => mockDio.get(ApiEndpoints.product('1'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.product('1')),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final controller = container.read(productDetailsControllerProvider('1').notifier);
      final result = await controller.fetchProduct();

      expect(result, isA<Success<Product>>());
      final state = container.read(productDetailsControllerProvider('1'));
      expect(state, isA<ProductDetailsLoaded>());
    });
  });
}
