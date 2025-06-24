import 'package:freezed_annotation/freezed_annotation.dart';

part 'homework_submission.freezed.dart';
part 'homework_submission.g.dart';

enum HomeworkStatus {
  pending,    // Ожидает проверки
  approved,   // Зачтено
  needsWork,  // Требует доработки
}

@freezed
class HomeworkSubmission with _$HomeworkSubmission {
  const factory HomeworkSubmission({
    required String id,
    required String lessonId,
    required String courseId,
    required String studentId,
    required String studentName,
    required String answer,
    required HomeworkStatus status,
    String? adminComment,  // Комментарий от преподавателя
    String? reviewedBy,    // ID админа который проверил
    required DateTime submittedAt,
    DateTime? reviewedAt,
  }) = _HomeworkSubmission;

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) =>
      _$HomeworkSubmissionFromJson(json);
} 