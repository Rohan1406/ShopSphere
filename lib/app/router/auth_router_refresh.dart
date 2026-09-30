import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(this._ref) {
    _subscription = _ref.listen(authControllerProvider, (_, _) {
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
