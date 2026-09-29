import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(this._ref) {
    _subscription = _ref.listen(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
