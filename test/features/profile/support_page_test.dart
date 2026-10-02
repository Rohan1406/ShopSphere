import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/profile/views/pages/support_page.dart';

void main() {
  group('SupportPage', () {
    testWidgets('renders support channels and FAQs accordion', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SupportPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('We\'re here to help 24/7'), findsOneWidget);
      expect(find.text('Live Chat'), findsOneWidget);
      expect(find.text('Email Us'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.textContaining('My Support Tickets ('), findsOneWidget);
      expect(find.text('New Ticket'), findsOneWidget);
    });

    testWidgets('opens live chat modal sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SupportPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Live Chat'));
      await tester.pumpAndSettle();

      expect(find.text('ShopSphere Live Concierge'), findsOneWidget);
      expect(find.text('Type your message...'), findsOneWidget);
    });

    testWidgets('opens new ticket modal sheet', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SupportPage())),
      );
      await tester.pumpAndSettle();

      final newTicketBtn = find.widgetWithText(TextButton, 'New Ticket');
      await tester.scrollUntilVisible(
        newTicketBtn,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(newTicketBtn);
      await tester.pumpAndSettle();

      expect(find.text('Submit Support Ticket'), findsOneWidget);
      expect(find.text('Submit Ticket'), findsOneWidget);
    });
  });
}
