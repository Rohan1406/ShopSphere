import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/controllers/product_controller.dart';
import 'package:shopsphere/features/products/views/widgets/search_suggestions_view.dart';
import 'package:shopsphere/features/products/views/widgets/voice_search_modal.dart';

void main() {
  group('RecentSearchesNotifier & TrendingSearches', () {
    test('addSearch adds unique searches to the front and trims to max 8', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recentSearchesProvider.notifier);

      notifier.addSearch('New Product');
      expect(container.read(recentSearchesProvider).first, 'New Product');

      // Adding duplicate brings it to the front
      notifier.addSearch('New Product');
      expect(
        container
            .read(recentSearchesProvider)
            .where((s) => s == 'New Product')
            .length,
        1,
      );

      // Add multiple
      for (int i = 0; i < 10; i++) {
        notifier.addSearch('Query $i');
      }
      expect(container.read(recentSearchesProvider).length, lessThanOrEqualTo(8));
    });

    test('removeSearch and clearSearches operate correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(recentSearchesProvider.notifier);
      notifier.addSearch('Item to delete');
      expect(container.read(recentSearchesProvider).contains('Item to delete'), isTrue);

      notifier.removeSearch('Item to delete');
      expect(container.read(recentSearchesProvider).contains('Item to delete'), isFalse);

      notifier.clearSearches();
      expect(container.read(recentSearchesProvider), isEmpty);
    });

    test('trendingSearchesProvider provides curated terms', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final trending = container.read(trendingSearchesProvider);
      expect(trending.isNotEmpty, isTrue);
      expect(trending.contains('Sony Headphones'), isTrue);
    });
  });

  group('VoiceSearchModal Widget', () {
    testWidgets('renders animated microphone and triggers query recognition via prompt chip', (
      tester,
    ) async {
      String recognized = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceSearchModal(
              onQueryRecognized: (query) {
                recognized = query;
              },
            ),
          ),
        ),
      );

      // Verify initial UI elements
      expect(find.text('Voice Search (AI Simulation)'), findsOneWidget);
      expect(find.text('Listening... Speak now'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsWidgets);

      // Tap on prompt chip '🎧 Sony Headphones'
      final promptChip = find.text('🎧 Sony Headphones');
      expect(promptChip, findsOneWidget);
      await tester.tap(promptChip);

      // Pump through the simulated typing periodic timer
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1500));

      expect(recognized, contains('Sony'));
    });
  });

  group('SearchSuggestionsView Widget', () {
    testWidgets('displays recent searches and trending keywords', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      String selectedQuery = '';
      bool voiceTapped = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SearchSuggestionsView(
                onQuerySelected: (query) {
                  selectedQuery = query;
                },
                onVoiceSearchTap: () {
                  voiceTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('Trending Keywords'), findsOneWidget);
      expect(find.text('Try Voice Search'), findsOneWidget);

      // Tap on a trending tag
      final trendingChip = find.text('Sony Headphones');
      expect(trendingChip, findsWidgets);
      await tester.tap(trendingChip.first);
      expect(selectedQuery, 'Sony Headphones');

      // Tap voice search banner
      await tester.tap(find.text('Try Voice Search'));
      expect(voiceTapped, isTrue);
    });
  });
}
