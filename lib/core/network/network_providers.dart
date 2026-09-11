import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final dioProvider = Provider((ref) {
  return ref.watch(dioClientProvider).dio;
});
