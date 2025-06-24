// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'homework_submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeworkSubmission _$HomeworkSubmissionFromJson(Map<String, dynamic> json) {
  return _HomeworkSubmission.fromJson(json);
}

/// @nodoc
mixin _$HomeworkSubmission {
  String get id => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  String get courseId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  HomeworkStatus get status => throw _privateConstructorUsedError;
  String? get adminComment =>
      throw _privateConstructorUsedError; // Комментарий от преподавателя
  String? get reviewedBy =>
      throw _privateConstructorUsedError; // ID админа который проверил
  DateTime get submittedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;

  /// Serializes this HomeworkSubmission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeworkSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeworkSubmissionCopyWith<HomeworkSubmission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeworkSubmissionCopyWith<$Res> {
  factory $HomeworkSubmissionCopyWith(
          HomeworkSubmission value, $Res Function(HomeworkSubmission) then) =
      _$HomeworkSubmissionCopyWithImpl<$Res, HomeworkSubmission>;
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String courseId,
      String studentId,
      String studentName,
      String answer,
      HomeworkStatus status,
      String? adminComment,
      String? reviewedBy,
      DateTime submittedAt,
      DateTime? reviewedAt});
}

/// @nodoc
class _$HomeworkSubmissionCopyWithImpl<$Res, $Val extends HomeworkSubmission>
    implements $HomeworkSubmissionCopyWith<$Res> {
  _$HomeworkSubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeworkSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? courseId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? answer = null,
    Object? status = null,
    Object? adminComment = freezed,
    Object? reviewedBy = freezed,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HomeworkStatus,
      adminComment: freezed == adminComment
          ? _value.adminComment
          : adminComment // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeworkSubmissionImplCopyWith<$Res>
    implements $HomeworkSubmissionCopyWith<$Res> {
  factory _$$HomeworkSubmissionImplCopyWith(_$HomeworkSubmissionImpl value,
          $Res Function(_$HomeworkSubmissionImpl) then) =
      __$$HomeworkSubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String courseId,
      String studentId,
      String studentName,
      String answer,
      HomeworkStatus status,
      String? adminComment,
      String? reviewedBy,
      DateTime submittedAt,
      DateTime? reviewedAt});
}

/// @nodoc
class __$$HomeworkSubmissionImplCopyWithImpl<$Res>
    extends _$HomeworkSubmissionCopyWithImpl<$Res, _$HomeworkSubmissionImpl>
    implements _$$HomeworkSubmissionImplCopyWith<$Res> {
  __$$HomeworkSubmissionImplCopyWithImpl(_$HomeworkSubmissionImpl _value,
      $Res Function(_$HomeworkSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeworkSubmission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? courseId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? answer = null,
    Object? status = null,
    Object? adminComment = freezed,
    Object? reviewedBy = freezed,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
  }) {
    return _then(_$HomeworkSubmissionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _value.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HomeworkStatus,
      adminComment: freezed == adminComment
          ? _value.adminComment
          : adminComment // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeworkSubmissionImpl implements _HomeworkSubmission {
  const _$HomeworkSubmissionImpl(
      {required this.id,
      required this.lessonId,
      required this.courseId,
      required this.studentId,
      required this.studentName,
      required this.answer,
      required this.status,
      this.adminComment,
      this.reviewedBy,
      required this.submittedAt,
      this.reviewedAt});

  factory _$HomeworkSubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeworkSubmissionImplFromJson(json);

  @override
  final String id;
  @override
  final String lessonId;
  @override
  final String courseId;
  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final String answer;
  @override
  final HomeworkStatus status;
  @override
  final String? adminComment;
// Комментарий от преподавателя
  @override
  final String? reviewedBy;
// ID админа который проверил
  @override
  final DateTime submittedAt;
  @override
  final DateTime? reviewedAt;

  @override
  String toString() {
    return 'HomeworkSubmission(id: $id, lessonId: $lessonId, courseId: $courseId, studentId: $studentId, studentName: $studentName, answer: $answer, status: $status, adminComment: $adminComment, reviewedBy: $reviewedBy, submittedAt: $submittedAt, reviewedAt: $reviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeworkSubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.adminComment, adminComment) ||
                other.adminComment == adminComment) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      lessonId,
      courseId,
      studentId,
      studentName,
      answer,
      status,
      adminComment,
      reviewedBy,
      submittedAt,
      reviewedAt);

  /// Create a copy of HomeworkSubmission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeworkSubmissionImplCopyWith<_$HomeworkSubmissionImpl> get copyWith =>
      __$$HomeworkSubmissionImplCopyWithImpl<_$HomeworkSubmissionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeworkSubmissionImplToJson(
      this,
    );
  }
}

abstract class _HomeworkSubmission implements HomeworkSubmission {
  const factory _HomeworkSubmission(
      {required final String id,
      required final String lessonId,
      required final String courseId,
      required final String studentId,
      required final String studentName,
      required final String answer,
      required final HomeworkStatus status,
      final String? adminComment,
      final String? reviewedBy,
      required final DateTime submittedAt,
      final DateTime? reviewedAt}) = _$HomeworkSubmissionImpl;

  factory _HomeworkSubmission.fromJson(Map<String, dynamic> json) =
      _$HomeworkSubmissionImpl.fromJson;

  @override
  String get id;
  @override
  String get lessonId;
  @override
  String get courseId;
  @override
  String get studentId;
  @override
  String get studentName;
  @override
  String get answer;
  @override
  HomeworkStatus get status;
  @override
  String? get adminComment; // Комментарий от преподавателя
  @override
  String? get reviewedBy; // ID админа который проверил
  @override
  DateTime get submittedAt;
  @override
  DateTime? get reviewedAt;

  /// Create a copy of HomeworkSubmission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeworkSubmissionImplCopyWith<_$HomeworkSubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
