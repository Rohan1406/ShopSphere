import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/network/auth_refresh_coordinator.dart';

void main() {
  group('AuthRefreshCoordinator', () {
    test('executes only one refresh for concurrent requests', () async {
      final coordinator = AuthRefreshCoordinator();

      var refreshCount = 0;

      final completer = Completer<String?>();

      Future<String?> refresh() {
        refreshCount++;
        return completer.future;
      }

      final first = coordinator.refresh(refresh);
      final second = coordinator.refresh(refresh);
      final third = coordinator.refresh(refresh);

      expect(refreshCount, 1);

      completer.complete('new-access-token');

      expect(await first, 'new-access-token');
      expect(await second, 'new-access-token');
      expect(await third, 'new-access-token');
    });

    test('allows another refresh after the previous one completes', () async {
      final coordinator = AuthRefreshCoordinator();

      var refreshCount = 0;

      Future<String?> refresh() async {
        refreshCount++;
        return 'token-$refreshCount';
      }

      expect(
        await coordinator.refresh(refresh),
        'token-1',
      );

      expect(
        await coordinator.refresh(refresh),
        'token-2',
      );

      expect(refreshCount, 2);
    });

    test('shares a failed refresh with concurrent callers', () async {
      final coordinator = AuthRefreshCoordinator();

      var refreshCount = 0;

      final completer = Completer<String?>();

      Future<String?> refresh() {
        refreshCount++;
        return completer.future;
      }

      final first = coordinator.refresh(refresh);
      final second = coordinator.refresh(refresh);

      expect(refreshCount, 1);

      completer.complete(null);

      expect(await first, isNull);
      expect(await second, isNull);
    });
  });
}