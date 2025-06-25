// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  int get id => throw _privateConstructorUsedError;
  String? get firebaseId => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get languageCode => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool get isAdmin => throw _privateConstructorUsedError;
  List<String> get enrolledCourses => throw _privateConstructorUsedError;
  Map<String, double> get courseProgress => throw _privateConstructorUsedError;
  Map<String, DateTime> get lastAccessedAt =>
      throw _privateConstructorUsedError; // курс -> дата последнего доступа
  Map<String, String> get lastLessonId =>
      throw _privateConstructorUsedError; // курс -> ID последнего урока
  Map<String, dynamic> get settings => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {int id,
      String? firebaseId,
      String firstName,
      String? lastName,
      String? username,
      String? languageCode,
      String? photoUrl,
      bool isAdmin,
      List<String> enrolledCourses,
      Map<String, double> courseProgress,
      Map<String, DateTime> lastAccessedAt,
      Map<String, String> lastLessonId,
      Map<String, dynamic> settings,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseId = freezed,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? languageCode = freezed,
    Object? photoUrl = freezed,
    Object? isAdmin = null,
    Object? enrolledCourses = null,
    Object? courseProgress = null,
    Object? lastAccessedAt = null,
    Object? lastLessonId = null,
    Object? settings = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      firebaseId: freezed == firebaseId
          ? _value.firebaseId
          : firebaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      languageCode: freezed == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      enrolledCourses: null == enrolledCourses
          ? _value.enrolledCourses
          : enrolledCourses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      courseProgress: null == courseProgress
          ? _value.courseProgress
          : courseProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastAccessedAt: null == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      lastLessonId: null == lastLessonId
          ? _value.lastLessonId
          : lastLessonId // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? firebaseId,
      String firstName,
      String? lastName,
      String? username,
      String? languageCode,
      String? photoUrl,
      bool isAdmin,
      List<String> enrolledCourses,
      Map<String, double> courseProgress,
      Map<String, DateTime> lastAccessedAt,
      Map<String, String> lastLessonId,
      Map<String, dynamic> settings,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firebaseId = freezed,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? languageCode = freezed,
    Object? photoUrl = freezed,
    Object? isAdmin = null,
    Object? enrolledCourses = null,
    Object? courseProgress = null,
    Object? lastAccessedAt = null,
    Object? lastLessonId = null,
    Object? settings = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      firebaseId: freezed == firebaseId
          ? _value.firebaseId
          : firebaseId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      languageCode: freezed == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      enrolledCourses: null == enrolledCourses
          ? _value._enrolledCourses
          : enrolledCourses // ignore: cast_nullable_to_non_nullable
              as List<String>,
      courseProgress: null == courseProgress
          ? _value._courseProgress
          : courseProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      lastAccessedAt: null == lastAccessedAt
          ? _value._lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      lastLessonId: null == lastLessonId
          ? _value._lastLessonId
          : lastLessonId // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      settings: null == settings
          ? _value._settings
          : settings // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.id,
      this.firebaseId,
      required this.firstName,
      this.lastName,
      this.username,
      this.languageCode,
      this.photoUrl,
      this.isAdmin = false,
      final List<String> enrolledCourses = const [],
      final Map<String, double> courseProgress = const {},
      final Map<String, DateTime> lastAccessedAt = const {},
      final Map<String, String> lastLessonId = const {},
      final Map<String, dynamic> settings = const {},
      required this.createdAt,
      required this.updatedAt})
      : _enrolledCourses = enrolledCourses,
        _courseProgress = courseProgress,
        _lastAccessedAt = lastAccessedAt,
        _lastLessonId = lastLessonId,
        _settings = settings;

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final int id;
  @override
  final String? firebaseId;
  @override
  final String firstName;
  @override
  final String? lastName;
  @override
  final String? username;
  @override
  final String? languageCode;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final bool isAdmin;
  final List<String> _enrolledCourses;
  @override
  @JsonKey()
  List<String> get enrolledCourses {
    if (_enrolledCourses is EqualUnmodifiableListView) return _enrolledCourses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enrolledCourses);
  }

  final Map<String, double> _courseProgress;
  @override
  @JsonKey()
  Map<String, double> get courseProgress {
    if (_courseProgress is EqualUnmodifiableMapView) return _courseProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_courseProgress);
  }

  final Map<String, DateTime> _lastAccessedAt;
  @override
  @JsonKey()
  Map<String, DateTime> get lastAccessedAt {
    if (_lastAccessedAt is EqualUnmodifiableMapView) return _lastAccessedAt;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastAccessedAt);
  }

// курс -> дата последнего доступа
  final Map<String, String> _lastLessonId;
// курс -> дата последнего доступа
  @override
  @JsonKey()
  Map<String, String> get lastLessonId {
    if (_lastLessonId is EqualUnmodifiableMapView) return _lastLessonId;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastLessonId);
  }

// курс -> ID последнего урока
  final Map<String, dynamic> _settings;
// курс -> ID последнего урока
  @override
  @JsonKey()
  Map<String, dynamic> get settings {
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_settings);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, firebaseId: $firebaseId, firstName: $firstName, lastName: $lastName, username: $username, languageCode: $languageCode, photoUrl: $photoUrl, isAdmin: $isAdmin, enrolledCourses: $enrolledCourses, courseProgress: $courseProgress, lastAccessedAt: $lastAccessedAt, lastLessonId: $lastLessonId, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firebaseId, firebaseId) ||
                other.firebaseId == firebaseId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            const DeepCollectionEquality()
                .equals(other._enrolledCourses, _enrolledCourses) &&
            const DeepCollectionEquality()
                .equals(other._courseProgress, _courseProgress) &&
            const DeepCollectionEquality()
                .equals(other._lastAccessedAt, _lastAccessedAt) &&
            const DeepCollectionEquality()
                .equals(other._lastLessonId, _lastLessonId) &&
            const DeepCollectionEquality().equals(other._settings, _settings) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firebaseId,
      firstName,
      lastName,
      username,
      languageCode,
      photoUrl,
      isAdmin,
      const DeepCollectionEquality().hash(_enrolledCourses),
      const DeepCollectionEquality().hash(_courseProgress),
      const DeepCollectionEquality().hash(_lastAccessedAt),
      const DeepCollectionEquality().hash(_lastLessonId),
      const DeepCollectionEquality().hash(_settings),
      createdAt,
      updatedAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final int id,
      final String? firebaseId,
      required final String firstName,
      final String? lastName,
      final String? username,
      final String? languageCode,
      final String? photoUrl,
      final bool isAdmin,
      final List<String> enrolledCourses,
      final Map<String, double> courseProgress,
      final Map<String, DateTime> lastAccessedAt,
      final Map<String, String> lastLessonId,
      final Map<String, dynamic> settings,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  int get id;
  @override
  String? get firebaseId;
  @override
  String get firstName;
  @override
  String? get lastName;
  @override
  String? get username;
  @override
  String? get languageCode;
  @override
  String? get photoUrl;
  @override
  bool get isAdmin;
  @override
  List<String> get enrolledCourses;
  @override
  Map<String, double> get courseProgress;
  @override
  Map<String, DateTime> get lastAccessedAt; // курс -> дата последнего доступа
  @override
  Map<String, String> get lastLessonId; // курс -> ID последнего урока
  @override
  Map<String, dynamic> get settings;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
