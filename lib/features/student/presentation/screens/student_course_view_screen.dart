import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/providers/section_provider.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_view_screen.dart';
import 'package:miniapp/core/utils/string_utils.dart';

class StudentCourseViewScreen extends ConsumerWidget {
  final Course course;

  const StudentCourseViewScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(sectionProvider(course.id));
    final courseLessons = ref.watch(courseLessonsProvider(course.id));

    return sections.when(
      data: (sectionList) => courseLessons.when(
        data: (lessonList) => _buildContent(context, ref, sectionList, lessonList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки уроков: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки разделов: $error')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Section> sections, List<Lesson> courseLessons) {
    // Уроки без раздела (прямо в курсе)
    final directLessons = courseLessons.where((lesson) => lesson.sectionId == null).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Информация о курсе
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (course.imageUrl != null) ...[
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(course.imageUrl!),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                    child: course.imageUrl == null 
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.withOpacity(0.8),
                                  Colors.purple.withOpacity(0.6),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.school,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip('Разделы', sections.length.toString(), Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('Уроки', courseLessons.length.toString(), Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // Прямые уроки (не в разделах)
        if (directLessons.isNotEmpty) ...[
          const Text(
            'Уроки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...directLessons.map((lesson) => _buildLessonCard(context, ref, lesson)),
          const SizedBox(height: 16),
        ] else if (courseLessons.isNotEmpty) ...[
          // Если есть уроки, но все они в разделах, показываем их все
          const Text(
            'Уроки курса',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...courseLessons.map((lesson) => _buildLessonCard(context, ref, lesson)),
          const SizedBox(height: 16),
        ],

        // Разделы с уроками
        if (sections.isNotEmpty) ...[
          const Text(
            'Разделы курса',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sections.map((section) {
            final sectionLessons = courseLessons.where((lesson) => lesson.sectionId == section.id).toList();
            return _buildSectionCard(context, ref, section, sectionLessons);
          }),
        ],

        // Если нет ни уроков, ни разделов
        if (directLessons.isEmpty && sections.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Курс пока пустой',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Уроки появятся здесь, когда преподаватель их добавит',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, WidgetRef ref, Section section, List<Lesson> lessons) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(RussianPlurals.formatLessons(lessons.length)),
        children: lessons.map((lesson) => _buildLessonCard(context, ref, lesson, isInSection: true)).toList(),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, WidgetRef ref, Lesson lesson, {bool isInSection = false}) {
    return Card(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isInSection ? 16 : 0,
        right: isInSection ? 16 : 0,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90B8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.play_circle_outline,
            color: Color(0xFF4A90B8),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: lesson.description?.isNotEmpty == true 
            ? Text(
                lesson.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Переходим к уроку в студенческом разделе
          context.go('/student/course/${course.id}/lesson/${lesson.id}');
        },
      ),
    );
  }
} 