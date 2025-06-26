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
        expect(AppConstants.appBuildNumber, 1);
        expect(AppConstants.appVersion.contains('.'), isTrue);
      });

      test('should have valid description', () {
        expect(AppConstants.appDescription.isNotEmpty, isTrue);
        expect(AppConstants.appDescription, contains('интеллект'));
      });
    });

    group('AppRoutes', () {
      test('should have valid main routes', () {
        expect(AppRoutes.home, '/');
        expect(AppRoutes.login, '/login');
        expect(AppRoutes.adminDashboard, '/admin');
        expect(AppRoutes.courseList, '/courses');
        expect(AppRoutes.settings, '/settings');
      });

      test('should have admin routes', () {
        expect(AppRoutes.adminCourses, '/admin/courses');
        expect(AppRoutes.adminUsers, '/admin/users');
        expect(AppRoutes.adminHomework, '/admin/homework');
        expect(AppRoutes.userProfile, '/admin/user/:userId');
      });

      test('should have course routes', () {
        expect(AppRoutes.courseDetails, '/course/:courseId');
        expect(AppRoutes.lessonView, '/course/:courseId/lesson/:lessonId');
        expect(AppRoutes.lessonEdit, '/admin/lesson/:lessonId/edit');
      });

      test('should have student routes', () {
        expect(AppRoutes.studentDashboard, '/student');
        expect(AppRoutes.enrolledCourses, '/student/courses');
        expect(AppRoutes.studentHomework, '/student/homework');
      });

      test('all routes should start with /', () {
        final routes = [
          AppRoutes.home,
          AppRoutes.login,
          AppRoutes.adminDashboard,
          AppRoutes.adminCourses,
          AppRoutes.adminUsers,
          AppRoutes.adminHomework,
          AppRoutes.userProfile,
          AppRoutes.courseList,
          AppRoutes.courseDetails,
          AppRoutes.lessonView,
          AppRoutes.lessonEdit,
          AppRoutes.studentDashboard,
          AppRoutes.enrolledCourses,
          AppRoutes.studentHomework,
          AppRoutes.settings,
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
          AppStorageKeys.appTheme,
          AppStorageKeys.appLanguage,
          AppStorageKeys.debugLogs,
          AppStorageKeys.cacheData,
          AppStorageKeys.lastLoginTime,
          AppStorageKeys.userPreferences,
          AppStorageKeys.coursesCache,
          AppStorageKeys.offlineMode,
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
        expect(AppEndpoints.enrollments, 'enrollments');
        expect(AppEndpoints.homeworkSubmissions, 'homework_submissions');
        expect(AppEndpoints.admins, 'admins');
        expect(AppEndpoints.categories, 'categories');
      });

      test('should have valid log collections', () {
        expect(AppEndpoints.errorLogs, 'error_logs');
        expect(AppEndpoints.warningLogs, 'warning_logs');
        expect(AppEndpoints.appLogs, 'app_logs');
      });

      test('should have Firebase Functions', () {
        expect(AppEndpoints.getCustomToken, 'getCustomToken');
        expect(AppEndpoints.validateTelegramData, 'validateTelegramData');
        expect(AppEndpoints.logError, 'logError');
      });

      test('collection names should follow Firestore conventions', () {
        final endpoints = [
          AppEndpoints.users,
          AppEndpoints.courses,
          AppEndpoints.lessons,
          AppEndpoints.enrollments,
          AppEndpoints.homeworkSubmissions,
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
      test('should have valid padding values', () {
        expect(AppDimensions.paddingSmall, 8.0);
        expect(AppDimensions.paddingMedium, 16.0);
        expect(AppDimensions.paddingLarge, 24.0);
        expect(AppDimensions.paddingXLarge, 32.0);
      });

      test('should have valid border radius values', () {
        expect(AppDimensions.radiusSmall, 4.0);
        expect(AppDimensions.radiusMedium, 8.0);
        expect(AppDimensions.radiusLarge, 12.0);
        expect(AppDimensions.radiusCard, 12.0);
        expect(AppDimensions.radiusButton, 8.0);
      });

      test('should have valid icon sizes', () {
        expect(AppDimensions.iconSmall, 16.0);
        expect(AppDimensions.iconMedium, 24.0);
        expect(AppDimensions.iconLarge, 32.0);
      });

      test('should have valid heights', () {
        expect(AppDimensions.buttonHeight, 48.0);
        expect(AppDimensions.inputHeight, 56.0);
        expect(AppDimensions.appBarHeight, 56.0);
      });

      test('spacing should be progressive', () {
        expect(AppDimensions.paddingSmall, lessThan(AppDimensions.paddingMedium));
        expect(AppDimensions.paddingMedium, lessThan(AppDimensions.paddingLarge));
        expect(AppDimensions.paddingLarge, lessThan(AppDimensions.paddingXLarge));
      });

      test('icons should be progressive', () {
        expect(AppDimensions.iconSmall, lessThan(AppDimensions.iconMedium));
        expect(AppDimensions.iconMedium, lessThan(AppDimensions.iconLarge));
      });
    });

    group('AppDurations', () {
      test('should have valid animation durations', () {
        expect(AppDurations.fast, const Duration(milliseconds: 150));
        expect(AppDurations.medium, const Duration(milliseconds: 300));
        expect(AppDurations.slow, const Duration(milliseconds: 500));
      });

      test('should have valid UI durations', () {
        expect(AppDurations.pageTransition, const Duration(milliseconds: 250));
        expect(AppDurations.modalAnimation, const Duration(milliseconds: 300));
        expect(AppDurations.snackBarDuration, const Duration(seconds: 3));
        expect(AppDurations.toastDuration, const Duration(seconds: 2));
      });

      test('animation durations should be progressive', () {
        expect(
          AppDurations.fast.inMilliseconds,
          lessThan(AppDurations.medium.inMilliseconds),
        );
        expect(
          AppDurations.medium.inMilliseconds,
          lessThan(AppDurations.slow.inMilliseconds),
        );
      });
    });

    group('AppNetwork', () {
      test('should have reasonable network settings', () {
        expect(AppNetwork.connectionTimeout, const Duration(seconds: 30));
        expect(AppNetwork.receiveTimeout, const Duration(seconds: 30));
        expect(AppNetwork.sendTimeout, const Duration(seconds: 30));
        expect(AppNetwork.maxRetries, 3);
        expect(AppNetwork.retryDelay, const Duration(seconds: 1));
      });

      test('should have positive values', () {
        expect(AppNetwork.connectionTimeout.inSeconds, greaterThan(0));
        expect(AppNetwork.receiveTimeout.inSeconds, greaterThan(0));
        expect(AppNetwork.maxRetries, greaterThan(0));
        expect(AppNetwork.retryDelay.inSeconds, greaterThan(0));
      });

      test('should have cache settings', () {
        expect(AppNetwork.maxCacheAge, 7);
        expect(AppNetwork.maxCacheEntries, 1000);
        expect(AppNetwork.maxCacheAge, greaterThan(0));
        expect(AppNetwork.maxCacheEntries, greaterThan(0));
      });
    });

    group('AppMessages', () {
      test('should have user-friendly error messages', () {
        expect(AppMessages.networkError.isNotEmpty, isTrue);
        expect(AppMessages.serverError.isNotEmpty, isTrue);
        expect(AppMessages.unknownError.isNotEmpty, isTrue);
        expect(AppMessages.authError.isNotEmpty, isTrue);
        expect(AppMessages.permissionDenied.isNotEmpty, isTrue);
      });

      test('should have success messages', () {
        expect(AppMessages.loginSuccess.isNotEmpty, isTrue);
        expect(AppMessages.logoutSuccess.isNotEmpty, isTrue);
        expect(AppMessages.saveSuccess.isNotEmpty, isTrue);
        expect(AppMessages.deleteSuccess.isNotEmpty, isTrue);
        expect(AppMessages.updateSuccess.isNotEmpty, isTrue);
      });

      test('should have informational messages', () {
        expect(AppMessages.loading.isNotEmpty, isTrue);
        expect(AppMessages.noData.isNotEmpty, isTrue);
        expect(AppMessages.comingSoon.isNotEmpty, isTrue);
      });

      test('should have confirmation messages', () {
        expect(AppMessages.confirmDelete.isNotEmpty, isTrue);
        expect(AppMessages.confirmLogout.isNotEmpty, isTrue);
        expect(AppMessages.confirmEnrollment.isNotEmpty, isTrue);
      });
    });

    group('AppLimits', () {
      test('should have reasonable file size limits', () {
        expect(AppLimits.maxFileSize, 10 * 1024 * 1024); // 10 MB
        expect(AppLimits.maxImageSize, 5 * 1024 * 1024); // 5 MB
        expect(AppLimits.maxVideoSize, 100 * 1024 * 1024); // 100 MB
        expect(AppLimits.maxImageSize, lessThan(AppLimits.maxFileSize));
        expect(AppLimits.maxFileSize, lessThan(AppLimits.maxVideoSize));
      });

      test('should have pagination limits', () {
        expect(AppLimits.pageSize, 20);
        expect(AppLimits.maxPageSize, 100);
        expect(AppLimits.maxLogsToKeep, 1000);
        
        expect(AppLimits.pageSize, greaterThan(0));
        expect(AppLimits.maxPageSize, greaterThan(AppLimits.pageSize));
        expect(AppLimits.maxLogsToKeep, greaterThan(0));
      });

      test('should have text limits', () {
        expect(AppLimits.maxUsernameLength, 50);
        expect(AppLimits.maxCourseTitleLength, 100);
        expect(AppLimits.maxCourseDescriptionLength, 2000);
        
        expect(AppLimits.maxUsernameLength, lessThan(AppLimits.maxCourseTitleLength));
        expect(AppLimits.maxCourseTitleLength, lessThan(AppLimits.maxCourseDescriptionLength));
      });
    });

    group('AppColors', () {
      test('should have Augmentek brand colors', () {
        expect(AppColors.primaryBlue.value, 0xFF4A90B8);
        expect(AppColors.accentOrange.value, 0xFFE8A87C);
        expect(AppColors.backgroundPeach.value, 0xFFFFF8F0);
      });

      test('should have status colors', () {
        expect(AppColors.successGreen.value, 0xFF4CAF50);
        expect(AppColors.warningOrange.value, 0xFFFF9800);
        expect(AppColors.errorRed.value, 0xFFF44336);
        expect(AppColors.infoBlue.value, 0xFF2196F3);
      });

      test('should have neutral colors', () {
        expect(AppColors.white.value, 0xFFFFFFFF);
        expect(AppColors.black.value, 0xFF000000);
        expect(AppColors.grey100.value, 0xFFF5F5F5);
        expect(AppColors.grey500.value, 0xFF9E9E9E);
        expect(AppColors.grey900.value, 0xFF212121);
      });
    });

    group('AppBreakpoints', () {
      test('should have responsive breakpoints', () {
        expect(AppBreakpoints.mobile, 600.0);
        expect(AppBreakpoints.tablet, 900.0);
        expect(AppBreakpoints.desktop, 1200.0);
        expect(AppBreakpoints.wide, 1600.0);
      });

      test('breakpoints should be progressive', () {
        expect(AppBreakpoints.mobile, lessThan(AppBreakpoints.tablet));
        expect(AppBreakpoints.tablet, lessThan(AppBreakpoints.desktop));
        expect(AppBreakpoints.desktop, lessThan(AppBreakpoints.wide));
      });
    });

    group('AppPatterns', () {
      test('should have valid regex patterns', () {
        // Email pattern
        final emailRegex = RegExp(AppPatterns.email);
        expect(emailRegex.hasMatch('test@example.com'), isTrue);
        expect(emailRegex.hasMatch('invalid-email'), isFalse);
        
        // Username pattern  
        final usernameRegex = RegExp(AppPatterns.username);
        expect(usernameRegex.hasMatch('user123'), isTrue);
        expect(usernameRegex.hasMatch('us'), isFalse);
        
        // YouTube URL pattern
        final youtubeRegex = RegExp(AppPatterns.youtubeUrl);
        expect(youtubeRegex.hasMatch('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
        expect(youtubeRegex.hasMatch('https://youtu.be/dQw4w9WgXcQ'), isTrue);
        expect(youtubeRegex.hasMatch('youtube.com/watch?v=test'), isTrue);
        
        // Phone number pattern
        final phoneRegex = RegExp(AppPatterns.phoneNumber);
        expect(phoneRegex.hasMatch('+1234567890'), isTrue);
        expect(phoneRegex.hasMatch('12345'), isTrue); // минимум 2 цифры после первой
        // NOTE: '123' actually matches pattern ^\\+?[1-9]\\d{1,14}$ (1 + 2 digits)
      });
    });

    group('AppFeatures', () {
      test('should have feature flags', () {
        expect(AppFeatures.enableOfflineMode, isFalse);
        expect(AppFeatures.enablePushNotifications, isTrue);
        expect(AppFeatures.enableAnalytics, isTrue);
        expect(AppFeatures.enableCrashReporting, isTrue);
        expect(AppFeatures.enablePerformanceMonitoring, isTrue);
      });

      test('experimental features should be disabled', () {
        expect(AppFeatures.enableRemoteConfig, isFalse);
        expect(AppFeatures.enableABTesting, isFalse);
        expect(AppFeatures.enableDarkTheme, isFalse);
        expect(AppFeatures.enableMultiLanguage, isFalse);
      });
    });

    group('AppAnalyticsEvents', () {
      test('should have core analytics events', () {
        expect(AppAnalyticsEvents.appOpened, 'app_opened');
        expect(AppAnalyticsEvents.userLoggedIn, 'user_logged_in');
        expect(AppAnalyticsEvents.userLoggedOut, 'user_logged_out');
        expect(AppAnalyticsEvents.courseViewed, 'course_viewed');
        expect(AppAnalyticsEvents.courseEnrolled, 'course_enrolled');
      });

      test('event names should follow convention', () {
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
          expect(event.contains('_'), isTrue, reason: 'Event $event should use snake_case');
          expect(event.toLowerCase(), event, reason: 'Event $event should be lowercase');
          expect(event.isNotEmpty, isTrue);
        }
      });
    });

    group('AppTestData', () {
      test('should have test data for development', () {
        expect(AppTestData.testUserId.isNotEmpty, isTrue);
        expect(AppTestData.testCourseId.isNotEmpty, isTrue);
        expect(AppTestData.testLessonId.isNotEmpty, isTrue);
        expect(AppTestData.mockYouTubeUrl.isNotEmpty, isTrue);
      });

      test('test data should be distinguishable', () {
        expect(AppTestData.testUserId.contains('test'), isTrue);
        expect(AppTestData.testCourseId.contains('test'), isTrue);
        expect(AppTestData.testLessonId.contains('test'), isTrue);
        expect(AppTestData.mockYouTubeUrl.contains('youtube'), isTrue);
      });
    });
  });
} 