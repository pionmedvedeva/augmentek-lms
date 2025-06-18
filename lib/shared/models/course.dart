import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class Course with _$Course {
  const factory Course({
    required String id,
    required String title,
    required String description,
    required String categoryId,
    required String instructor,
    @Default(0) int duration,
    @Default(0) int likes,
    @Default(0) double price,
    String? imageUrl,
    @Default([]) List<String> lessonIds,
    @Default(false) bool isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
} 