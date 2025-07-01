// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CourseProgress _$CourseProgressFromJson(Map<String, dynamic> json) {
  return _CourseProgress.fromJson(json);
}

/// @nodoc
mixin _$CourseProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get courseId => throw _privateConstructorUsedError;
  String get courseTitle =>
      throw _privateConstructorUsedError; // Общий прогресс
  double get completionPercentage =>
      throw _privateConstructorUsedError; // 0.0 - 1.0
  int get totalLessons => throw _privateConstructorUsedError;
  int get completedLessons => throw _privateConstructorUsedError;
  int get lessonsInProgress =>
      throw _privateConstructorUsedError; // Домашние задания
  int get totalHomework => throw _privateConstructorUsedError;
  int get completedHomework => throw _privateConstructorUsedError;
  int get pendingHomework =>
      throw _privateConstructorUsedError; // Время обучения
  int get totalTimeSpentSeconds => throw _privateConstructorUsedError;
  DateTime? get lastAccessedAt => throw _privateConstructorUsedError;
  String? get currentLessonId =>
      throw _privateConstructorUsedError; // Текущий урок
  String? get nextLessonId =>
      throw _privateConstructorUsedError; // Следующий урок для изучения
// Достижения
  List<String> get achievements =>
      throw _privateConstructorUsedError; // ID достижений
  int get streak => throw _privateConstructorUsedError; // Дни подряд обучения
