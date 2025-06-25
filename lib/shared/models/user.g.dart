// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: (json['id'] as num).toInt(),
      firebaseId: json['firebaseId'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      languageCode: json['languageCode'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      enrolledCourses: (json['enrolledCourses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      courseProgress: (json['courseProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      lastAccessedAt: (json['lastAccessedAt'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      lastLessonId: (json['lastLessonId'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firebaseId': instance.firebaseId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'languageCode': instance.languageCode,
      'photoUrl': instance.photoUrl,
      'isAdmin': instance.isAdmin,
      'enrolledCourses': instance.enrolledCourses,
      'courseProgress': instance.courseProgress,
      'lastAccessedAt': instance.lastAccessedAt
          .map((k, e) => MapEntry(k, e.toIso8601String())),
      'lastLessonId': instance.lastLessonId,
      'settings': instance.settings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
