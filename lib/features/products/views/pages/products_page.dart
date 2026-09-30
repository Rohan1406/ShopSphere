import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/views/widgets/product_card.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productControllerProvider.notifier).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: switch (state) {
        ProductInitial() => const SizedBox.shrink(),
        ProductLoading() => const Center(child: CircularProgressIndicator()),
        ProductLoaded(:final products) =>
          products.isEmpty
              ? const Center(child: Text('No products available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
        ProductError(:final failure) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failure.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(productControllerProvider.notifier).fetchProducts();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      },
    );
  }
}
