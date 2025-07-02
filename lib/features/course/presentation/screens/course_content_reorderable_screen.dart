import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/section_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_edit_screen.dart';

class CourseContentReorderableScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseContentReorderableScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseContentReorderableScreen> createState() => _CourseContentReorderableScreenState();
}

class _CourseContentReorderableScreenState extends ConsumerState<CourseContentReorderableScreen> {
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(sectionProvider(widget.courseId));
    final courseLessons = ref.watch(courseLessonsProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Содержимое курса'),
        backgroundColor: Color(0xFF4A90B8), // primaryBlue
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isReordering = !_isReordering;
              });
            },
            icon: Icon(_isReordering ? Icons.check : Icons.sort),
            tooltip: _isReordering ? 'Завершить сортировку' : 'Сортировать',
          ),
          if (!_isReordering)
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
    final directLessons = courseLessons.where((lesson) => lesson.sectionId == null).toList();

    if (_isReordering) {
      return _buildReorderableContent(context, ref, sections, directLessons, courseLessons);
    }

    return _buildNormalContent(context, ref, sections, directLessons, courseLessons);
  }

  Widget _buildNormalContent(BuildContext context, WidgetRef ref, List<Section> sections, List<Lesson> directLessons, List<Lesson> courseLessons) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Статистика курса
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статистика курса',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildReorderableContent(BuildContext context, WidgetRef ref, List<Section> sections, List<Lesson> directLessons, List<Lesson> courseLessons) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.sort, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Режим сортировки: перетащите элементы для изменения порядка',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Уроки без раздела
          if (directLessons.isNotEmpty) ...[
            const Text(
              'Уроки курса',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) => _reorderDirectLessons(ref, directLessons, oldIndex, newIndex),
              children: directLessons.map((lesson) => 
                _buildDraggableLessonCard(context, ref, lesson, key: ValueKey(lesson.id))
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Разделы
          if (sections.isNotEmpty) ...[
            const Text(
              'Разделы',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) => _reorderSections(ref, sections, oldIndex, newIndex),
              children: sections.map((section) {
                final sectionLessons = courseLessons.where((lesson) => lesson.sectionId == section.id).toList();
                return _buildDraggableSectionCard(context, ref, section, sectionLessons, key: ValueKey(section.id));
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDraggableLessonCard(BuildContext context, WidgetRef ref, Lesson lesson, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.drag_handle),
          title: Text(lesson.title),
          subtitle: Text(lesson.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditLessonDialog(context, ref, lesson),
                icon: const Icon(Icons.edit),
                tooltip: 'Редактировать',
              ),
              IconButton(
                onPressed: () => _showDeleteLessonDialog(context, ref, lesson),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Удалить',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableSectionCard(BuildContext context, WidgetRef ref, Section section, List<Lesson> sectionLessons, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ExpansionTile(
          leading: const Icon(Icons.drag_handle),
          title: Text(
            section.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${sectionLessons.length} урок(ов)'),
          children: [
            if (sectionLessons.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) => _reorderSectionLessons(ref, section, sectionLessons, oldIndex, newIndex),
                  children: sectionLessons.map((lesson) => 
                    _buildDraggableLessonCard(context, ref, lesson, key: ValueKey('${section.id}_${lesson.id}'))
                  ).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreateLessonDialog(context, ref, section.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить урок'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showEditSectionDialog(context, ref, section),
                    icon: const Icon(Icons.edit),
                    label: const Text('Редактировать'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteSectionDialog(context, ref, section),
                    icon: const Icon(Icons.delete),
                    label: const Text('Удалить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderDirectLessons(WidgetRef ref, List<Lesson> lessons, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final reorderedLessons = List<Lesson>.from(lessons);
    final lesson = reorderedLessons.removeAt(oldIndex);
    reorderedLessons.insert(newIndex, lesson);
    
    // Обновляем порядок
    final lessonIds = reorderedLessons.map((l) => l.id).toList();
    ref.read(courseLessonsProvider(widget.courseId).notifier).reorderLessons(lessonIds);
  }

  void _reorderSections(WidgetRef ref, List<Section> sections, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final reorderedSections = List<Section>.from(sections);
    final section = reorderedSections.removeAt(oldIndex);
    reorderedSections.insert(newIndex, section);
    
    ref.read(sectionProvider(widget.courseId).notifier).reorderSections(reorderedSections);
  }

  void _reorderSectionLessons(WidgetRef ref, Section section, List<Lesson> lessons, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final reorderedLessons = List<Lesson>.from(lessons);
    final lesson = reorderedLessons.removeAt(oldIndex);
    reorderedLessons.insert(newIndex, lesson);
    
    // Обновляем порядок уроков в разделе
    final lessonIds = reorderedLessons.map((l) => l.id).toList();
    ref.read(courseLessonsProvider(widget.courseId).notifier).reorderLessons(lessonIds);
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
          // Открываем урок для просмотра
          context.go('/admin/course/${widget.courseId}/lesson/${lesson.id}/edit');
        },
      ),
    );
  }

  // Все диалоги такие же как в оригинальном файле
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
                  await ref.read(sectionProvider(widget.courseId).notifier).createSection(
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
    final homeworkTaskController = TextEditingController();
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
                controller: homeworkTaskController,
                decoration: const InputDecoration(
                  labelText: 'Домашнее задание (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                  await ref.read(courseLessonsProvider(widget.courseId).notifier).createLesson(
                    courseId: widget.courseId,
                    sectionId: sectionId,
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    content: contentController.text.trim().isEmpty 
                        ? null 
                        : contentController.text.trim(),
                    videoUrl: videoUrlController.text.trim().isEmpty 
                        ? null 
                        : videoUrlController.text.trim(),
                    homeworkTask: homeworkTaskController.text.trim().isEmpty 
                        ? null 
                        : homeworkTaskController.text.trim(),
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
                  await ref.read(sectionProvider(widget.courseId).notifier).updateSection(
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
                await ref.read(sectionProvider(widget.courseId).notifier).deleteSection(section.id);
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
    context.go('/admin/course/${widget.courseId}/lesson/${lesson.id}/edit');
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
                await ref.read(courseLessonsProvider(widget.courseId).notifier).deleteLesson(lesson.id);
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