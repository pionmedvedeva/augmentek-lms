// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      sectionId: json['sectionId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String?,
      videoUrl: json['videoUrl'] as String?,
      documentUrl: json['documentUrl'] as String?,
      homeworkTask: json['homeworkTask'] as String?,
      homeworkAnswer: json['homeworkAnswer'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'sectionId': instance.sectionId,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'videoUrl': instance.videoUrl,
      'documentUrl': instance.documentUrl,
      'homeworkTask': instance.homeworkTask,
      'homeworkAnswer': instance.homeworkAnswer,
      'order': instance.order,
      'durationMinutes': instance.durationMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
