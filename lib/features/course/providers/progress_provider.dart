import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/lesson_progress.dart';
import '../../../shared/models/course_progress.dart';
import '../../../shared/models/homework_submission.dart';
import '../repositories/progress_repository.dart';

// Провайдер репозитория
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

// Провайдер для получения прогресса курса
final courseProgressProvider = FutureProvider.family<CourseProgress?, String>((ref, params) async {
  final parts = params.split('_');
  if (parts.length != 2) return null;
  
  final userId = parts[0];
  final courseId = parts[1];
  
  final repository = ref.read(progressRepositoryProvider);
  return repository.getCourseProgress(userId, courseId);
});

// Провайдер для получения всех прогрессов курсов пользователя
final userCourseProgressesProvider = FutureProvider.family<List<CourseProgress>, String>((ref, userId) async {
  final repository = ref.read(progressRepositoryProvider);
  return repository.getUserCourseProgresses(userId);
});

// Провайдер для получения следующего урока
final nextLessonProvider = FutureProvider.family<Map<String, String>?, String>((ref, userId) async {
  final repository = ref.read(progressRepositoryProvider);
  return repository.getNextLesson(userId);
});

// Провайдер для получения прогресса урока
final lessonProgressProvider = FutureProvider.family<LessonProgress?, String>((ref, params) async {
  final parts = params.split('_');
  if (parts.length != 2) return null;
  
  final userId = parts[0];
  final lessonId = parts[1];
  
  final repository = ref.read(progressRepositoryProvider);
  return repository.getLessonProgress(userId, lessonId);
});

// Провайдер для получения прогрессов уроков курса
final courseLessonProgressesProvider = FutureProvider.family<List<LessonProgress>, String>((ref, params) async {
  final parts = params.split('_');
  if (parts.length != 2) return [];
  
  final userId = parts[0];
  final courseId = parts[1];
  
  final repository = ref.read(progressRepositoryProvider);
  return repository.getLessonProgressesForCourse(userId, courseId);
});

// Основной провайдер для управления прогрессом
class ProgressNotifier extends StateNotifier<AsyncValue<void>> {
  ProgressNotifier(this._repository) : super(const AsyncValue.data(null));

  final ProgressRepository _repository;

  /// Отметить урок как начатый
  Future<void> markLessonStarted(String userId, String courseId, String lessonId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markLessonStarted(userId, courseId, lessonId);
      state = const AsyncValue.data(null);
      AppLogger.info('Урок отмечен как начатый');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Ошибка отметки урока как начатого: $e');
    }
  }

  /// Отметить урок как завершенный
  Future<void> markLessonCompleted(String userId, String courseId, String lessonId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markLessonCompleted(userId, courseId, lessonId);
      state = const AsyncValue.data(null);
      AppLogger.info('Урок отмечен как завершенный');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Ошибка отметки урока как завершенного: $e');
    }
  }

  /// Обновить прогресс домашнего задания
  Future<void> updateHomeworkProgress(String userId, String lessonId, {
    bool? submitted,
    bool? completed,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateHomeworkProgress(
        userId, 
        lessonId,
        submitted: submitted,
        completed: completed,
      );
      state = const AsyncValue.data(null);
      AppLogger.info('Прогресс домашки обновлен');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Ошибка обновления прогресса домашки: $e');
    }
  }

  /// Синхронизировать прогресс с домашним заданием
  Future<void> syncHomeworkProgress(String userId, String lessonId, HomeworkStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.syncHomeworkProgress(userId, lessonId, status);
      state = const AsyncValue.data(null);
      AppLogger.info('Прогресс синхронизирован с домашкой');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      AppLogger.error('Ошибка синхронизации прогресса: $e');
    }
  }
}

// Провайдер для управления прогрессом
final progressNotifierProvider = StateNotifierProvider<ProgressNotifier, AsyncValue<void>>((ref) {
  return ProgressNotifier(ref.read(progressRepositoryProvider));
});

/// Хелпер-класс для работы с прогрессом в UI
class ProgressHelper {
  /// Получить цвет для статуса урока
  static Color getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.notStarted:
        return Colors.grey;
      case LessonStatus.inProgress:
        return Colors.orange;
      case LessonStatus.completed:
        return Colors.green;
      case LessonStatus.pendingReview:
        return Colors.blue;
    }
  }

  /// Получить иконку для статуса урока
  static IconData getStatusIcon(LessonStatus status) {
    switch (status) {
      case LessonStatus.notStarted:
        return Icons.radio_button_unchecked;
      case LessonStatus.inProgress:
        return Icons.play_circle_outline;
      case LessonStatus.completed:
        return Icons.check_circle;
      case LessonStatus.pendingReview:
        return Icons.pending;
    }
  }

  /// Получить текст для статуса урока
  static String getStatusText(LessonStatus status) {
    switch (status) {
      case LessonStatus.notStarted:
        return 'Не начат';
      case LessonStatus.inProgress:
        return 'В процессе';
      case LessonStatus.completed:
        return 'Завершен';
      case LessonStatus.pendingReview:
        return 'На проверке';
    }
  }

  /// Получить цвет для прогресса курса
  static Color getCourseProgressColor(double progress) {
    if (progress == 0.0) return Colors.grey;
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  /// Форматировать время обучения
  static String formatStudyTime(int seconds) {
    if (seconds < 60) return '$seconds сек';
    if (seconds < 3600) return '${(seconds / 60).round()} мин';
    return '${(seconds / 3600).toStringAsFixed(1)} ч';
  }

  /// Получить мотивационное сообщение на основе прогресса
  static String getMotivationalMessage(CourseProgress progress) {
    final percent = progress.completionPercent;
    
    if (percent == 0) {
      return 'Время начать! Первый урок ждет тебя 🚀';
    } else if (percent < 25) {
      return 'Отличное начало! Продолжай в том же духе 💪';
    } else if (percent < 50) {
      return 'Ты на полпути к цели! Не останавливайся 🎯';
    } else if (percent < 75) {
      return 'Больше половины позади! Финиш уже близко 🏃‍♂️';
    } else if (percent < 100) {
      return 'Почти у цели! Осталось совсем немного 🔥';
    } else {
      return 'Поздравляем! Курс завершен! 🎉';
    }
  }
}

/// Виджет-обертка для автоматического обновления прогресса
class ProgressTracker extends ConsumerWidget {
  const ProgressTracker({
    super.key,
    required this.userId,
    required this.courseId,
    required this.lessonId,
    required this.child,
    this.autoMarkStarted = true,
  });

  final String userId;
  final String courseId;
  final String lessonId;
  final Widget child;
  final bool autoMarkStarted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Автоматически отмечаем урок как начатый при первом просмотре
    if (autoMarkStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(progressNotifierProvider.notifier)
            .markLessonStarted(userId, courseId, lessonId);
      });
    }

    return child;
  }
} 