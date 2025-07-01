// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseProgressImpl _$$CourseProgressImplFromJson(Map<String, dynamic> json) =>
    _$CourseProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      courseId: json['courseId'] as String,
      courseTitle: json['courseTitle'] as String,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      lessonsInProgress: (json['lessonsInProgress'] as num?)?.toInt() ?? 0,
      totalHomework: (json['totalHomework'] as num?)?.toInt() ?? 0,
      completedHomework: (json['completedHomework'] as num?)?.toInt() ?? 0,
      pendingHomework: (json['pendingHomework'] as num?)?.toInt() ?? 0,
      totalTimeSpentSeconds:
          (json['totalTimeSpentSeconds'] as num?)?.toInt() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      currentLessonId: json['currentLessonId'] as String?,
      nextLessonId: json['nextLessonId'] as String?,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      enrolledAt: json['enrolledAt'] == null
          ? null
          : DateTime.parse(json['enrolledAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CourseProgressImplToJson(
        _$CourseProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'courseId': instance.courseId,
      'courseTitle': instance.courseTitle,
      'completionPercentage': instance.completionPercentage,
      'totalLessons': instance.totalLessons,
      'completedLessons': instance.completedLessons,
      'lessonsInProgress': instance.lessonsInProgress,
      'totalHomework': instance.totalHomework,
      'completedHomework': instance.completedHomework,
      'pendingHomework': instance.pendingHomework,
      'totalTimeSpentSeconds': instance.totalTimeSpentSeconds,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'currentLessonId': instance.currentLessonId,
      'nextLessonId': instance.nextLessonId,
      'achievements': instance.achievements,
      'streak': instance.streak,
      'enrolledAt': instance.enrolledAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
