import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/errors/failure.dart';

import 'package:shopsphere/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success contains the expected data', () {
      const result = Success<String>('ShopSphere');

      expect(result, isA<Success<String>>());
      expect(result.data, 'ShopSphere');
    });

    test('Error contains the expected failure', () {
      const failure = Failure(
        message: 'Something went wrong.',
      );

      const result = Error<String>(failure);

      expect(result, isA<Error<String>>());
      expect(result.failure, same(failure));
    });

    test('Success can contain a list of data', () {
      const result = Success<List<String>>([
        'Product 1',
        'Product 2',
      ]);

      expect(result.data, hasLength(2));
      expect(result.data.first, 'Product 1');
    });

    test('Result supports pattern matching', () {
      const Result<String> result = Success('ShopSphere');

      final value = switch (result) {
        Success(:final data) => data,
        Error(:final failure) => failure.message,
      };

      expect(value, 'ShopSphere');
    });
  });
}