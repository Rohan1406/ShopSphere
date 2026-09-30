import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/core/errors/app_exception.dart';
import 'package:shopsphere/core/errors/failure.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/dio_error_mapper.dart';
import 'package:shopsphere/core/network/network_providers.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/models/product.dart';

// ==========================================
// 1. PRODUCT LIST STATE & CONTROLLER
// ==========================================

sealed class ProductState {
  const ProductState();
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductLoaded extends ProductState {
  const ProductLoaded(this.products);
  final List<Product> products;
}

final class ProductError extends ProductState {
  const ProductError(this.failure);
  final Failure failure;
}

final productControllerProvider =
    NotifierProvider<ProductController, ProductState>(ProductController.new);

/// Alias for backwards compatibility
final productNotifierProvider = productControllerProvider;

class ProductController extends Notifier<ProductState> {
  late final Dio _dio;

  @override
  ProductState build() {
    _dio = ref.watch(dioProvider);
    return const ProductInitial();
  }

  /// Fetches products from remote API or falls back to offline dummy data.
  Future<Result<List<Product>>> fetchProducts({String? category}) async {
    state = const ProductLoading();

    try {
      final endpoint = (category != null && category != 'all')
          ? '${ApiEndpoints.products}?category=$category'
          : ApiEndpoints.products;

      final response = await _dio.get(endpoint);
      final rawList = response.data as List<dynamic>;
      final products = rawList
          .map((item) => ProductModelAdapter.fromJson(item as Map<String, dynamic>))
          .toList();

      state = ProductLoaded(products);
      return Success(products);
    } on DioException catch (exception) {
      final mappedException = mapDioException(exception);
      // If offline or connection error, serve rich mock products gracefully
      if (mappedException is NetworkException || mappedException is TimeoutException) {
        final mockProducts = (category != null && category != 'all')
            ? DummyData.findProductsByCategory(category)
            : DummyData.products;
        state = ProductLoaded(mockProducts);
        return Success(mockProducts);
      }
      final failure = Failure(
        message: mappedException.message,
        statusCode: mappedException.statusCode,
      );
      state = ProductError(failure);
      return Error(failure);
    } on AppException catch (exception) {
      final failure = Failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
      state = ProductError(failure);
      return Error(failure);
    } catch (error) {
      // Offline fallback
      final mockProducts = (category != null && category != 'all')
          ? DummyData.findProductsByCategory(category)
          : DummyData.products;
      if (mockProducts.isNotEmpty) {
        state = ProductLoaded(mockProducts);
        return Success(mockProducts);
      }
      final failure = Failure(message: 'Failed to load products: $error');
      state = ProductError(failure);
      return Error(failure);
    }
  }
}

// ==========================================
// 2. CATEGORY & SEARCH FILTER PROVIDERS
// ==========================================

/// Provider for the currently selected category ID ('all' by default)
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void selectCategory(String categoryId) {
    state = categoryId;
  }
}

/// Provider for product search query filter
final productSearchQueryProvider =
    NotifierProvider<ProductSearchQueryNotifier, String>(
      ProductSearchQueryNotifier.new,
    );

class ProductSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Computed provider returning filtered products matching selectedCategory & searchQuery
final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productState = ref.watch(productControllerProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(productSearchQueryProvider).trim().toLowerCase();

  final List<Product> baseProducts = switch (productState) {
    ProductLoaded(:final products) => products,
    _ => DummyData.products,
  };

  return baseProducts.where((product) {
    final matchesCategory = selectedCategory == 'all' ||
        product.category.toLowerCase() == selectedCategory.toLowerCase();

    final matchesSearch = searchQuery.isEmpty ||
        product.title.toLowerCase().contains(searchQuery) ||
        product.description.toLowerCase().contains(searchQuery) ||
        product.category.toLowerCase().contains(searchQuery);

    return matchesCategory && matchesSearch;
  }).toList();
});

/// Related products in the same category
final relatedProductsProvider =
    Provider.family<List<Product>, String>((ref, productId) {
      final productState = ref.watch(productControllerProvider);
      final List<Product> allProducts = switch (productState) {
        ProductLoaded(:final products) => products,
        _ => DummyData.products,
      };

      final current = allProducts.where((p) => p.id == productId).firstOrNull ??
          DummyData.findProductById(productId);
      if (current == null) return const [];

      return allProducts
          .where((p) => p.id != productId && p.category.toLowerCase() == current.category.toLowerCase())
          .toList();
    });

// ==========================================
// 3. PRODUCT DETAILS STATE & CONTROLLER
// ==========================================

sealed class ProductDetailsState {
  const ProductDetailsState();
}

final class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product);
  final Product product;
}

final class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.failure);
  final Failure failure;
}

final productDetailsControllerProvider =
    NotifierProvider.family<ProductDetailsController, ProductDetailsState, String>(
      ProductDetailsController.new,
    );

/// Alias for backwards compatibility
final productDetailsNotifierProvider = productDetailsControllerProvider;

class ProductDetailsController extends Notifier<ProductDetailsState> {
  ProductDetailsController(this.productId);

  final String productId;
  late final Dio _dio;

  @override
  ProductDetailsState build() {
    _dio = ref.watch(dioProvider);
    return const ProductDetailsInitial();
  }

  Future<Result<Product>> fetchProduct() async {
    state = const ProductDetailsLoading();

    try {
      final response = await _dio.get(ApiEndpoints.product(productId));
      final rawData = response.data as Map<String, dynamic>;
      final product = Product.fromJson(rawData);

      state = ProductDetailsLoaded(product);
      return Success(product);
    } on DioException catch (exception) {
      final mappedException = mapDioException(exception);
      // Offline mock fallback
      final mockProduct = DummyData.findProductById(productId);
      if (mockProduct != null) {
        state = ProductDetailsLoaded(mockProduct);
        return Success(mockProduct);
      }
      final failure = Failure(
        message: mappedException.message,
        statusCode: mappedException.statusCode,
      );
      state = ProductDetailsError(failure);
      return Error(failure);
    } on AppException catch (exception) {
      final failure = Failure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
      state = ProductDetailsError(failure);
      return Error(failure);
    } catch (error) {
      final mockProduct = DummyData.findProductById(productId);
      if (mockProduct != null) {
        state = ProductDetailsLoaded(mockProduct);
        return Success(mockProduct);
      }
      final failure = Failure(message: 'Failed to load product details: $error');
      state = ProductDetailsError(failure);
      return Error(failure);
    }
  }
}

/// Helper adapter to parse Product
abstract final class ProductModelAdapter {
  static Product fromJson(Map<String, dynamic> json) => Product.fromJson(json);
}
