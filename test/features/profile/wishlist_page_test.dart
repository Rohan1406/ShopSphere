import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/wishlist_page.dart';

void main() {
  group('WishlistPage', () {
    testWidgets('renders favorite items in wishlist', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WishlistPage())),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Wishlist ('), findsOneWidget);
      expect(find.text('Add All to Cart'), findsOneWidget);
      expect(find.text('Add to Cart'), findsWidgets);
    });
  });
}
