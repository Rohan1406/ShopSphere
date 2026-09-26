import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/di/app_dependencies.dart';
import 'package:shopsphere/core/storage/storage_providers.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:shopsphere/features/auth/presentation/state/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(appDioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenManagerProvider),
  );
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
