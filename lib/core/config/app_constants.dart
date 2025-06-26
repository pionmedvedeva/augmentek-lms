import 'package:flutter/material.dart';

/// Централизованные константы приложения Augmentek LMS
class AppConstants {
  // Предотвращаем создание экземпляров
  AppConstants._();
  
  /// 🎯 Основная информация приложения
  static const String appName = 'Augmentek LMS';
  static const String appDescription = 'Инструменты усиления человеческого интеллекта';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
}

/// 🛣️ Маршруты навигации
class AppRoutes {
    static const String home = '/';
    static const String login = '/login';
    
    // Admin routes
    static const String adminDashboard = '/admin';
    static const String adminCourses = '/admin/courses';
    static const String adminUsers = '/admin/users';
    static const String adminHomework = '/admin/homework';
    static const String userProfile = '/admin/user/:userId';
    
    // Course routes
    static const String courseList = '/courses';
    static const String courseDetails = '/course/:courseId';
    static const String lessonView = '/course/:courseId/lesson/:lessonId';
    static const String lessonEdit = '/admin/lesson/:lessonId/edit';
    
    // Student routes
    static const String studentDashboard = '/student';
    static const String enrolledCourses = '/student/courses';
    static const String studentHomework = '/student/homework';
    
    // Settings
    static const String settings = '/settings';
}

/// 💾 Ключи для локального хранения
class AppStorageKeys {
    static const String userToken = 'user_token';
    static const String userData = 'user_data';
    static const String appTheme = 'app_theme';
    static const String appLanguage = 'app_language';
    static const String debugLogs = 'app_logs';
    static const String cacheData = 'cache_data';
    static const String lastLoginTime = 'last_login_time';
    static const String userPreferences = 'user_preferences';
    static const String coursesCache = 'courses_cache';
    static const String offlineMode = 'offline_mode';
}

/// 🌐 API и Firebase endpoints  
class AppEndpoints {
    // Firestore коллекции
    static const String users = 'users';
    static const String courses = 'courses';
    static const String sections = 'sections';
    static const String lessons = 'lessons';
    static const String enrollments = 'enrollments';
    static const String homeworkSubmissions = 'homework_submissions';
    static const String admins = 'admins';
    static const String categories = 'categories';
    static const String errorLogs = 'error_logs';
    static const String warningLogs = 'warning_logs';
    static const String appLogs = 'app_logs';
    
    // Firebase Functions
    static const String getCustomToken = 'getCustomToken';
    static const String validateTelegramData = 'validateTelegramData';
    static const String logError = 'logError';
    static const String getErrorStats = 'getErrorStats';
    static const String cleanupOldLogs = 'cleanupOldLogs';
    
    // Firebase Storage пути
    static const String courseImages = 'course-images';
    static const String userAvatars = 'user-avatars';
    static const String lessonFiles = 'lesson-files';
    static const String homeworkFiles = 'homework-files';
}

/// 📱 UI размеры и отступы
class AppDimensions {
    // Отступы
    static const double paddingSmall = 8.0;
    static const double paddingMedium = 16.0;
    static const double paddingLarge = 24.0;
    static const double paddingXLarge = 32.0;
    
    // Margins
    static const double marginSmall = 4.0;
    static const double marginMedium = 8.0;
    static const double marginLarge = 16.0;
    
    // Border radius
    static const double radiusSmall = 4.0;
    static const double radiusMedium = 8.0;
    static const double radiusLarge = 12.0;
    static const double radiusXLarge = 16.0;
    static const double radiusCard = 12.0;
    static const double radiusButton = 8.0;
    
    // Sizes
    static const double iconSmall = 16.0;
    static const double iconMedium = 24.0;
    static const double iconLarge = 32.0;
    static const double avatarSmall = 32.0;
    static const double avatarMedium = 48.0;
    static const double avatarLarge = 64.0;
    
    // Heights
    static const double buttonHeight = 48.0;
    static const double inputHeight = 56.0;
    static const double appBarHeight = 56.0;
    static const double tabBarHeight = 48.0;
    static const double cardHeight = 120.0;
    
    // Elevations
    static const double elevationNone = 0.0;
    static const double elevationLow = 2.0;
    static const double elevationMedium = 4.0;
    static const double elevationHigh = 8.0;
    static const double elevationCard = 2.0;
    static const double elevationModal = 8.0;
}

/// ⏱️ Продолжительности анимаций
class AppDurations {
    static const Duration fast = Duration(milliseconds: 150);
    static const Duration medium = Duration(milliseconds: 300);
    static const Duration slow = Duration(milliseconds: 500);
    static const Duration pageTransition = Duration(milliseconds: 250);
    static const Duration modalAnimation = Duration(milliseconds: 300);
    static const Duration loadingDelay = Duration(milliseconds: 500);
    static const Duration snackBarDuration = Duration(seconds: 3);
    static const Duration toastDuration = Duration(seconds: 2);
}

/// 🌐 Сетевые настройки
class AppNetwork {
    static const Duration connectionTimeout = Duration(seconds: 30);
    static const Duration receiveTimeout = Duration(seconds: 30);
    static const Duration sendTimeout = Duration(seconds: 30);
    static const int maxRetries = 3;
    static const Duration retryDelay = Duration(seconds: 1);
    static const int maxCacheAge = 7; // дней
    static const int maxCacheEntries = 1000;
}

