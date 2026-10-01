import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/views/pages/products_page.dart';
import 'package:shopsphere/features/products/views/widgets/product_grid_card.dart';

class _FakeLoadedProductController extends ProductController {
  @override
  ProductState build() {
    return ProductLoaded(DummyData.products);
  }

  @override
  Future<Result<List<Product>>> fetchProducts({String? category}) async {
    final products = (category != null && category != 'all')
        ? DummyData.findProductsByCategory(category)
        : DummyData.products;
    state = ProductLoaded(products);
    return Success(products);
  }
}

void main() {
  group('Product Catalog 2-Column Grid Layout', () {
    testWidgets('renders GridView with 2 columns in ProductsPage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productControllerProvider.overrideWith(
              () => _FakeLoadedProductController(),
            ),
          ],
          child: const MaterialApp(home: ProductsPage()),
        ),
      );

      await tester.pumpAndSettle();

      // Check GridView exists
      final gridFinder = find.byType(GridView);
      expect(gridFinder, findsOneWidget);

      final gridView = tester.widget<GridView>(gridFinder);
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      // Verify 2 columns
      expect(delegate.crossAxisCount, 2);
      expect(delegate.crossAxisSpacing, 12);
      expect(delegate.mainAxisSpacing, 12);

      // Verify ProductGridCards are rendered
      expect(find.byType(ProductGridCard), findsWidgets);
    });

    testWidgets('ProductGridCard displays product info and adds to cart', (
      WidgetTester tester,
    ) async {
      final product = DummyData.products.first;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: ProductGridCard(product: product),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title & price display
      expect(find.text(product.title), findsOneWidget);
      expect(find.text('₹${product.price.toStringAsFixed(2)}'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);

      // Tap add to cart
      await tester.tap(find.byIcon(Icons.add_shopping_cart_rounded));
      await tester.pumpAndSettle();

      // Verify SnackBar appears
      expect(find.text('Added "${product.title}" to cart!'), findsOneWidget);
    });
  });
}
