import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/app/app.dart';

void main() {
  testWidgets('ShopSphere app starts authentication flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShopSphereApp()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
