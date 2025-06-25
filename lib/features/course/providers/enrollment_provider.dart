import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import '../../../core/utils/app_logger.dart';

import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';

class EnrollmentNotifier extends StateNotifier<AsyncValue<void>> {
  EnrollmentNotifier(this._firestore, this._ref) : super(const AsyncValue.data(null));

  final FirebaseFirestore _firestore;
  final Ref _ref;

  Future<void> enrollInCourse(String courseId) async {
    state = const AsyncValue.loading();
    
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Проверяем что пользователь еще не записан
      if (user.enrolledCourses.contains(courseId)) {
        throw Exception('Вы уже записаны на этот курс');
      }

      // Обновляем пользователя
      final updatedUser = user.copyWith(
        enrolledCourses: [...user.enrolledCourses, courseId],
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id.toString()).set(
        updatedUser.toJson(),
        SetOptions(merge: true),
      );

      // Увеличиваем счетчик записанных в курсе
      await _firestore.collection('courses').doc(courseId).update({
        'enrolledCount': FieldValue.increment(1),
      });

      // Обновляем провайдер пользователя
      _ref.read(userProvider.notifier).setUser(updatedUser);
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> unenrollFromCourse(String courseId) async {
    state = const AsyncValue.loading();
    
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Проверяем что пользователь записан
      if (!user.enrolledCourses.contains(courseId)) {
        throw Exception('Вы не записаны на этот курс');
      }

      // Обновляем пользователя
      final updatedEnrolledCourses = user.enrolledCourses.where((id) => id != courseId).toList();
      final updatedCourseProgress = Map<String, double>.from(user.courseProgress)..remove(courseId);
      
      final updatedUser = user.copyWith(
        enrolledCourses: updatedEnrolledCourses,
        courseProgress: updatedCourseProgress,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id.toString()).set(
        updatedUser.toJson(),
        SetOptions(merge: true),
      );

      // Уменьшаем счетчик записанных в курсе
      await _firestore.collection('courses').doc(courseId).update({
        'enrolledCount': FieldValue.increment(-1),
      });

      // Обновляем провайдер пользователя
      _ref.read(userProvider.notifier).setUser(updatedUser);
      
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateCourseProgress(String courseId, double progress, {String? lastLessonId}) async {
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) return;

      // Обновляем прогресс и активность
      final updatedCourseProgress = Map<String, double>.from(user.courseProgress);
      updatedCourseProgress[courseId] = progress;
      
      final updatedLastAccessedAt = Map<String, DateTime>.from(user.lastAccessedAt);
      updatedLastAccessedAt[courseId] = DateTime.now();
      
      final updatedLastLessonId = Map<String, String>.from(user.lastLessonId);
      if (lastLessonId != null) {
        updatedLastLessonId[courseId] = lastLessonId;
      }
      
      final updatedUser = user.copyWith(
        courseProgress: updatedCourseProgress,
        lastAccessedAt: updatedLastAccessedAt,
        lastLessonId: updatedLastLessonId,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id.toString()).set(
        updatedUser.toJson(),
        SetOptions(merge: true),
      );

      // Обновляем провайдер пользователя
      _ref.read(userProvider.notifier).setUser(updatedUser);
    } catch (error) {
      // Логгируем ошибку, но не меняем state - это не критично
      AppLogger.warning('Error updating course progress: $error');
    }
  }

  Future<void> updateLastAccessed(String courseId, String lessonId) async {
    try {
      final user = _ref.read(userProvider).value;
      if (user == null) return;

      final updatedLastAccessedAt = Map<String, DateTime>.from(user.lastAccessedAt);
      updatedLastAccessedAt[courseId] = DateTime.now();
      
      final updatedLastLessonId = Map<String, String>.from(user.lastLessonId);
      updatedLastLessonId[courseId] = lessonId;
      
      final updatedUser = user.copyWith(
        lastAccessedAt: updatedLastAccessedAt,
        lastLessonId: updatedLastLessonId,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id.toString()).set(
        updatedUser.toJson(),
        SetOptions(merge: true),
      );

      // Обновляем провайдер пользователя
      _ref.read(userProvider.notifier).setUser(updatedUser);
    } catch (error) {
      AppLogger.warning('Error updating last accessed: $error');
    }
  }
}

final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, AsyncValue<void>>((ref) {
  return EnrollmentNotifier(FirebaseFirestore.instance, ref);
});

// Провайдер для получения курсов пользователя
final enrolledCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final user = ref.watch(userProvider);
  final allCourses = ref.watch(activeCoursesProvider);

  return user.when(
    data: (appUser) {
      if (appUser == null) return const AsyncValue.data([]);
      
      return allCourses.when(
        data: (courses) {
          final enrolledCourses = courses.where((course) => 
            appUser.enrolledCourses.contains(course.id)
          ).toList();
          return AsyncValue.data(enrolledCourses);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Провайдер для получения доступных (не записанных) курсов
final availableCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final user = ref.watch(userProvider);
  final allCourses = ref.watch(activeCoursesProvider);

  return user.when(
    data: (appUser) {
      return allCourses.when(
        data: (courses) {
          if (appUser == null) return AsyncValue.data(courses);
          
          final availableCourses = courses.where((course) => 
            !appUser.enrolledCourses.contains(course.id)
          ).toList();
          return AsyncValue.data(availableCourses);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Провайдер для проверки записан ли пользователь на курс
final isEnrolledProvider = Provider.family<bool, String>((ref, courseId) {
  final user = ref.watch(userProvider);
  return user.when(
    data: (appUser) => appUser?.enrolledCourses.contains(courseId) ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Провайдер для получения прогресса курса
final courseProgressProvider = Provider.family<double, String>((ref, courseId) {
  final user = ref.watch(userProvider);
  return user.when(
    data: (appUser) => appUser?.courseProgress[courseId] ?? 0.0,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Провайдер для получения следующего урока
final nextLessonProvider = Provider<AsyncValue<Map<String, String>?>>((ref) {
  final user = ref.watch(userProvider);
  final enrolledCourses = ref.watch(enrolledCoursesProvider);

  return user.when(
    data: (appUser) {
      if (appUser == null) return const AsyncValue.data(null);
      
      return enrolledCourses.when(
        data: (courses) {
          if (courses.isEmpty) return const AsyncValue.data(null);
          
          // Найдем последний активный курс (курс с самой поздней активностью)
          Course? lastActiveCourse;
          DateTime? latestAccess;
          
          for (final course in courses) {
            final lastAccess = appUser.lastAccessedAt[course.id];
            if (lastAccess != null && (latestAccess == null || lastAccess.isAfter(latestAccess))) {
              latestAccess = lastAccess;
              lastActiveCourse = course;
            }
          }
          
          // Если нет активности, берем первый курс
          lastActiveCourse ??= courses.first;
          
          // Возвращаем курс и последний урок (если есть)
          final lastLessonId = appUser.lastLessonId[lastActiveCourse.id];
          
          return AsyncValue.data({
            'courseId': lastActiveCourse.id,
            'lessonId': lastLessonId ?? '', // пустая строка если урока нет
          });
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}); 