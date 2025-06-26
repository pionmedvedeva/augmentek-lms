import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:miniapp/core/config/app_environment.dart';

/// Unit тесты для EnvironmentConfig
/// 
/// Покрывает:
/// - Определение окружения (development/staging/production)
/// - Конфигурация Firebase для разных окружений
/// - API endpoints и настройки
/// - Feature flags и производительность
/// - Debug информация
void main() {
  group('EnvironmentConfig', () {
    group('Environment Detection', () {
      test('should detect development environment when in debug mode', () {
        // В тестах kDebugMode всегда true, поэтому должно быть development
        expect(EnvironmentConfig.current, AppEnvironment.development);
        expect(EnvironmentConfig.isDevelopment, isTrue);
        expect(EnvironmentConfig.isStaging, isFalse);
        expect(EnvironmentConfig.isProduction, isFalse);
      });

      test('should return correct environment name', () {
        expect(EnvironmentConfig.current.name, 'development');
      });
    });

    group('Firebase Configuration', () {
      test('should provide correct Firebase project ID for each environment', () {
        // В development окружении
        expect(EnvironmentConfig.firebaseProjectId, 'augmentek-lms-dev');
      });

      test('should provide correct functions region', () {
        expect(EnvironmentConfig.functionsRegion, 'us-central1');
      });
    });

    group('API Configuration', () {
      test('should provide correct API base URL for development', () {
        expect(
          EnvironmentConfig.apiBaseUrl,
          'http://localhost:5001/augmentek-lms-dev/us-central1',
        );
      });

      test('should provide correct web app URL for development', () {
        expect(
          EnvironmentConfig.webAppUrl,
          'http://localhost:5000',
        );
      });
    });

    group('Feature Flags', () {
      test('should enable debug logs in development', () {
        expect(EnvironmentConfig.enableDebugLogs, isTrue);
      });

      test('should disable remote logging in development', () {
        expect(EnvironmentConfig.enableRemoteLogging, isFalse);
      });

      test('should disable performance monitoring in development', () {
        expect(EnvironmentConfig.enablePerformanceMonitoring, isFalse);
      });

      test('should disable analytics in development', () {
        expect(EnvironmentConfig.enableAnalytics, isFalse);
      });

      test('should enable experimental features in development', () {
        expect(EnvironmentConfig.enableExperimentalFeatures, isTrue);
      });

      test('should enable debug panel in development', () {
        expect(EnvironmentConfig.enableDebugPanel, isTrue);
      });

      test('should disable error reporting in development', () {
        expect(EnvironmentConfig.enableErrorReporting, isFalse);
      });
    });

    group('Performance Settings', () {
      test('should have fast cache duration in development', () {
        expect(
          EnvironmentConfig.cacheDuration,
          const Duration(minutes: 5),
        );
      });

      test('should have appropriate cache size in development', () {
        expect(
          EnvironmentConfig.maxCacheSize,
          50 * 1024 * 1024, // 50 MB
        );
      });

      test('should have longer connection timeout in development', () {
        expect(
          EnvironmentConfig.connectionTimeout,
          const Duration(seconds: 60),
        );
      });

      test('should have smaller page size in development', () {
        expect(EnvironmentConfig.defaultPageSize, 5);
      });
    });

    group('Telegram Bot Configuration', () {
      test('should provide correct bot token key for development', () {
        expect(EnvironmentConfig.telegramBotToken, 'BOT_TOKEN_DEV');
      });
    });

    group('App Version', () {
      test('should provide correct app version string for development', () {
        expect(EnvironmentConfig.appVersionString, '1.0.0-dev');
      });
    });

    group('Debug Information', () {
      test('should provide comprehensive debug info', () {
        final debugInfo = EnvironmentConfig.debugInfo;

        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo['environment'], 'development');
        expect(debugInfo['isDebug'], kDebugMode);
        expect(debugInfo['firebaseProjectId'], 'augmentek-lms-dev');
        expect(debugInfo['apiBaseUrl'], isA<String>());
        expect(debugInfo['webAppUrl'], isA<String>());
        expect(debugInfo['appVersion'], '1.0.0-dev');
        expect(debugInfo['enableDebugLogs'], isTrue);
        expect(debugInfo['enableRemoteLogging'], isFalse);
        expect(debugInfo['cacheDuration'], 5); // 5 minutes
        expect(debugInfo['maxCacheSize'], 50); // 50 MB
      });

      test('should provide description', () {
        expect(EnvironmentConfig.description, 'EnvironmentConfig(development)');
      });
    });

    group('Edge Cases', () {
      test('should handle all environment enum values', () {
        // Проверяем что все enum значения поддерживаются
        for (final env in AppEnvironment.values) {
          expect(env.name, isA<String>());
          expect(env.name.isNotEmpty, isTrue);
        }
      });

      test('should provide consistent configuration', () {
        // Проверяем консистентность настроек
        if (EnvironmentConfig.isDevelopment) {
          expect(EnvironmentConfig.enableDebugLogs, isTrue);
          expect(EnvironmentConfig.enableRemoteLogging, isFalse);
        }
        
        if (EnvironmentConfig.isProduction) {
          expect(EnvironmentConfig.enableDebugLogs, isFalse);
          expect(EnvironmentConfig.enableRemoteLogging, isTrue);
        }
      });
    });
  });
} 