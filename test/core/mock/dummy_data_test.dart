import 'package:flutter_test/flutter_test.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';

void main() {
  group('DummyData', () {
    test('contains rich products catalog', () {
      expect(DummyData.products.length, greaterThanOrEqualTo(10));
      for (final product in DummyData.products) {
        expect(product.id.isNotEmpty, isTrue);
        expect(product.title.isNotEmpty, isTrue);
        expect(product.description.isNotEmpty, isTrue);
        expect(product.price, greaterThan(0));
        expect(product.imageUrl.startsWith('https://'), isTrue);
      }
    });

    test('findProductById returns expected item', () {
      final product = DummyData.findProductById('1');
      expect(product, isNotNull);
      expect(product!.id, '1');

      final notFound = DummyData.findProductById('non_existing');
      expect(notFound, isNull);
    });

    test('generateMockJwt generates non-expired valid JWT', () {
      final token = DummyData.generateMockJwt(email: 'test@shopsphere.com');
      expect(token, isNotEmpty);
      expect(JwtDecoder.isExpired(token), isFalse);

      final decoded = JwtDecoder.decode(token);
      expect(decoded['email'], 'test@shopsphere.com');
      expect(decoded['exp'], isA<int>());
    });

    test('categories and promoBanners contain expected data', () {
      expect(DummyData.categories, isNotEmpty);
      expect(DummyData.promoBanners, isNotEmpty);
    });
  });
}
