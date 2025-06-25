class AppConfig {
  static const String appName = 'Augmentek';
  static const String appVersion = '1.0.0';
  
  // Firebase configuration
  static const String firebaseApiKey = 'YOUR_API_KEY';
  static const String firebaseAuthDomain = 'YOUR_AUTH_DOMAIN';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String firebaseStorageBucket = 'YOUR_STORAGE_BUCKET';
  static const String firebaseMessagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String firebaseAppId = 'YOUR_APP_ID';
  
  // Telegram configuration
  static const String telegramBotUsername = 'YOUR_BOT_USERNAME';
  
  // API endpoints
  static const String baseApiUrl = 'YOUR_API_URL';
  
  // Cache configuration
  static const int cacheDuration = 7; // days
  static const int maxCacheSize = 100; // MB
} 