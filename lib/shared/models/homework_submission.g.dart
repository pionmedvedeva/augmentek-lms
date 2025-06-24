// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeworkSubmissionImpl _$$HomeworkSubmissionImplFromJson(
        Map<String, dynamic> json) =>
    _$HomeworkSubmissionImpl(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      answer: json['answer'] as String,
      status: $enumDecode(_$HomeworkStatusEnumMap, json['status']),
      adminComment: json['adminComment'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
    );

Map<String, dynamic> _$$HomeworkSubmissionImplToJson(
        _$HomeworkSubmissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'courseId': instance.courseId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'answer': instance.answer,
      'status': _$HomeworkStatusEnumMap[instance.status]!,
      'adminComment': instance.adminComment,
      'reviewedBy': instance.reviewedBy,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
    };

const _$HomeworkStatusEnumMap = {
  HomeworkStatus.pending: 'pending',
  HomeworkStatus.approved: 'approved',
  HomeworkStatus.needsWork: 'needsWork',
};
