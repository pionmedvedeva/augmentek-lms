import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_progress.dart';
import 'package:miniapp/core/utils/string_utils.dart';

part 'course_progress.freezed.dart';
part 'course_progress.g.dart';

@freezed
class CourseProgress with _$CourseProgress {
  const factory CourseProgress({
    required String id,
    required String userId,
    required String courseId,
    required String courseTitle,
    
    // Общий прогресс
    @Default(0.0) double completionPercentage, // 0.0 - 1.0
    @Default(0) int totalLessons,
    @Default(0) int completedLessons,
    @Default(0) int lessonsInProgress,
    
    // Домашние задания
    @Default(0) int totalHomework,
    @Default(0) int completedHomework,
    @Default(0) int pendingHomework,
    
    // Время обучения
    @Default(0) int totalTimeSpentSeconds,
    DateTime? lastAccessedAt,
    String? currentLessonId, // Текущий урок
    String? nextLessonId,    // Следующий урок для изучения
    
    // Достижения
    @Default([]) List<String> achievements, // ID достижений
    @Default(0) int streak,                 // Дни подряд обучения
    
    // Метаданные
    DateTime? enrolledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CourseProgress;

  factory CourseProgress.fromJson(Map<String, dynamic> json) => _$CourseProgressFromJson(json);
  
  // Вычисляемые свойства
  const CourseProgress._();
  
  /// Статус курса для UI
  CourseStatus get status {
    if (completedLessons == 0) return CourseStatus.notStarted;
    if (completedLessons == totalLessons && completedHomework == totalHomework) {
      return CourseStatus.completed;
    }
    return CourseStatus.inProgress;
  }
  
  /// Есть ли невыполненные домашки
  bool get hasPendingHomework => pendingHomework > 0;
  
  /// Прогресс в процентах для UI (0-100)
  int get completionPercent => (completionPercentage * 100).round();
  
  /// Текстовое описание прогресса
  String get progressText => '$completedLessons из ${RussianPlurals.formatLessons(totalLessons)}';
  
  /// Есть ли следующий урок
  bool get hasNextLesson => nextLessonId != null && nextLessonId!.isNotEmpty;
}

enum CourseStatus {
  notStarted,
  inProgress,
  completed,
}

/// Вспомогательный класс для агрегации прогресса из LessonProgress
class ProgressCalculator {
  static CourseProgress calculateFromLessons({
    required String userId,
    required String courseId,
    required String courseTitle,
    required List<LessonProgress> lessonProgresses,
    required List<String> allLessonIds,
    DateTime? enrolledAt,
  }) {
    final totalLessons = allLessonIds.length;
    final completedLessons = lessonProgresses.where((p) => p.isCompleted).length;
    final lessonsInProgress = lessonProgresses.where((p) => p.isStarted && !p.isCompleted).length;
    
    final totalHomework = lessonProgresses.where((p) => p.hasHomework).length;
    final completedHomework = lessonProgresses.where((p) => p.homeworkCompleted).length;
    final pendingHomework = lessonProgresses.where((p) => p.homeworkSubmitted && !p.homeworkCompleted).length;
    
    final totalTimeSpent = lessonProgresses.fold<int>(0, (sum, p) => sum + p.timeSpentSeconds);
    final lastAccessed = lessonProgresses
        .where((p) => p.startedAt != null)
        .map((p) => p.startedAt!)
        .fold<DateTime?>(null, (latest, date) => latest == null || date.isAfter(latest) ? date : latest);
    
    // Находим следующий урок для изучения
    // Сначала ищем текущий урок (начатый, но не завершенный)
    final currentLessonIndex = lessonProgresses.indexWhere((p) => p.isStarted && !p.isCompleted);
    
    String? nextLessonId;
    if (currentLessonIndex != -1) {
      // Если есть урок в процессе, он и есть следующий
      nextLessonId = lessonProgresses[currentLessonIndex].lessonId;
    } else {
      // Иначе ищем первый неначатый урок среди всех уроков курса
      final startedLessonIds = lessonProgresses.map((p) => p.lessonId).toSet();
      for (final lessonId in allLessonIds) {
        if (!startedLessonIds.contains(lessonId)) {
          nextLessonId = lessonId;
          break;
        }
      }
    }
    
    final completionPercentage = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    
    return CourseProgress(
      id: '${userId}_$courseId',
      userId: userId,
      courseId: courseId,
      courseTitle: courseTitle,
      completionPercentage: completionPercentage,
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      lessonsInProgress: lessonsInProgress,
      totalHomework: totalHomework,
      completedHomework: completedHomework,
      pendingHomework: pendingHomework,
      totalTimeSpentSeconds: totalTimeSpent,
      lastAccessedAt: lastAccessed,
      currentLessonId: currentLessonIndex >= 0 ? lessonProgresses[currentLessonIndex].lessonId : null,
      nextLessonId: nextLessonId,
      enrolledAt: enrolledAt,
      startedAt: lessonProgresses.isNotEmpty ? lessonProgresses.first.startedAt : null,
      completedAt: completedLessons == totalLessons ? DateTime.now() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 