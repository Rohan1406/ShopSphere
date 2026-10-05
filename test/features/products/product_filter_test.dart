import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/models/product_filter_state.dart';
import 'package:shopsphere/features/products/views/widgets/active_filter_chips_bar.dart';
import 'package:shopsphere/features/products/views/widgets/product_filter_sheet.dart';

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
  group('ProductFilterState Model & Notifier', () {
    test('initial state has no active filters', () {
      final initial = ProductFilterState.initial();
      expect(initial.hasActiveFilters, isFalse);
      expect(initial.activeFiltersCount, 0);
      expect(initial.minRating, 0.0);
      expect(initial.inStockOnly, isFalse);
      expect(initial.sortOption, ProductSortOption.featured);
      expect(initial.selectedBrands, isEmpty);
    });

    test('activeFiltersCount calculates active constraints accurately', () {
      var state = const ProductFilterState(
        priceRange: RangeValues(500, 20000),
        selectedBrands: {'Sony', 'Apple'},
        minRating: 4.5,
        inStockOnly: true,
        sortOption: ProductSortOption.priceLowToHigh,
      );

      // 1 (price) + 2 (brands) + 1 (rating) + 1 (stock) + 1 (sort) = 6
      expect(state.activeFiltersCount, 6);
      expect(state.hasActiveFilters, isTrue);
      expect(state.isBrandSelected('sony'), isTrue);
      expect(state.isBrandSelected('Nike'), isFalse);

      final reset = state.reset();
      expect(reset.activeFiltersCount, 0);
      expect(reset.hasActiveFilters, isFalse);
    });

    test('ProductFilterNotifier modifies state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productFilterProvider.notifier);

      notifier.updatePriceRange(const RangeValues(1000, 15000));
      expect(
        container.read(productFilterProvider).priceRange,
        const RangeValues(1000, 15000),
      );

      notifier.toggleBrand('Sony');
      expect(container.read(productFilterProvider).selectedBrands, {'Sony'});
      notifier.toggleBrand('Sony');
      expect(container.read(productFilterProvider).selectedBrands, isEmpty);

      notifier.setBrandSelected('Apple', true);
      notifier.setBrandSelected('Nike', true);
      expect(container.read(productFilterProvider).selectedBrands, {
        'Apple',
        'Nike',
      });

      notifier.setMinRating(4.0);
      notifier.setInStockOnly(true);
      notifier.setSortOption(ProductSortOption.rating);

      final updated = container.read(productFilterProvider);
      expect(updated.minRating, 4.0);
      expect(updated.inStockOnly, isTrue);
      expect(updated.sortOption, ProductSortOption.rating);

      notifier.resetFilters();
      expect(container.read(productFilterProvider).hasActiveFilters, isFalse);
    });
  });

  group('FilteredProductsProvider Multi-Facet Filtering & Sorting', () {
    test('filters by price range', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(productFilterProvider.notifier)
          .updatePriceRange(const RangeValues(500, 3000));

      final results = container.read(filteredProductsProvider);
      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.price >= 500 && p.price <= 3000), isTrue);
    });

    test('filters by brand selection', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(productFilterProvider.notifier).toggleBrand('Sony');
      final results = container.read(filteredProductsProvider);

      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.brand.toLowerCase() == 'sony'), isTrue);
    });

    test('filters by customer rating threshold', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(productFilterProvider.notifier).setMinRating(4.8);
      final results = container.read(filteredProductsProvider);

      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.rating >= 4.8), isTrue);
    });

    test('filters by in-stock only toggle', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Out-of-stock items exist in the mock dataset
      final all = container.read(filteredProductsProvider);
      expect(all.any((p) => !p.inStock), isTrue);

      container.read(productFilterProvider.notifier).setInStockOnly(true);
      final inStockList = container.read(filteredProductsProvider);

      expect(inStockList.isNotEmpty, isTrue);
      expect(inStockList.every((p) => p.inStock), isTrue);
    });

    test('sorts by Price: Low to High', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(productFilterProvider.notifier)
          .setSortOption(ProductSortOption.priceLowToHigh);
      final results = container.read(filteredProductsProvider);

      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price <= results[i + 1].price, isTrue);
      }
    });

    test('sorts by Price: High to Low', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(productFilterProvider.notifier)
          .setSortOption(ProductSortOption.priceHighToLow);
      final results = container.read(filteredProductsProvider);

      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price >= results[i + 1].price, isTrue);
      }
    });

    test('sorts by Customer Rating', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(productFilterProvider.notifier)
          .setSortOption(ProductSortOption.rating);
      final results = container.read(filteredProductsProvider);

      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].rating >= results[i + 1].rating, isTrue);
      }
    });

    test('sorts by Newest Arrivals', () {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(productFilterProvider.notifier)
          .setSortOption(ProductSortOption.newestArrivals);
      final results = container.read(filteredProductsProvider);

      expect(results.first.isNewArrival, isTrue);
    });
  });

  group('ProductFilterSheet Widget', () {
    testWidgets('renders filter sections and applies selected options', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: ProductFilterSheet())),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sections exist
      expect(find.text('Filters & Sort'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Price Range'), findsOneWidget);
      expect(find.text('Brands'), findsOneWidget);
      expect(find.text('Customer Rating'), findsWidgets);
      expect(find.text('In-Stock Only'), findsOneWidget);

      // Tap Sort option "Price: Low to High"
      await tester.tap(find.text('Price: Low to High'));
      await tester.pump();

      // Tap Rating threshold "4.5★ & above"
      await tester.tap(find.text('4.5★ & above'));
      await tester.pump();

      // Toggle In-Stock switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      // Tap Apply Filters button
      final applyButton = find.textContaining('Apply Filters');
      expect(applyButton, findsOneWidget);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Check state in container
      final state = container.read(productFilterProvider);
      expect(state.sortOption, ProductSortOption.priceLowToHigh);
      expect(state.minRating, 4.5);
      expect(state.inStockOnly, isTrue);
    });
  });

  group('ActiveFilterChipsBar Widget', () {
    testWidgets('displays active filters and removes individually', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          productControllerProvider.overrideWith(
            () => _FakeLoadedProductController(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Set some initial filters
      container.read(productFilterProvider.notifier).toggleBrand('Sony');
      container.read(productFilterProvider.notifier).setMinRating(4.0);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: ActiveFilterChipsBar()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sony'), findsOneWidget);
      expect(find.text('4.0★ & up'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Tap Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(container.read(productFilterProvider).hasActiveFilters, isFalse);
    });
  });
}