/// 🗣️ Сообщения пользователю
class AppMessages {
    // Ошибки
    static const String networkError = 'Проверьте подключение к интернету';
    static const String authError = 'Ошибка аутентификации';
    static const String unknownError = 'Произошла неизвестная ошибка';
    static const String permissionDenied = 'У вас нет прав доступа';
    static const String dataNotFound = 'Данные не найдены';
    static const String invalidInput = 'Некорректные данные';
    static const String serverError = 'Ошибка сервера. Попробуйте позже';
    static const String timeoutError = 'Превышено время ожидания';
    
    // Успех
    static const String loginSuccess = 'Вход выполнен успешно';
    static const String logoutSuccess = 'Выход выполнен успешно';
    static const String saveSuccess = 'Данные сохранены';
    static const String deleteSuccess = 'Данные удалены';
    static const String updateSuccess = 'Данные обновлены';
    static const String enrollmentSuccess = 'Вы записались на курс';
    static const String lessonCompleted = 'Урок завершен';
    static const String homeworkSubmitted = 'Домашнее задание отправлено';
    
    // Информационные
    static const String loading = 'Загрузка...';
    static const String noData = 'Нет данных';
    static const String noInternet = 'Нет подключения к интернету';
    static const String comingSoon = 'Скоро будет доступно';
    static const String underConstruction = 'В разработке';
    
    // Подтверждения
    static const String confirmDelete = 'Вы уверены, что хотите удалить?';
    static const String confirmLogout = 'Вы уверены, что хотите выйти?';
    static const String confirmEnrollment = 'Записаться на этот курс?';
    static const String confirmSubmission = 'Отправить домашнее задание?';
}

/// 📏 Лимиты и ограничения
class AppLimits {
    static const int maxUsernameLength = 50;
    static const int maxMessageLength = 1000;
    static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
    static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
    static const int maxVideoSize = 100 * 1024 * 1024; // 100 MB
    static const int maxCourseTitleLength = 100;
    static const int maxCourseDescriptionLength = 2000;
    static const int maxLessonTitleLength = 100;
    static const int maxHomeworkAnswerLength = 5000;
    static const int maxLogsToKeep = 1000;
    static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
    static const int pageSize = 20;
    static const int maxPageSize = 100;
}

/// 🎨 Цвета (в дополнение к AppTheme)
class AppColors {
    // Основные цвета Augmentek
    static const Color primaryBlue = Color(0xFF4A90B8);
    static const Color accentOrange = Color(0xFFE8A87C);
    static const Color backgroundPeach = Color(0xFFFFF8F0);
    
    // Статусы
    static const Color successGreen = Color(0xFF4CAF50);
    static const Color warningOrange = Color(0xFFFF9800);
    static const Color errorRed = Color(0xFFF44336);
    static const Color infoBlue = Color(0xFF2196F3);
    
    // Нейтральные
    static const Color white = Color(0xFFFFFFFF);
    static const Color black = Color(0xFF000000);
    static const Color grey100 = Color(0xFFF5F5F5);
    static const Color grey300 = Color(0xFFE0E0E0);
    static const Color grey500 = Color(0xFF9E9E9E);
    static const Color grey700 = Color(0xFF616161);
    static const Color grey900 = Color(0xFF212121);
    
    // Прозрачности
    static const Color overlay = Color(0x80000000);
    static const Color shimmer = Color(0xFFE0E0E0);
}

/// 📱 Breakpoints для responsive дизайна
class AppBreakpoints {
    static const double mobile = 600.0;
    static const double tablet = 900.0;
    static const double desktop = 1200.0;
    static const double wide = 1600.0;
}

/// 🔢 Regex паттерны
class AppPatterns {
    static const String email = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    static const String youtubeUrl = r'^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+$';
    static const String phoneNumber = r'^\+?[1-9]\d{1,14}$';
    static const String username = r'^[a-zA-Z0-9_]{3,30}$';
    static const String courseId = r'^[a-zA-Z0-9_-]{1,50}$';
}

/// 🎯 Feature flags
class AppFeatures {
    static const bool enableOfflineMode = false;
    static const bool enablePushNotifications = true;
    static const bool enableAnalytics = true;
    static const bool enableCrashReporting = true;
    static const bool enablePerformanceMonitoring = true;
    static const bool enableRemoteConfig = false;
    static const bool enableABTesting = false;
    static const bool enableDarkTheme = false;
    static const bool enableMultiLanguage = false;
}

/// 📊 Аналитика события
class AppAnalyticsEvents {
    static const String appOpened = 'app_opened';
    static const String userLoggedIn = 'user_logged_in';
    static const String userLoggedOut = 'user_logged_out';
    static const String courseViewed = 'course_viewed';
    static const String courseEnrolled = 'course_enrolled';
    static const String lessonStarted = 'lesson_started';
    static const String lessonCompleted = 'lesson_completed';
    static const String homeworkSubmitted = 'homework_submitted';
    static const String errorOccurred = 'error_occurred';
    static const String screenViewed = 'screen_viewed';
}

/// 🧪 Тестовые данные (только для development)
class AppTestData {
    static const String testUserId = 'test_user_123';
    static const String testCourseId = 'test_course_123';
    static const String testLessonId = 'test_lesson_123';
    static const String mockYouTubeUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
} 