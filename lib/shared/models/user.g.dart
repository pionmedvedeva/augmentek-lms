// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      languageCode: json['languageCode'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'languageCode': instance.languageCode,
      'isAdmin': instance.isAdmin,
      'settings': instance.settings,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
