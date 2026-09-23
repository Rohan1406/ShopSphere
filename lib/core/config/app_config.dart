import 'app_environment.dart';

abstract final class AppConfig {
  static const environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static AppEnvironment get environment {
    return switch (environmentName) {
      'development' => AppEnvironment.development,
      'staging' => AppEnvironment.staging,
      'production' => AppEnvironment.production,
      _ => throw StateError("Unsupported APP_ENV:$environmentName"),
    };
  }

  static bool get isDevelopment => environment == AppEnvironment.development;

  static bool get isStaging => environment == AppEnvironment.staging;

  static bool get isProduction => environment == AppEnvironment.production;
}
