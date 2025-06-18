// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      instructor: json['instructor'] as String,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      lessonIds: (json['lessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'instructor': instance.instructor,
      'duration': instance.duration,
      'likes': instance.likes,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'lessonIds': instance.lessonIds,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
