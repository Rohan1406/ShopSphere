import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/models/product.dart';
import 'package:shopsphere/features/products/views/pages/products_page.dart';
import 'package:shopsphere/features/products/views/widgets/product_filter_sheet.dart';
import 'package:shopsphere/features/products/views/widgets/voice_search_modal.dart';

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
  group('ProductsPage Integrated Search, Voice & Filter Sheet', () {
    testWidgets(
      'renders search field, mic button, filter button, and category filters',
      (tester) async {
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

        // Check App Bar & Actions
        expect(find.text('Product Catalog'), findsOneWidget);
        expect(find.byIcon(Icons.tune_rounded), findsWidgets);
        expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        // Search by brand name
        await tester.enterText(find.byType(TextField), 'Apple');
        await tester.pumpAndSettle();

        expect(find.textContaining('Apple Watch'), findsOneWidget);

        // Tap clear search button
        final clearButton = find.byIcon(Icons.clear_rounded);
        expect(clearButton, findsOneWidget);
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Apple Watch Ultra 2 Titanium GPS + Cellular'),
          findsOneWidget,
        );
      },
    );

    testWidgets('tapping filter button opens ProductFilterSheet modal', (
      tester,
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

      // Tap filter icon in AppBar or search row
      await tester.tap(find.byIcon(Icons.tune_rounded).first);
      await tester.pumpAndSettle();

      expect(find.byType(ProductFilterSheet), findsOneWidget);
      expect(find.text('Filters & Sort'), findsOneWidget);
    });

    testWidgets('tapping mic button opens VoiceSearchModal', (tester) async {
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

      // Tap voice mic icon
      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(VoiceSearchModal), findsOneWidget);
      expect(find.text('Voice Search (AI Simulation)'), findsOneWidget);
    });

    testWidgets(
      'autoFocusSearch opens keyboard and pressing enter finds results',
      (tester) async {
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
            child: const MaterialApp(home: ProductsPage(autoFocusSearch: true)),
          ),
        );

        await tester.pumpAndSettle();

        // Check TextField has focus
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);
        final textField = tester.widget<TextField>(textFieldFinder);
        expect(textField.focusNode?.hasFocus, isTrue);

        // Enter search query and press Enter / Search action on soft keyboard
        await tester.enterText(textFieldFinder, 'Keychron');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        // Verify filtered result is shown and recent searches recorded
        expect(
          find.text('Keychron K2 Wireless Mechanical Keyboard'),
          findsOneWidget,
        );
        expect(
          container.read(recentSearchesProvider).contains('Keychron'),
          isTrue,
        );
        expect(textField.focusNode?.hasFocus, isFalse);
      },
    );
  });
}
