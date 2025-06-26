import 'package:flutter_test/flutter_test.dart';
import 'package:miniapp/core/config/app_constants.dart';

/// Unit тесты для системы констант
/// 
/// Покрывает:
/// - Валидность всех константных значений
/// - Непротиворечивость значений
/// - Типы данных и форматы
/// - Regex patterns
/// - Consistent naming
void main() {
  group('AppConstants', () {
    group('Basic App Info', () {
      test('should have valid app name', () {
        expect(AppConstants.appName, 'Augmentek LMS');
        expect(AppConstants.appName.isNotEmpty, isTrue);
      });

      test('should have valid version and build', () {
        expect(AppConstants.appVersion, '1.0.0');
        expect(AppConstants.appBuildNumber, '1');
        expect(AppConstants.appVersion.contains('.'), isTrue);
      });
    });

    group('AppRoutes', () {
      test('should have valid route paths', () {
        expect(AppRoutes.root, '/');
        expect(AppRoutes.home, '/home');
        expect(AppRoutes.admin, '/admin');
        expect(AppRoutes.courses, '/courses');
        expect(AppRoutes.settings, '/settings');
        expect(AppRoutes.profile, '/profile');
        expect(AppRoutes.debug, '/debug');
      });

      test('should have admin nested routes', () {
        expect(AppRoutes.adminUsers, '/admin/users');
        expect(AppRoutes.adminCourses, '/admin/courses');
        expect(AppRoutes.adminHomework, '/admin/homework');
        expect(AppRoutes.adminSettings, '/admin/settings');
      });

      test('should have course nested routes', () {
        expect(AppRoutes.courseDetails, '/courses/:courseId');
        expect(AppRoutes.courseContent, '/courses/:courseId/content');
        expect(AppRoutes.lessonView, '/courses/:courseId/lessons/:lessonId');
      });

      test('all routes should start with /', () {
        final routes = [
          AppRoutes.root,
          AppRoutes.home,
          AppRoutes.admin,
          AppRoutes.courses,
          AppRoutes.settings,
          AppRoutes.profile,
          AppRoutes.debug,
          AppRoutes.adminUsers,
          AppRoutes.adminCourses,
          AppRoutes.adminHomework,
          AppRoutes.adminSettings,
          AppRoutes.courseDetails,
          AppRoutes.courseContent,
          AppRoutes.lessonView,
        ];

        for (final route in routes) {
          expect(route.startsWith('/'), isTrue, reason: 'Route $route should start with /');
        }
      });
    });

    group('AppStorageKeys', () {
      test('should have unique storage keys', () {
        final keys = [
          AppStorageKeys.userToken,
          AppStorageKeys.userData,
          AppStorageKeys.appSettings,
          AppStorageKeys.debugLogs,
          AppStorageKeys.cacheData,
          AppStorageKeys.lastSyncTime,
          AppStorageKeys.offlineMode,
          AppStorageKeys.themeMode,
          AppStorageKeys.languageCode,
        ];

        // Проверяем что все ключи уникальны
        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, keys.length, reason: 'All storage keys should be unique');

        // Проверяем что все ключи не пустые и содержательные
        for (final key in keys) {
          expect(key.isNotEmpty, isTrue);
          expect(key.length, greaterThan(3), reason: 'Key $key should be descriptive');
        }
      });
    });

    group('AppEndpoints', () {
      test('should have valid Firestore collection names', () {
        expect(AppEndpoints.users, 'users');
        expect(AppEndpoints.courses, 'courses');
        expect(AppEndpoints.lessons, 'lessons');
        expect(AppEndpoints.homework, 'homework');
        expect(AppEndpoints.submissions, 'submissions');
        expect(AppEndpoints.admins, 'admins');
        expect(AppEndpoints.categories, 'categories');
      });

      test('should have valid log collections', () {
        expect(AppEndpoints.errorLogs, 'error_logs');
        expect(AppEndpoints.warningLogs, 'warning_logs');
        expect(AppEndpoints.appLogs, 'app_logs');
      });

      test('collection names should follow Firestore conventions', () {
        final endpoints = [
          AppEndpoints.users,
          AppEndpoints.courses,
          AppEndpoints.lessons,
          AppEndpoints.homework,
          AppEndpoints.submissions,
          AppEndpoints.admins,
          AppEndpoints.categories,
          AppEndpoints.errorLogs,
          AppEndpoints.warningLogs,
          AppEndpoints.appLogs,
        ];

        for (final endpoint in endpoints) {
          // Lowercase, no spaces, can contain underscores
          expect(endpoint.toLowerCase(), endpoint);
          expect(endpoint.contains(' '), isFalse);
          expect(endpoint.isNotEmpty, isTrue);
        }
      });
    });

    group('AppDimensions', () {
      test('should have valid spacing values', () {
        expect(AppDimensions.paddingSmall, 8.0);
        expect(AppDimensions.paddingMedium, 16.0);
        expect(AppDimensions.paddingLarge, 24.0);
        expect(AppDimensions.paddingExtraLarge, 32.0);
      });

      test('should have valid border radius values', () {
        expect(AppDimensions.defaultBorderRadius, 8.0);
        expect(AppDimensions.cardBorderRadius, 12.0);
        expect(AppDimensions.buttonBorderRadius, 8.0);
      });

      test('should have valid icon and button sizes', () {
        expect(AppDimensions.iconSize, 24.0);
        expect(AppDimensions.iconSizeLarge, 32.0);
        expect(AppDimensions.defaultButtonHeight, 48.0);
        expect(AppDimensions.compactButtonHeight, 36.0);
      });

      test('spacing should be progressive', () {
        expect(AppDimensions.paddingSmall, lessThan(AppDimensions.paddingMedium));
        expect(AppDimensions.paddingMedium, lessThan(AppDimensions.paddingLarge));
        expect(AppDimensions.paddingLarge, lessThan(AppDimensions.paddingExtraLarge));
      });
    });

    group('AppDurations', () {
      test('should have valid animation durations', () {
        expect(AppDurations.shortAnimation, const Duration(milliseconds: 200));
        expect(AppDurations.mediumAnimation, const Duration(milliseconds: 300));
        expect(AppDurations.longAnimation, const Duration(milliseconds: 500));
      });

      test('should have valid loading durations', () {
        expect(AppDurations.loadingDelay, const Duration(milliseconds: 500));
        expect(AppDurations.snackBarDuration, const Duration(seconds: 3));
        expect(AppDurations.toastDuration, const Duration(seconds: 2));
      });

      test('animation durations should be progressive', () {
        expect(
          AppDurations.shortAnimation.inMilliseconds,
          lessThan(AppDurations.mediumAnimation.inMilliseconds),
        );
        expect(
          AppDurations.mediumAnimation.inMilliseconds,
          lessThan(AppDurations.longAnimation.inMilliseconds),
        );
      });
    });

    group('AppNetwork', () {
      test('should have reasonable network settings', () {
        expect(AppNetwork.connectionTimeout, const Duration(seconds: 30));
        expect(AppNetwork.receiveTimeout, const Duration(seconds: 30));
        expect(AppNetwork.maxRetryAttempts, 3);
        expect(AppNetwork.retryDelay, const Duration(seconds: 1));
      });

      test('should have positive values', () {
        expect(AppNetwork.connectionTimeout.inSeconds, greaterThan(0));
        expect(AppNetwork.receiveTimeout.inSeconds, greaterThan(0));
        expect(AppNetwork.maxRetryAttempts, greaterThan(0));
        expect(AppNetwork.retryDelay.inSeconds, greaterThan(0));
      });
    });

    group('AppMessages', () {
      test('should have user-friendly error messages', () {
        expect(AppMessages.networkError.isNotEmpty, isTrue);
        expect(AppMessages.serverError.isNotEmpty, isTrue);
        expect(AppMessages.unknownError.isNotEmpty, isTrue);
        expect(AppMessages.validationError.isNotEmpty, isTrue);
        expect(AppMessages.permissionDenied.isNotEmpty, isTrue);
      });

      test('should have success messages', () {
        expect(AppMessages.loginSuccess.isNotEmpty, isTrue);
        expect(AppMessages.logoutSuccess.isNotEmpty, isTrue);
        expect(AppMessages.saveSuccess.isNotEmpty, isTrue);
        expect(AppMessages.deleteSuccess.isNotEmpty, isTrue);
        expect(AppMessages.updateSuccess.isNotEmpty, isTrue);
      });

      test('should have loading messages', () {
        expect(AppMessages.loading.isNotEmpty, isTrue);
        expect(AppMessages.pleaseWait.isNotEmpty, isTrue);
        expect(AppMessages.processing.isNotEmpty, isTrue);
      });
    });

    group('AppLimits', () {
      test('should have reasonable file size limits', () {
        expect(AppLimits.maxFileSize, 20 * 1024 * 1024); // 20 MB
        expect(AppLimits.maxImageSize, 5 * 1024 * 1024); // 5 MB
        expect(AppLimits.maxFileSize, greaterThan(AppLimits.maxImageSize));
      });

      test('should have pagination limits', () {
        expect(AppLimits.maxCoursesPerPage, 20);
        expect(AppLimits.maxUsersPerPage, 50);
        expect(AppLimits.maxLogsToKeep, 1000);
        
        expect(AppLimits.maxCoursesPerPage, greaterThan(0));
        expect(AppLimits.maxUsersPerPage, greaterThan(0));
        expect(AppLimits.maxLogsToKeep, greaterThan(0));
      });

      test('should have text limits', () {
        expect(AppLimits.maxUsernameLength, 50);
        expect(AppLimits.maxCourseNameLength, 100);
        expect(AppLimits.maxDescriptionLength, 500);
        
        expect(AppLimits.maxUsernameLength, lessThan(AppLimits.maxCourseNameLength));
        expect(AppLimits.maxCourseNameLength, lessThan(AppLimits.maxDescriptionLength));
      });
    });

    group('AppColors', () {
      test('should have primary color palette', () {
        expect(AppColors.primary, 0xFF673AB7);
        expect(AppColors.primaryDark, 0xFF512DA8);
        expect(AppColors.primaryLight, 0xFF9575CD);
      });

      test('should have secondary colors', () {
        expect(AppColors.secondary, 0xFFFF9800);
        expect(AppColors.accent, 0xFFFF5722);
      });

      test('should have semantic colors', () {
        expect(AppColors.success, 0xFF4CAF50);
        expect(AppColors.warning, 0xFFFFC107);
        expect(AppColors.error, 0xFFF44336);
        expect(AppColors.info, 0xFF2196F3);
      });
    });

    group('AppBreakpoints', () {
      test('should have responsive breakpoints', () {
        expect(AppBreakpoints.mobile, 768);
        expect(AppBreakpoints.tablet, 1024);
        expect(AppBreakpoints.desktop, 1200);
      });

      test('breakpoints should be progressive', () {
        expect(AppBreakpoints.mobile, lessThan(AppBreakpoints.tablet));
        expect(AppBreakpoints.tablet, lessThan(AppBreakpoints.desktop));
      });
    });

    group('AppPatterns', () {
      test('should have valid regex patterns', () {
        expect(AppPatterns.email.hasMatch('test@example.com'), isTrue);
        expect(AppPatterns.email.hasMatch('invalid-email'), isFalse);
        
        expect(AppPatterns.password.hasMatch('Password123!'), isTrue);
        expect(AppPatterns.password.hasMatch('weak'), isFalse);
        
        expect(AppPatterns.username.hasMatch('user123'), isTrue);
        expect(AppPatterns.username.hasMatch('u'), isFalse);
        
        expect(AppPatterns.url.hasMatch('https://example.com'), isTrue);
        expect(AppPatterns.url.hasMatch('not-a-url'), isFalse);
        
        expect(AppPatterns.phone.hasMatch('+1234567890'), isTrue);
        expect(AppPatterns.phone.hasMatch('123'), isFalse);
      });
    });

    group('AppFeatures', () {
      test('should have boolean feature flags', () {
        expect(AppFeatures.enableOfflineMode, isA<bool>());
        expect(AppFeatures.enablePushNotifications, isA<bool>());
        expect(AppFeatures.enableAnalytics, isA<bool>());
        expect(AppFeatures.enableCrashReporting, isA<bool>());
        expect(AppFeatures.enablePerformanceMonitoring, isA<bool>());
        expect(AppFeatures.enableRemoteConfig, isA<bool>());
        expect(AppFeatures.enableABTesting, isA<bool>());
        expect(AppFeatures.enableDarkTheme, isA<bool>());
        expect(AppFeatures.enableMultiLanguage, isA<bool>());
      });
    });

    group('AppAnalyticsEvents', () {
      test('should have meaningful event names', () {
        final events = [
          AppAnalyticsEvents.appOpened,
          AppAnalyticsEvents.userLoggedIn,
          AppAnalyticsEvents.userLoggedOut,
          AppAnalyticsEvents.courseViewed,
          AppAnalyticsEvents.courseEnrolled,
          AppAnalyticsEvents.lessonStarted,
          AppAnalyticsEvents.lessonCompleted,
          AppAnalyticsEvents.homeworkSubmitted,
          AppAnalyticsEvents.errorOccurred,
          AppAnalyticsEvents.screenViewed,
        ];

        for (final event in events) {
          expect(event.isNotEmpty, isTrue);
          expect(event.contains('_'), isTrue, reason: 'Event names should use snake_case');
          expect(event.toLowerCase(), event, reason: 'Event names should be lowercase');
        }
      });
    });

    group('AppTestData', () {
      test('should have test data for development', () {
        expect(AppTestData.testUserId, 'test_user_123');
        expect(AppTestData.testCourseId, 'test_course_123');
        expect(AppTestData.testLessonId, 'test_lesson_123');
        expect(AppTestData.mockYouTubeUrl, contains('youtube.com'));
      });

      test('test data should be clearly marked as test', () {
        expect(AppTestData.testUserId.contains('test'), isTrue);
        expect(AppTestData.testCourseId.contains('test'), isTrue);
        expect(AppTestData.testLessonId.contains('test'), isTrue);
      });
    });
  });
} 