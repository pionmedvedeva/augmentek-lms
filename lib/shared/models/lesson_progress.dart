import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_progress.freezed.dart';
part 'lesson_progress.g.dart';

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String id,
    required String userId,
    required String courseId,
    required String lessonId,
    required String lessonTitle,
    required String courseTitle,
    
    // Статус прохождения урока
    @Default(false) bool isStarted,
    @Default(false) bool isCompleted,
    @Default(0.0) double completionPercentage, // 0.0 - 1.0
    
    // Время обучения
    DateTime? startedAt,
    DateTime? completedAt,
    @Default(0) int timeSpentSeconds, // Время потраченное на урок
    
    // Домашнее задание
    @Default(false) bool hasHomework,
    @Default(false) bool homeworkSubmitted,
    @Default(false) bool homeworkCompleted,
    
    // Метаданные
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) => _$LessonProgressFromJson(json);
  
  // Вычисляемые свойства
  const LessonProgress._();
  
  /// Полностью ли завершен урок (включая домашку если есть)
  bool get isFullyCompleted {
    if (!isCompleted) return false;
    if (hasHomework && !homeworkCompleted) return false;
    return true;
  }
  
  /// Статус урока для UI
  LessonStatus get status {
    if (!isStarted) return LessonStatus.notStarted;
    if (isFullyCompleted) return LessonStatus.completed;
    if (hasHomework && homeworkSubmitted && !homeworkCompleted) {
      return LessonStatus.pendingReview;
    }
    return LessonStatus.inProgress;
  }
}

enum LessonStatus {
  notStarted,
  inProgress, 
  completed,
  pendingReview, // Домашка отправлена, ждет проверки
} 