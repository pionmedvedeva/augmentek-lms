// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonProgressImpl _$$LessonProgressImplFromJson(Map<String, dynamic> json) =>
    _$LessonProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      lessonId: json['lessonId'] as String,
      lessonTitle: json['lessonTitle'] as String,
      courseTitle: json['courseTitle'] as String,
      isStarted: json['isStarted'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      hasHomework: json['hasHomework'] as bool? ?? false,
      homeworkSubmitted: json['homeworkSubmitted'] as bool? ?? false,
      homeworkCompleted: json['homeworkCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LessonProgressImplToJson(
        _$LessonProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'courseId': instance.courseId,
      'lessonId': instance.lessonId,
      'lessonTitle': instance.lessonTitle,
      'courseTitle': instance.courseTitle,
      'isStarted': instance.isStarted,
      'isCompleted': instance.isCompleted,
      'completionPercentage': instance.completionPercentage,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'timeSpentSeconds': instance.timeSpentSeconds,
      'hasHomework': instance.hasHomework,
      'homeworkSubmitted': instance.homeworkSubmitted,
      'homeworkCompleted': instance.homeworkCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
