import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/views/pages/product_details_page.dart';

class _FakeProductDetailsController extends ProductDetailsController {
  _FakeProductDetailsController(super.productId, this._initialState);

  final ProductDetailsState _initialState;

  @override
  ProductDetailsState build() {
    return _initialState;
  }

  @override
  Future<Result<Product>> fetchProduct() async {
    final product = switch (_initialState) {
      ProductDetailsLoaded(:final product) => product,
      _ => DummyData.products.first,
    };
    return Success(product);
  }
}

void main() {
  group('ProductDetailsPage', () {
    testWidgets(
      'displays loaded product details with image, title, and price',
      (tester) async {
        final product = DummyData.products.first;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              productDetailsControllerProvider('1').overrideWith(
                () => _FakeProductDetailsController(
                  '1',
                  ProductDetailsLoaded(product),
                ),
              ),
            ],
            child: const MaterialApp(home: ProductDetailsPage(productId: '1')),
          ),
        );

        expect(find.text(product.title), findsOneWidget);
        expect(find.text(product.category.toUpperCase()), findsOneWidget);
        expect(
          find.text('₹${product.price.toStringAsFixed(2)}'),
          findsOneWidget,
        );

        // Scroll to reveal description and action button
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pump();

        expect(find.text(product.description), findsOneWidget);
        expect(find.text('Add to Cart'), findsOneWidget);
      },
    );

    testWidgets('displays loading indicator during loading state', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productDetailsControllerProvider('1').overrideWith(
              () => _FakeProductDetailsController(
                '1',
                const ProductDetailsLoading(),
              ),
            ),
          ],
          child: const MaterialApp(home: ProductDetailsPage(productId: '1')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
