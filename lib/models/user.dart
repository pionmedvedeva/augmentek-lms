import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String username,
    required bool isAdmin,
    @Default([]) List<String> enrolledCourses,
    @Default({}) Map<String, double> courseProgress,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
} 