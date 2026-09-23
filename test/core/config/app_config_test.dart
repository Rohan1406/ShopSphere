import 'package:flutter_test/flutter_test.dart';

import 'package:shopsphere/core/config/app_config.dart';
import 'package:shopsphere/core/config/app_environment.dart';

void main() {
  group('AppConfig', () {
    test('uses development environment by default', () {
      expect(AppConfig.environmentName, 'development');
      expect(AppConfig.environment, AppEnvironment.development);
      expect(AppConfig.isDevelopment, isTrue);
      expect(AppConfig.isStaging, isFalse);
      expect(AppConfig.isProduction, isFalse);
    });

    test('provides a default base URL', () {
      expect(AppConfig.baseUrl, 'https://api.example.com');
    });
  });
}
