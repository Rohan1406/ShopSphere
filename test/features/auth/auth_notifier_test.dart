import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

void main() {
  test('auth notifier starts with initial state', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final state = container.read(authNotifierProvider);

    expect(state, isA<AuthInitial>());
  });
}
