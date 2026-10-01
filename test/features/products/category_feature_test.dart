import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/category.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/views/pages/products_page.dart';
import 'package:shopsphere/features/products/views/widgets/category_filter_bar.dart';

void main() {
  group('Category Model', () {
    test('creates Category with default icon and JSON serialization', () {
      final category = Category.fromJson({
        'id': 'electronics',
        'name': 'Electronics',
        'icon': 'devices_rounded',
      });

      expect(category.id, 'electronics');
      expect(category.name, 'Electronics');
      expect(category.iconKey, 'devices_rounded');
      expect(category.iconData, Icons.devices_rounded);

      final json = category.toJson();
      expect(json['id'], 'electronics');
      expect(json['name'], 'Electronics');
      expect(json['icon'], 'devices_rounded');
    });

    test('supports equality and copyWith', () {
      const cat1 = Category(id: 'fashion', name: 'Fashion');
      const cat2 = Category(id: 'fashion', name: 'Fashion');
      final cat3 = cat1.copyWith(name: 'New Fashion');

      expect(cat1, equals(cat2));
      expect(cat1.hashCode, equals(cat2.hashCode));
      expect(cat3.name, 'New Fashion');
    });
  });

  group('Product Model with Category', () {
    test('parses category correctly from JSON and defaults when missing', () {
      final product = Product.fromJson({
        'id': 'p1',
        'title': 'Test Item',
        'description': 'Description',
        'price': 49.99,
        'imageUrl': 'https://example.com/item.jpg',
        'category': 'footwear',
      });

      expect(product.category, 'footwear');

      final fallbackProduct = Product.fromJson({
        'id': 'p2',
        'title': 'Test Item 2',
        'description': 'Description 2',
        'price': 19.99,
        'imageUrl': 'https://example.com/item2.jpg',
      });

      expect(fallbackProduct.category, 'general');
    });
  });

  group('Category Filtering & Providers', () {
    test('filteredProductsProvider filters by selected category', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Default 'all'
      expect(container.read(selectedCategoryProvider), 'all');
      expect(
        container.read(filteredProductsProvider).length,
        DummyData.products.length,
      );

      // Select electronics
      container
          .read(selectedCategoryProvider.notifier)
          .selectCategory('electronics');
      final electronics = container.read(filteredProductsProvider);
      expect(electronics.every((p) => p.category == 'electronics'), isTrue);
      expect(electronics.isNotEmpty, isTrue);

      // Select fashion
      container
          .read(selectedCategoryProvider.notifier)
          .selectCategory('fashion');
      final fashion = container.read(filteredProductsProvider);
      expect(fashion.every((p) => p.category == 'fashion'), isTrue);
    });

    test('filteredProductsProvider filters by search query', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(productSearchQueryProvider.notifier).updateQuery('Sony');
      final results = container.read(filteredProductsProvider);

      expect(results.length, 1);
      expect(results.first.title, contains('Sony'));
    });
  });

  group('CategoryFilterBar Widget', () {
    testWidgets('renders category chips and triggers onCategorySelected', (
      tester,
    ) async {
      String selected = 'all';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilterBar(
              selectedCategoryId: selected,
              onCategorySelected: (catId) {
                selected = catId;
              },
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Fashion'), findsOneWidget);

      await tester.tap(find.text('Electronics'));
      await tester.pump();

      expect(selected, 'electronics');
    });
  });

  group('ProductsPage with Category Filter', () {
    testWidgets('displays catalog, category chips, and filter changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productControllerProvider.overrideWith(
              () => _FakeLoadedProductController(),
            ),
          ],
          child: const MaterialApp(
            home: ProductsPage(initialCategory: 'footwear'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Product Catalog'), findsOneWidget);
      expect(find.text('Category: FOOTWEAR (1)'), findsOneWidget);
      expect(find.text('Nike Air Max Performance Runners'), findsOneWidget);
    });
  });
}

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
