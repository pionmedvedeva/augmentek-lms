class Env {
  static const String appName = 'Augmentek';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API endpoints
  static const String apiBaseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Cache settings
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration cacheDuration = Duration(days: 7);
  
  // Pagination settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultButtonHeight = 48.0;
  
  // Error messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  
  // Success messages
  static const String loginSuccessMessage = 'Successfully logged in.';
  static const String logoutSuccessMessage = 'Successfully logged out.';
  static const String updateSuccessMessage = 'Successfully updated.';
  static const String deleteSuccessMessage = 'Successfully deleted.';
  
  // Validation messages
  static const String requiredFieldMessage = 'This field is required.';
  static const String invalidEmailMessage = 'Please enter a valid email address.';
  static const String invalidPasswordMessage = 'Password must be at least 8 characters long.';
  static const String passwordMismatchMessage = 'Passwords do not match.';
} 