// Метаданные
  DateTime? get enrolledAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CourseProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseProgressCopyWith<CourseProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseProgressCopyWith<$Res> {
  factory $CourseProgressCopyWith(
          CourseProgress value, $Res Function(CourseProgress) then) =
      _$CourseProgressCopyWithImpl<$Res, CourseProgress>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String courseId,
      String courseTitle,
      double completionPercentage,
      int totalLessons,
      int completedLessons,
      int lessonsInProgress,
      int totalHomework,
      int completedHomework,
      int pendingHomework,
      int totalTimeSpentSeconds,
      DateTime? lastAccessedAt,
      String? currentLessonId,
      String? nextLessonId,
      List<String> achievements,
      int streak,
      DateTime? enrolledAt,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CourseProgressCopyWithImpl<$Res, $Val extends CourseProgress>
    implements $CourseProgressCopyWith<$Res> {
  _$CourseProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? courseId = null,
    Object? courseTitle = null,
    Object? completionPercentage = null,
    Object? totalLessons = null,
    Object? completedLessons = null,
    Object? lessonsInProgress = null,
    Object? totalHomework = null,
    Object? completedHomework = null,
    Object? pendingHomework = null,
    Object? totalTimeSpentSeconds = null,
    Object? lastAccessedAt = freezed,
    Object? currentLessonId = freezed,
    Object? nextLessonId = freezed,
    Object? achievements = null,
    Object? streak = null,
    Object? enrolledAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
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
      courseTitle: null == courseTitle
          ? _value.courseTitle
          : courseTitle // ignore: cast_nullable_to_non_nullable
              as String,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      totalLessons: null == totalLessons
          ? _value.totalLessons
          : totalLessons // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsInProgress: null == lessonsInProgress
          ? _value.lessonsInProgress
          : lessonsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      totalHomework: null == totalHomework
          ? _value.totalHomework
          : totalHomework // ignore: cast_nullable_to_non_nullable
              as int,
      completedHomework: null == completedHomework
          ? _value.completedHomework
          : completedHomework // ignore: cast_nullable_to_non_nullable
              as int,
      pendingHomework: null == pendingHomework
          ? _value.pendingHomework
          : pendingHomework // ignore: cast_nullable_to_non_nullable
              as int,
      totalTimeSpentSeconds: null == totalTimeSpentSeconds
          ? _value.totalTimeSpentSeconds
          : totalTimeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      lastAccessedAt: freezed == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentLessonId: freezed == currentLessonId
          ? _value.currentLessonId
          : currentLessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      nextLessonId: freezed == nextLessonId
          ? _value.nextLessonId
          : nextLessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      enrolledAt: freezed == enrolledAt
          ? _value.enrolledAt
          : enrolledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
abstract class _$$CourseProgressImplCopyWith<$Res>
    implements $CourseProgressCopyWith<$Res> {
  factory _$$CourseProgressImplCopyWith(_$CourseProgressImpl value,
          $Res Function(_$CourseProgressImpl) then) =
      __$$CourseProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String courseId,
      String courseTitle,
      double completionPercentage,
      int totalLessons,
      int completedLessons,
      int lessonsInProgress,
      int totalHomework,
      int completedHomework,
      int pendingHomework,
      int totalTimeSpentSeconds,
      DateTime? lastAccessedAt,
      String? currentLessonId,
      String? nextLessonId,
      List<String> achievements,
      int streak,
      DateTime? enrolledAt,
      DateTime? startedAt,
      DateTime? completedAt,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$CourseProgressImplCopyWithImpl<$Res>
    extends _$CourseProgressCopyWithImpl<$Res, _$CourseProgressImpl>
    implements _$$CourseProgressImplCopyWith<$Res> {
  __$$CourseProgressImplCopyWithImpl(
      _$CourseProgressImpl _value, $Res Function(_$CourseProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? courseId = null,
    Object? courseTitle = null,
    Object? completionPercentage = null,
    Object? totalLessons = null,
    Object? completedLessons = null,
    Object? lessonsInProgress = null,
    Object? totalHomework = null,
    Object? completedHomework = null,
    Object? pendingHomework = null,
    Object? totalTimeSpentSeconds = null,
    Object? lastAccessedAt = freezed,
    Object? currentLessonId = freezed,
    Object? nextLessonId = freezed,
    Object? achievements = null,
    Object? streak = null,
    Object? enrolledAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$CourseProgressImpl(
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
      courseTitle: null == courseTitle
          ? _value.courseTitle
          : courseTitle // ignore: cast_nullable_to_non_nullable
              as String,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      totalLessons: null == totalLessons
          ? _value.totalLessons
          : totalLessons // ignore: cast_nullable_to_non_nullable
              as int,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as int,
      lessonsInProgress: null == lessonsInProgress
          ? _value.lessonsInProgress
          : lessonsInProgress // ignore: cast_nullable_to_non_nullable
              as int,
      totalHomework: null == totalHomework
          ? _value.totalHomework
          : totalHomework // ignore: cast_nullable_to_non_nullable
              as int,
      completedHomework: null == completedHomework
          ? _value.completedHomework
          : completedHomework // ignore: cast_nullable_to_non_nullable
              as int,
      pendingHomework: null == pendingHomework
          ? _value.pendingHomework
          : pendingHomework // ignore: cast_nullable_to_non_nullable
              as int,
      totalTimeSpentSeconds: null == totalTimeSpentSeconds
          ? _value.totalTimeSpentSeconds
          : totalTimeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      lastAccessedAt: freezed == lastAccessedAt
          ? _value.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentLessonId: freezed == currentLessonId
          ? _value.currentLessonId
          : currentLessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      nextLessonId: freezed == nextLessonId
          ? _value.nextLessonId
          : nextLessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      enrolledAt: freezed == enrolledAt
          ? _value.enrolledAt
          : enrolledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _$CourseProgressImpl extends _CourseProgress {
  const _$CourseProgressImpl(
      {required this.id,
      required this.userId,
      required this.courseId,
      required this.courseTitle,
      this.completionPercentage = 0.0,
      this.totalLessons = 0,
      this.completedLessons = 0,
      this.lessonsInProgress = 0,
      this.totalHomework = 0,
      this.completedHomework = 0,
      this.pendingHomework = 0,
      this.totalTimeSpentSeconds = 0,
      this.lastAccessedAt,
      this.currentLessonId,
      this.nextLessonId,
      final List<String> achievements = const [],
      this.streak = 0,
      this.enrolledAt,
      this.startedAt,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt})
      : _achievements = achievements,
        super._();

  factory _$CourseProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String courseId;
  @override
  final String courseTitle;
// Общий прогресс
  @override
  @JsonKey()
  final double completionPercentage;
// 0.0 - 1.0
  @override
  @JsonKey()
  final int totalLessons;
  @override
  @JsonKey()
  final int completedLessons;
  @override
  @JsonKey()
  final int lessonsInProgress;
// Домашние задания
  @override
  @JsonKey()
  final int totalHomework;
  @override
  @JsonKey()
  final int completedHomework;
  @override
  @JsonKey()
  final int pendingHomework;
// Время обучения
  @override
  @JsonKey()
  final int totalTimeSpentSeconds;
  @override
  final DateTime? lastAccessedAt;
  @override
  final String? currentLessonId;
// Текущий урок
  @override
  final String? nextLessonId;
// Следующий урок для изучения
// Достижения
  final List<String> _achievements;
// Следующий урок для изучения
// Достижения
  @override
  @JsonKey()
  List<String> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

// ID достижений
  @override
  @JsonKey()
  final int streak;
// Дни подряд обучения
// Метаданные
  @override
  final DateTime? enrolledAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CourseProgress(id: $id, userId: $userId, courseId: $courseId, courseTitle: $courseTitle, completionPercentage: $completionPercentage, totalLessons: $totalLessons, completedLessons: $completedLessons, lessonsInProgress: $lessonsInProgress, totalHomework: $totalHomework, completedHomework: $completedHomework, pendingHomework: $pendingHomework, totalTimeSpentSeconds: $totalTimeSpentSeconds, lastAccessedAt: $lastAccessedAt, currentLessonId: $currentLessonId, nextLessonId: $nextLessonId, achievements: $achievements, streak: $streak, enrolledAt: $enrolledAt, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.courseTitle, courseTitle) ||
                other.courseTitle == courseTitle) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.completedLessons, completedLessons) ||
                other.completedLessons == completedLessons) &&
            (identical(other.lessonsInProgress, lessonsInProgress) ||
                other.lessonsInProgress == lessonsInProgress) &&
            (identical(other.totalHomework, totalHomework) ||
                other.totalHomework == totalHomework) &&
            (identical(other.completedHomework, completedHomework) ||
                other.completedHomework == completedHomework) &&
            (identical(other.pendingHomework, pendingHomework) ||
                other.pendingHomework == pendingHomework) &&
            (identical(other.totalTimeSpentSeconds, totalTimeSpentSeconds) ||
                other.totalTimeSpentSeconds == totalTimeSpentSeconds) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt) &&
            (identical(other.currentLessonId, currentLessonId) ||
                other.currentLessonId == currentLessonId) &&
            (identical(other.nextLessonId, nextLessonId) ||
                other.nextLessonId == nextLessonId) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.enrolledAt, enrolledAt) ||
                other.enrolledAt == enrolledAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        courseId,
        courseTitle,
        completionPercentage,
        totalLessons,
        completedLessons,
        lessonsInProgress,
        totalHomework,
        completedHomework,
        pendingHomework,
        totalTimeSpentSeconds,
        lastAccessedAt,
        currentLessonId,
        nextLessonId,
        const DeepCollectionEquality().hash(_achievements),
        streak,
        enrolledAt,
        startedAt,
        completedAt,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseProgressImplCopyWith<_$CourseProgressImpl> get copyWith =>
      __$$CourseProgressImplCopyWithImpl<_$CourseProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseProgressImplToJson(
      this,
    );
  }
}

abstract class _CourseProgress extends CourseProgress {
  const factory _CourseProgress(
      {required final String id,
      required final String userId,
      required final String courseId,
      required final String courseTitle,
      final double completionPercentage,
      final int totalLessons,
      final int completedLessons,
      final int lessonsInProgress,
      final int totalHomework,
      final int completedHomework,
      final int pendingHomework,
      final int totalTimeSpentSeconds,
      final DateTime? lastAccessedAt,
      final String? currentLessonId,
      final String? nextLessonId,
      final List<String> achievements,
      final int streak,
      final DateTime? enrolledAt,
      final DateTime? startedAt,
      final DateTime? completedAt,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$CourseProgressImpl;
  const _CourseProgress._() : super._();

  factory _CourseProgress.fromJson(Map<String, dynamic> json) =
      _$CourseProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get courseId;
  @override
  String get courseTitle; // Общий прогресс
  @override
  double get completionPercentage; // 0.0 - 1.0
  @override
  int get totalLessons;
  @override
  int get completedLessons;
  @override
  int get lessonsInProgress; // Домашние задания
  @override
  int get totalHomework;
  @override
  int get completedHomework;
  @override
  int get pendingHomework; // Время обучения
  @override
  int get totalTimeSpentSeconds;
  @override
  DateTime? get lastAccessedAt;
  @override
  String? get currentLessonId; // Текущий урок
  @override
  String? get nextLessonId; // Следующий урок для изучения
// Достижения
  @override
  List<String> get achievements; // ID достижений
  @override
  int get streak; // Дни подряд обучения
// Метаданные
  @override
  DateTime? get enrolledAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CourseProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseProgressImplCopyWith<_$CourseProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
