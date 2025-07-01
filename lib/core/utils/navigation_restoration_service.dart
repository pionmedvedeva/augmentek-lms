import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/core/utils/navigation_state_service.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_view_screen.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_edit_screen.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_screen.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/shared/models/course.dart';

/// Сервис для восстановления состояния навигации после перезагрузки
class NavigationRestorationService {
  
  /// Пытается восстановить последнее состояние навигации
  static Future<bool> tryRestoreNavigation(BuildContext context, WidgetRef ref) async {
    try {
      final lastRoute = await NavigationStateService.getLastRoute();
      final params = await NavigationStateService.getLastRouteParams();
      
      if (lastRoute == null) {
        AppLogger.info('🧭 No saved navigation state to restore');
        return false;
      }
      
      AppLogger.info('🧭 Attempting to restore navigation: $lastRoute');
      
      // Парсим маршрут и восстанавливаем состояние
      if (lastRoute.contains('/lesson/') && params != null) {
        return await _restoreLessonNavigation(context, ref, lastRoute, params);
      } else if (lastRoute.contains('/course/') && params != null) {
        return await _restoreCourseNavigation(context, ref, lastRoute, params);
      }
      
      AppLogger.info('🧭 Unknown route format, cannot restore: $lastRoute');
      return false;
      
    } catch (e) {
      AppLogger.error('❌ Error restoring navigation: $e');
      return false;
    }
  }
  
  /// Восстанавливает навигацию к уроку
  static Future<bool> _restoreLessonNavigation(
    BuildContext context,
    WidgetRef ref,
    String route,
    Map<String, String> params,
  ) async {
    final courseId = params['courseId'];
    final lessonId = params['lessonId'];
    final action = params['action'];
    
    if (courseId == null || lessonId == null) {
      AppLogger.warning('⚠️ Missing courseId or lessonId in saved navigation state');
      return false;
    }
    
    try {
      // Загружаем урок
      AppLogger.info('🔄 Loading lesson data for restoration: $lessonId');
      
      // Получаем урок из провайдера
      final lessonState = ref.read(courseLessonsProvider(courseId));
      Lesson? lesson;
      
      await lessonState.when(
        data: (lessons) async {
          lesson = lessons.firstWhere(
            (l) => l.id == lessonId,
            orElse: () => throw Exception('Lesson not found'),
          );
        },
        loading: () async {
          // Принудительно загружаем уроки курса
          await ref.read(courseLessonsProvider(courseId).notifier).loadLessonsByCourse(courseId);
          final newState = ref.read(courseLessonsProvider(courseId));
          newState.whenData((lessons) {
            lesson = lessons.firstWhere(
              (l) => l.id == lessonId,
              orElse: () => throw Exception('Lesson not found'),
            );
          });
        },
        error: (error, stack) async {
          throw Exception('Error loading lessons: $error');
        },
      );
      
      if (lesson == null) {
        AppLogger.warning('⚠️ Lesson not found: $lessonId');
        return false;
      }
      
      // Переходим к нужному экрану
      if (action == 'edit') {
        AppLogger.info('🧭 Restoring lesson edit screen: ${lesson!.title}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonEditScreen(lesson: lesson!),
          ),
        );
      } else {
        AppLogger.info('🧭 Restoring lesson view screen: ${lesson!.title}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LessonViewScreen(
              lesson: lesson!,
              courseId: courseId,
            ),
          ),
        );
      }
      
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error restoring lesson navigation: $e');
      return false;
    }
  }
  
  /// Восстанавливает навигацию к курсу
  static Future<bool> _restoreCourseNavigation(
    BuildContext context,
    WidgetRef ref,
    String route,
    Map<String, String> params,
  ) async {
    final courseId = params['courseId'];
    
    if (courseId == null) {
      AppLogger.warning('⚠️ Missing courseId in saved navigation state');
      return false;
    }
    
    try {
      // Загружаем курс
      AppLogger.info('🔄 Loading course data for restoration: $courseId');
      
      final courseState = ref.read(courseProvider);
      Course? course;
      
      await courseState.when(
        data: (courses) async {
          course = courses.firstWhere(
            (c) => c.id == courseId,
            orElse: () => throw Exception('Course not found'),
          );
        },
        loading: () async {
          // Принудительно загружаем курсы
          await ref.read(courseProvider.notifier).loadCourses();
          final newState = ref.read(courseProvider);
          newState.whenData((courses) {
            course = courses.firstWhere(
              (c) => c.id == courseId,
              orElse: () => throw Exception('Course not found'),
            );
          });
        },
        error: (error, stack) async {
          throw Exception('Error loading courses: $error');
        },
      );
      
      if (course == null) {
        AppLogger.warning('⚠️ Course not found: $courseId');
        return false;
      }
      
      // Переходим к экрану курса
      AppLogger.info('🧭 Restoring course content screen: ${course!.title}');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CourseContentScreen(course: course!),
        ),
      );
      
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error restoring course navigation: $e');
      return false;
    }
  }
  
  /// Очищает сохраненное состояние (например, при явном выходе)
  static Future<void> clearSavedState() async {
    await NavigationStateService.clearSavedRoute();
    AppLogger.info('🧭 Navigation state cleared');
  }
}

/// Провайдер для управления восстановлением навигации
final navigationRestorationProvider = Provider<NavigationRestorationService>((ref) {
  return NavigationRestorationService();
}); 