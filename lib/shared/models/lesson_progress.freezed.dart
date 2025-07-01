// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LessonProgress _$LessonProgressFromJson(Map<String, dynamic> json) {
  return _LessonProgress.fromJson(json);
}

/// @nodoc
mixin _$LessonProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get courseId => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  String get lessonTitle => throw _privateConstructorUsedError;
  String get courseTitle =>
      throw _privateConstructorUsedError; // Статус прохождения урока
  bool get isStarted => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  double get completionPercentage =>
      throw _privateConstructorUsedError; // 0.0 - 1.0
// Время обучения
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get timeSpentSeconds =>
      throw _privateConstructorUsedError; // Время потраченное на урок
// Домашнее задание
  bool get hasHomework => throw _privateConstructorUsedError;
  bool get homeworkSubmitted => throw _privateConstructorUsedError;
  bool get homeworkCompleted =>
      throw _privateConstructorUsedError; // Метаданные
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LessonProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonProgressCopyWith<LessonProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonProgressCopyWith<$Res> {
  factory $LessonProgressCopyWith(
          LessonProgress value, $Res Function(LessonProgress) then) =
      _$LessonProgressCopyWithImpl<$Res, LessonProgress>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String courseId,
      String lessonId,
      String lessonTitle,
      String courseTitle,
      bool isStarted,
      bool isCompleted,
      double completionPercentage,
      DateTime? startedAt,
      DateTime? completedAt,
      int timeSpentSeconds,
      bool hasHomework,
      bool homeworkSubmitted,
      bool homeworkCompleted,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$LessonProgressCopyWithImpl<$Res, $Val extends LessonProgress>
    implements $LessonProgressCopyWith<$Res> {
  _$LessonProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? courseId = null,
    Object? lessonId = null,
    Object? lessonTitle = null,
    Object? courseTitle = null,
    Object? isStarted = null,
    Object? isCompleted = null,
    Object? completionPercentage = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? timeSpentSeconds = null,
    Object? hasHomework = null,
    Object? homeworkSubmitted = null,
    Object? homeworkCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonTitle: null == lessonTitle
          ? _value.lessonTitle
          : lessonTitle // ignore: cast_nullable_to_non_nullable
              as String,
      courseTitle: null == courseTitle
          ? _value.courseTitle
          : courseTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isStarted: null == isStarted
          ? _value.isStarted
          : isStarted // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeSpentSeconds: null == timeSpentSeconds
          ? _value.timeSpentSeconds
          : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      hasHomework: null == hasHomework
          ? _value.hasHomework
          : hasHomework // ignore: cast_nullable_to_non_nullable
              as bool,
      homeworkSubmitted: null == homeworkSubmitted
          ? _value.homeworkSubmitted
          : homeworkSubmitted // ignore: cast_nullable_to_non_nullable
              as bool,
      homeworkCompleted: null == homeworkCompleted
          ? _value.homeworkCompleted
          : homeworkCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$LessonProgressImplCopyWith<$Res>
    implements $LessonProgressCopyWith<$Res> {
  factory _$$LessonProgressImplCopyWith(_$LessonProgressImpl value,
          $Res Function(_$LessonProgressImpl) then) =
      __$$LessonProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String courseId,
      String lessonId,
      String lessonTitle,
      String courseTitle,
      bool isStarted,
      bool isCompleted,
      double completionPercentage,
      DateTime? startedAt,
      DateTime? completedAt,
      int timeSpentSeconds,
      bool hasHomework,
      bool homeworkSubmitted,
      bool homeworkCompleted,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$LessonProgressImplCopyWithImpl<$Res>
    extends _$LessonProgressCopyWithImpl<$Res, _$LessonProgressImpl>
    implements _$$LessonProgressImplCopyWith<$Res> {
  __$$LessonProgressImplCopyWithImpl(
      _$LessonProgressImpl _value, $Res Function(_$LessonProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? courseId = null,
    Object? lessonId = null,
    Object? lessonTitle = null,
    Object? courseTitle = null,
    Object? isStarted = null,
    Object? isCompleted = null,
    Object? completionPercentage = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? timeSpentSeconds = null,
    Object? hasHomework = null,
    Object? homeworkSubmitted = null,
    Object? homeworkCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$LessonProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonTitle: null == lessonTitle
          ? _value.lessonTitle
          : lessonTitle // ignore: cast_nullable_to_non_nullable
              as String,
      courseTitle: null == courseTitle
          ? _value.courseTitle
          : courseTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isStarted: null == isStarted
          ? _value.isStarted
          : isStarted // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeSpentSeconds: null == timeSpentSeconds
          ? _value.timeSpentSeconds
          : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      hasHomework: null == hasHomework
          ? _value.hasHomework
          : hasHomework // ignore: cast_nullable_to_non_nullable
              as bool,
      homeworkSubmitted: null == homeworkSubmitted
          ? _value.homeworkSubmitted
          : homeworkSubmitted // ignore: cast_nullable_to_non_nullable
              as bool,
      homeworkCompleted: null == homeworkCompleted
          ? _value.homeworkCompleted
          : homeworkCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$LessonProgressImpl extends _LessonProgress {
  const _$LessonProgressImpl(
      {required this.id,
      required this.userId,
      required this.courseId,
      required this.lessonId,
      required this.lessonTitle,
      required this.courseTitle,
      this.isStarted = false,
      this.isCompleted = false,
      this.completionPercentage = 0.0,
      this.startedAt,
      this.completedAt,
      this.timeSpentSeconds = 0,
      this.hasHomework = false,
      this.homeworkSubmitted = false,
      this.homeworkCompleted = false,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  factory _$LessonProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String courseId;
  @override
  final String lessonId;
  @override
  final String lessonTitle;
  @override
  final String courseTitle;
// Статус прохождения урока
  @override
  @JsonKey()
  final bool isStarted;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final double completionPercentage;
// 0.0 - 1.0
// Время обучения
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int timeSpentSeconds;
// Время потраченное на урок
// Домашнее задание
  @override
  @JsonKey()
  final bool hasHomework;
  @override
  @JsonKey()
  final bool homeworkSubmitted;
  @override
  @JsonKey()
  final bool homeworkCompleted;
// Метаданные
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'LessonProgress(id: $id, userId: $userId, courseId: $courseId, lessonId: $lessonId, lessonTitle: $lessonTitle, courseTitle: $courseTitle, isStarted: $isStarted, isCompleted: $isCompleted, completionPercentage: $completionPercentage, startedAt: $startedAt, completedAt: $completedAt, timeSpentSeconds: $timeSpentSeconds, hasHomework: $hasHomework, homeworkSubmitted: $homeworkSubmitted, homeworkCompleted: $homeworkCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.lessonTitle, lessonTitle) ||
                other.lessonTitle == lessonTitle) &&
            (identical(other.courseTitle, courseTitle) ||
                other.courseTitle == courseTitle) &&
            (identical(other.isStarted, isStarted) ||
                other.isStarted == isStarted) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.timeSpentSeconds, timeSpentSeconds) ||
                other.timeSpentSeconds == timeSpentSeconds) &&
            (identical(other.hasHomework, hasHomework) ||
                other.hasHomework == hasHomework) &&
            (identical(other.homeworkSubmitted, homeworkSubmitted) ||
                other.homeworkSubmitted == homeworkSubmitted) &&
            (identical(other.homeworkCompleted, homeworkCompleted) ||
                other.homeworkCompleted == homeworkCompleted) &&
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
      userId,
      courseId,
      lessonId,
      lessonTitle,
      courseTitle,
      isStarted,
      isCompleted,
      completionPercentage,
      startedAt,
      completedAt,
      timeSpentSeconds,
      hasHomework,
      homeworkSubmitted,
      homeworkCompleted,
      createdAt,
      updatedAt);

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      __$$LessonProgressImplCopyWithImpl<_$LessonProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonProgressImplToJson(
      this,
    );
  }
}

abstract class _LessonProgress extends LessonProgress {
  const factory _LessonProgress(
      {required final String id,
      required final String userId,
      required final String courseId,
      required final String lessonId,
      required final String lessonTitle,
      required final String courseTitle,
      final bool isStarted,
      final bool isCompleted,
      final double completionPercentage,
      final DateTime? startedAt,
      final DateTime? completedAt,
      final int timeSpentSeconds,
      final bool hasHomework,
      final bool homeworkSubmitted,
      final bool homeworkCompleted,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$LessonProgressImpl;
  const _LessonProgress._() : super._();

  factory _LessonProgress.fromJson(Map<String, dynamic> json) =
      _$LessonProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get courseId;
  @override
  String get lessonId;
  @override
  String get lessonTitle;
  @override
  String get courseTitle; // Статус прохождения урока
  @override
  bool get isStarted;
  @override
  bool get isCompleted;
  @override
  double get completionPercentage; // 0.0 - 1.0
// Время обучения
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  int get timeSpentSeconds; // Время потраченное на урок
// Домашнее задание
  @override
  bool get hasHomework;
  @override
  bool get homeworkSubmitted;
  @override
  bool get homeworkCompleted; // Метаданные
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
