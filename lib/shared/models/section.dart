import 'package:freezed_annotation/freezed_annotation.dart';

part 'section.freezed.dart';
part 'section.g.dart';

@freezed
class Section with _$Section {
  const factory Section({
    required String id,
    required String courseId,
    required String title,
    String? description,
    @Default(0) int order,
    @Default(true) bool isActive,
    @Default([]) List<String> lessonIds, // ID уроков в этом разделе
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Section;

  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);
} 