class AuthRefreshCoordinator {
  Future<String?>? _refreshFuture;

  Future<String?> refresh(Future<String?> Function() refreshCallback) {
    final existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final future = refreshCallback();

    _refreshFuture = future;

    return future.whenComplete(() {
      _refreshFuture = null;
    });
  }
}
