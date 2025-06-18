// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      courseIds: (json['courseIds'] as List<dynamic>?)
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

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'courseIds': instance.courseIds,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
