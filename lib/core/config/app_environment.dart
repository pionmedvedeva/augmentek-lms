import 'package:flutter/foundation.dart';

/// Доступные окружения приложения
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Конфигурация окружения приложения
class EnvironmentConfig {
  static const String _kEnvironmentKey = 'APP_ENVIRONMENT';
  
  // Текущее окружение (определяется автоматически)
  static AppEnvironment get current {
    if (kDebugMode) {
      return AppEnvironment.development;
    }
    
    // Проверяем URL для определения staging/production
    final url = Uri.base.toString();
    if (url.contains('staging') || url.contains('test')) {
      return AppEnvironment.staging;
    }
    
    return AppEnvironment.production;
  }
  
  // Проверки окружения
  static bool get isDevelopment => current == AppEnvironment.development;
  static bool get isStaging => current == AppEnvironment.staging;
  static bool get isProduction => current == AppEnvironment.production;
  
  // Конфигурация Firebase для разных окружений
  static String get firebaseProjectId {
    switch (current) {
      case AppEnvironment.development:
        return 'augmentek-lms-dev';
      case AppEnvironment.staging:
        return 'augmentek-lms-staging';
      case AppEnvironment.production:
        return 'augmentek-lms';
    }
  }
  
  // API endpoints для разных окружений
  static String get apiBaseUrl {
    switch (current) {
      case AppEnvironment.development:
        return 'http://localhost:5001/augmentek-lms-dev/us-central1';
      case AppEnvironment.staging:
        return 'https://us-central1-augmentek-lms-staging.cloudfunctions.net';
      case AppEnvironment.production:
        return 'https://us-central1-augmentek-lms.cloudfunctions.net';
    }
  }
  
  // Веб-приложение URL
  static String get webAppUrl {
    switch (current) {
      case AppEnvironment.development:
        return 'http://localhost:5000';
      case AppEnvironment.staging:
        return 'https://augmentek-lms-staging.web.app';
      case AppEnvironment.production:
        return 'https://augmentek-lms.web.app';
    }
  }
  
  // Настройки логирования
  static bool get enableDebugLogs => !isProduction;
  static bool get enableRemoteLogging => !isDevelopment;
  static bool get enablePerformanceMonitoring => !isDevelopment;
  static bool get enableAnalytics => !isDevelopment;
  
  // Настройки кеширования
  static Duration get cacheDuration {
    switch (current) {
      case AppEnvironment.development:
        return const Duration(minutes: 5); // Быстрое обновление для разработки
      case AppEnvironment.staging:
        return const Duration(hours: 1);
      case AppEnvironment.production:
        return const Duration(days: 7);
    }
  }
  
  static int get maxCacheSize {
    switch (current) {
      case AppEnvironment.development:
        return 50 * 1024 * 1024; // 50 MB
      case AppEnvironment.staging:
        return 100 * 1024 * 1024; // 100 MB
      case AppEnvironment.production:
        return 200 * 1024 * 1024; // 200 MB
    }
  }
  
  // Настройки timeout
  static Duration get connectionTimeout {
    switch (current) {
      case AppEnvironment.development:
        return const Duration(seconds: 60); // Больше времени для отладки
      case AppEnvironment.staging:
        return const Duration(seconds: 45);
      case AppEnvironment.production:
        return const Duration(seconds: 30);
    }
  }
  
  // Настройки для функций Firebase
  static String get functionsRegion => 'us-central1';
  
  // Telegram Bot настройки
  static String get telegramBotToken {
    switch (current) {
      case AppEnvironment.development:
        return 'BOT_TOKEN_DEV'; // Секрет в Firebase Functions
      case AppEnvironment.staging:
        return 'BOT_TOKEN_STAGING';
      case AppEnvironment.production:
        return 'BOT_SECRETKEY'; // Продакшн токен
    }
  }
  
  // Feature flags для разных окружений
  static bool get enableExperimentalFeatures => isDevelopment || isStaging;
  static bool get enableDebugPanel => !isProduction;
  static bool get enableErrorReporting => !isDevelopment;
  
  // Pagination настройки
  static int get defaultPageSize {
    switch (current) {
      case AppEnvironment.development:
        return 5; // Меньше для тестирования
      case AppEnvironment.staging:
        return 10;
      case AppEnvironment.production:
        return 20;
    }
  }
  
  // Версия приложения с окружением
  static String get appVersionString {
    final baseVersion = '1.0.0';
    switch (current) {
      case AppEnvironment.development:
        return '$baseVersion-dev';
      case AppEnvironment.staging:
        return '$baseVersion-staging';
      case AppEnvironment.production:
        return baseVersion;
    }
  }
  
  // Отладочная информация
  static Map<String, dynamic> get debugInfo => {
    'environment': current.name,
    'isDebug': kDebugMode,
    'firebaseProjectId': firebaseProjectId,
    'apiBaseUrl': apiBaseUrl,
    'webAppUrl': webAppUrl,
    'appVersion': appVersionString,
    'enableDebugLogs': enableDebugLogs,
    'enableRemoteLogging': enableRemoteLogging,
    'cacheDuration': cacheDuration.inMinutes,
    'maxCacheSize': (maxCacheSize / (1024 * 1024)).round(),
  };
  
  static String get description => 'EnvironmentConfig(${current.name})';
} 