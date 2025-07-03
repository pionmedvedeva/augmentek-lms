import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/section_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_edit_screen.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_view_screen.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_reorderable_screen.dart';

class CourseContentScreen extends ConsumerWidget {
  final String courseId;

  const CourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionProvider(courseId));
    final lessonsAsync = ref.watch(courseLessonsProvider(courseId));

    return sectionsAsync.when(
      data: (sections) => lessonsAsync.when(
        data: (lessons) => _buildContent(context, ref, sections, lessons),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки уроков: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка загрузки разделов: $error')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Section> sections, List<Lesson> lessons) {
    final directLessons = lessons.where((l) => l.sectionId == null).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Чипы
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              _buildStatChip('Разделы', sections.length.toString(), Colors.blue),
              const SizedBox(width: 8),
              _buildStatChip('Уроки', lessons.length.toString(), Colors.green),
            ],
          ),
        ),
        // Уроки без раздела (drag-and-drop)
        if (directLessons.isNotEmpty)
          _buildReorderableLessonList(context, ref, directLessons, null),
        if (directLessons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCreateLessonDialog(context, ref, null),
                icon: const Icon(Icons.add),
                label: const Text('Добавить урок'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        // Разделы (drag-and-drop)
        _buildReorderableSectionList(context, ref, sections, lessons),
        // Кнопка добавить раздел
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCreateSectionDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Добавить раздел'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableSectionList(BuildContext context, WidgetRef ref, List<Section> sections, List<Lesson> lessons) {
    final sortedSections = List<Section>.from(sections)..sort((a, b) => a.order.compareTo(b.order));
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedSections.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final updated = List<Section>.from(sortedSections);
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        await ref.read(sectionProvider(courseId).notifier).reorderSections(updated);
        ref.invalidate(sectionProvider(courseId));
      },
      itemBuilder: (context, i) => _buildSectionTile(context, ref, sortedSections[i], lessons, i, Key('section_${sortedSections[i].id}')),
    );
  }

  Widget _buildSectionTile(BuildContext context, WidgetRef ref, Section section, List<Lesson> allLessons, int index, Key key) {
    final sectionLessons = List<Lesson>.from(allLessons.where((l) => l.sectionId == section.id))
      ..sort((a, b) => a.order.compareTo(b.order));
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Редактировать раздел',
                  onPressed: () => _showEditSectionDialog(context, ref, section),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Удалить раздел',
                  onPressed: () => _showDeleteSectionDialog(context, ref, section),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildReorderableLessonList(context, ref, sectionLessons, section.id),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateLessonDialog(context, ref, section.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить урок'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableLessonList(BuildContext context, WidgetRef ref, List<Lesson> lessons, String? sectionId) {
    final sortedLessons = List<Lesson>.from(lessons)..sort((a, b) => a.order.compareTo(b.order));
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedLessons.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) async {
        if (newIndex > oldIndex) newIndex--;
        final updated = List<Lesson>.from(sortedLessons);
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        if (sectionId == null) {
          await ref.read(courseLessonsProvider(courseId).notifier).reorderLessons(updated.map((l) => l.id).toList());
          ref.invalidate(courseLessonsProvider(courseId));
          // На всякий случай инвалидируем все sectionLessonsProvider для этого курса
          for (final lesson in updated) {
            if (lesson.sectionId != null) {
              ref.invalidate(sectionLessonsProvider(lesson.sectionId!));
            }
          }
        } else {
          await ref.read(sectionLessonsProvider(sectionId).notifier).reorderLessons(updated.map((l) => l.id).toList());
          ref.invalidate(sectionLessonsProvider(sectionId));
          ref.invalidate(courseLessonsProvider(courseId));
        }
      },
      itemBuilder: (context, i) => _buildLessonTile(context, ref, sortedLessons[i], i, Key('lesson_${sortedLessons[i].id}')),
    );
  }

  Widget _buildLessonTile(BuildContext context, WidgetRef ref, Lesson lesson, int index, Key key) {
    return ListTile(
      key: key,
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_indicator, color: Colors.grey),
      ),
      title: Text(lesson.title),
      subtitle: Text(lesson.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Редактировать урок',
            onPressed: () => _showEditLessonDialog(context, ref, lesson),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Удалить урок',
            onPressed: () => _showDeleteLessonDialog(context, ref, lesson),
          ),
        ],
      ),
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      onTap: () {
        context.go('/course/$courseId/lesson/${lesson.id}');
      },
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

  void _showCreateSectionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать раздел'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название раздела',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                try {
                  await ref.read(sectionProvider(courseId).notifier).createSection(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Раздел создан успешно')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка создания раздела: $error')),
                    );
                  }
                }
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showCreateLessonDialog(BuildContext context, WidgetRef ref, String? sectionId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final contentController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sectionId == null ? 'Создать урок курса' : 'Создать урок раздела'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название урока',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Краткое описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Содержание урока (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Ссылка на видео (необязательно)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Длительность в минутах',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty && 
                  descriptionController.text.trim().isNotEmpty) {
                try {
                  await ref.read(courseLessonsProvider(courseId).notifier).createLesson(
                    courseId: courseId,
                    sectionId: sectionId,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    content: contentController.text.trim().isEmpty 
                        ? null 
                        : contentController.text.trim(),
                    videoUrl: videoUrlController.text.trim().isEmpty 
                        ? null 
                        : videoUrlController.text.trim(),
                    durationMinutes: int.tryParse(durationController.text.trim()) ?? 0,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Урок создан успешно')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка создания урока: $error')),
                    );
                  }
                }
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showEditSectionDialog(BuildContext context, WidgetRef ref, Section section) {
    final titleController = TextEditingController(text: section.title);
    final descriptionController = TextEditingController(text: section.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать раздел'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Название раздела',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                try {
                  await ref.read(sectionProvider(courseId).notifier).updateSection(
                    section.id,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty 
                        ? null 
                        : descriptionController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Раздел обновлен')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка обновления: $error')),
                    );
                  }
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSectionDialog(BuildContext context, WidgetRef ref, Section section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить раздел?'),
        content: Text('Вы уверены что хотите удалить раздел "${section.title}"?\n\nВсе уроки в этом разделе также будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(sectionProvider(courseId).notifier).deleteSection(section.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Раздел удален')),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $error')),
                  );
                }
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditLessonDialog(BuildContext context, WidgetRef ref, Lesson lesson) {
    context.go('/admin/course/$courseId/lesson/${lesson.id}/edit');
  }

  void _showDeleteLessonDialog(BuildContext context, WidgetRef ref, Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить урок?'),
        content: Text('Вы уверены что хотите удалить урок "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ref.read(courseLessonsProvider(courseId).notifier).deleteLesson(lesson.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Урок удален')),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: $error')),
                  );
                }
              }
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 