import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/presentation/providers/auth_providers.dart';

void main() {
  test('auth providers resolve their dependencies', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final dataSource = container.read(
      authRemoteDataSourceProvider,
    );

    final repository = container.read(
      authRepositoryProvider,
    );

    expect(dataSource, isA<AuthRemoteDataSource>());
    expect(repository, isA<AuthRepository>());
  });
}