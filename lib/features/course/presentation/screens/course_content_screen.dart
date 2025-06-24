import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/section_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_edit_screen.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_view_screen.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_reorderable_screen.dart';

class CourseContentScreen extends ConsumerWidget {
  final Course course;

  const CourseContentScreen({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(sectionProvider(course.id));
    final courseLessons = ref.watch(courseLessonsProvider(course.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Содержимое: ${course.title}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CourseContentReorderableScreen(course: course),
                ),
              );
            },
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировать',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_section':
                  _showCreateSectionDialog(context, ref);
                  break;
                case 'add_lesson':
                  _showCreateLessonDialog(context, ref, null);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_section',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined),
                    SizedBox(width: 8),
                    Text('Добавить раздел'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_lesson',
                child: Row(
                  children: [
                    Icon(Icons.article_outlined),
                    SizedBox(width: 8),
                    Text('Добавить урок'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: sections.when(
        data: (sectionList) => courseLessons.when(
          data: (lessonList) => _buildContent(context, ref, sectionList, lessonList),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Ошибка загрузки уроков: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки разделов: $error')),
      ),
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
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: TextStyle(color: Colors.grey[600]),
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

        // Уроки без раздела
        if (directLessons.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.article, color: Colors.deepPurple),
              const SizedBox(width: 8),
              const Text(
                'Уроки курса',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showCreateLessonDialog(context, ref, null),
                icon: const Icon(Icons.add),
                tooltip: 'Добавить урок',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...directLessons.map((lesson) => _buildLessonCard(context, ref, lesson)),
          const SizedBox(height: 24),
        ],

        // Разделы
        if (sections.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.folder, color: Colors.deepPurple),
              const SizedBox(width: 8),
              const Text(
                'Разделы',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showCreateSectionDialog(context, ref),
                icon: const Icon(Icons.add),
                tooltip: 'Добавить раздел',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...sections.map((section) => _buildSectionCard(context, ref, section, courseLessons)),
        ],

        // Кнопки для добавления контента
        if (sections.isEmpty && directLessons.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Курс пока пуст',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте разделы и уроки для структурированного обучения',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Если ширина меньше 400px, располагаем кнопки вертикально
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showCreateSectionDialog(context, ref),
                                icon: const Icon(Icons.folder_outlined),
                                label: const Text('Добавить раздел'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showCreateLessonDialog(context, ref, null),
                                icon: const Icon(Icons.article_outlined),
                                label: const Text('Добавить урок'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // На широких экранах кнопки в ряд
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showCreateSectionDialog(context, ref),
                                icon: const Icon(Icons.folder_outlined),
                                label: const Text('Добавить раздел'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showCreateLessonDialog(context, ref, null),
                                icon: const Icon(Icons.article_outlined),
                                label: const Text('Добавить урок'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildSectionCard(BuildContext context, WidgetRef ref, Section section, List<Lesson> allLessons) {
    final sectionLessons = allLessons.where((lesson) => lesson.sectionId == section.id).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.folder, color: Colors.deepPurple),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${sectionLessons.length} урок(ов)'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'add_lesson':
                _showCreateLessonDialog(context, ref, section.id);
                break;
              case 'edit':
                _showEditSectionDialog(context, ref, section);
                break;
              case 'delete':
                _showDeleteSectionDialog(context, ref, section);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add_lesson',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Добавить урок'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        children: sectionLessons.map((lesson) => Padding(
          padding: const EdgeInsets.only(left: 32),
          child: _buildLessonCard(context, ref, lesson),
        )).toList(),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, WidgetRef ref, Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: const Icon(Icons.play_circle_outline, color: Colors.green),
        title: Text(lesson.title),
        subtitle: Text(lesson.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lesson.durationMinutes > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${lesson.durationMinutes} мин',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditLessonDialog(context, ref, lesson);
                    break;
                  case 'delete':
                    _showDeleteLessonDialog(context, ref, lesson);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Удалить', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LessonViewScreen(lesson: lesson),
            ),
          );
        },
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
                  await ref.read(sectionProvider(course.id).notifier).createSection(
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
                  await ref.read(courseLessonsProvider(course.id).notifier).createLesson(
                    courseId: course.id,
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
                  await ref.read(sectionProvider(course.id).notifier).updateSection(
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
                await ref.read(sectionProvider(course.id).notifier).deleteSection(section.id);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonEditScreen(lesson: lesson),
      ),
    );
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
                await ref.read(courseLessonsProvider(course.id).notifier).deleteLesson(lesson.id);
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