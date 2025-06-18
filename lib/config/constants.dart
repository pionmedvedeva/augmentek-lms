class AppConstants {
  // Route names
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String adminDashboardRoute = '/admin/dashboard';
  static const String studentDashboardRoute = '/student/dashboard';
  static const String courseDetailsRoute = '/course/:id';
  static const String settingsRoute = '/settings';
  
  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  
  // API endpoints
  static const String coursesEndpoint = '/courses';
  static const String usersEndpoint = '/users';
  static const String authEndpoint = '/auth';
  
  // Error messages
  static const String networkError = 'Network error occurred';
  static const String authError = 'Authentication failed';
  static const String unknownError = 'An unknown error occurred';
  
  // Success messages
  static const String loginSuccess = 'Successfully logged in';
  static const String logoutSuccess = 'Successfully logged out';
  static const String saveSuccess = 'Successfully saved';
} 