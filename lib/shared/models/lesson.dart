import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String courseId,
    String? sectionId, // ID раздела к которому принадлежит урок
    required String title,
    required String description,
    String? content, // Длинный текст урока
    String? videoUrl, // Ссылка на видео
    String? documentUrl,
    String? homeworkTask, // Формулировка домашнего задания
    String? homeworkAnswer, // Поле для ответа на домашку
    @Default(0) int order,
    @Default(0) int durationMinutes,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
} 