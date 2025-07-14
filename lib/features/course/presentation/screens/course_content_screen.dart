import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/section.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/section_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_edit_screen.dart';
import 'package:miniapp/features/course/presentation/screens/lesson_view_screen.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_reorderable_screen.dart';
import 'package:miniapp/shared/widgets/image_upload_widget.dart';
import 'package:miniapp/services/storage_service.dart';
import 'dart:typed_data';

final editingSectionIdProvider = StateProvider<String?>((ref) => null);
final editingLessonIdProvider = StateProvider<String?>((ref) => null);

enum EditStatus { idle, loading, success, error }
final sectionEditStatusProvider = StateProvider<Map<String, EditStatus>>((ref) => {});
final lessonEditStatusProvider = StateProvider<Map<String, EditStatus>>((ref) => {});

// Провайдеры для редактирования метаданных курса
final courseMetadataEditingProvider = StateProvider<bool>((ref) => false);
final courseMetadataChangedProvider = StateProvider<bool>((ref) => false);
final courseImageUploadProvider = StateProvider<Uint8List?>((ref) => null);
final courseImageFileNameProvider = StateProvider<String?>((ref) => null);

class CourseContentScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseContentScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends ConsumerState<CourseContentScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  
  bool get _isNewCourse => widget.courseId == 'new';
  Course? _currentCourse;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    
    if (_isNewCourse) {
      // Для нового курса инициализируем пустые поля
      _titleController.text = '';
      _descriptionController.text = '';
      _tagsController.text = '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNewCourse) {
      // Для нового курса показываем только секцию метаданных
      return Scaffold(
        appBar: AppBar(
          title: const Text('Создание курса'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: _createNewCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Создать'),
              ),
            ),
          ],
        ),
        body: _buildMetadataSection(context, ref, null),
      );
    } else {
      // Для существующего курса загружаем данные
      final coursesAsync = ref.watch(courseProvider);
      final sectionsAsync = ref.watch(sectionProvider(widget.courseId));
      final lessonsAsync = ref.watch(courseLessonsProvider(widget.courseId));

      return coursesAsync.when(
        data: (courses) {
          _currentCourse = courses.firstWhere(
            (c) => c.id == widget.courseId,
            orElse: () => throw Exception('Курс не найден'),
          );
          
          // Обновляем контроллеры при первой загрузке
          if (_titleController.text.isEmpty) {
            _titleController.text = _currentCourse!.title;
            _descriptionController.text = _currentCourse!.description;
            _tagsController.text = _currentCourse!.tags.join(', ');
          }

          return sectionsAsync.when(
            data: (sections) => lessonsAsync.when(
              data: (lessons) => _buildFullContent(context, ref, _currentCourse!, sections, lessons),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка загрузки уроков: $error')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка загрузки разделов: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка загрузки курса: $error')),
      );
    }
  }

  Future<void> _createNewCourse() async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название и описание обязательны')),
      );
      return;
    }

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      String? imageUrl;
      final imageBytes = ref.read(courseImageUploadProvider);
      final imageFileName = ref.read(courseImageFileNameProvider);

      // Загружаем изображение если выбрано
      if (imageBytes != null && imageFileName != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await ref.read(storageServiceProvider).uploadCourseImage(
          courseId: tempId,
          imageBytes: imageBytes,
          fileName: imageFileName,
        );
      }

      final newCourse = Course(
        id: '', // Будет установлен в CourseProvider
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        imageUrl: imageUrl,
        isActive: true,
        enrolledCount: 0,
        createdBy: '', // TODO: установить текущего пользователя
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final courseId = await ref.read(courseProvider.notifier).createCourse(newCourse);
      
      if (mounted) {
        context.go('/admin/course/$courseId/edit');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Курс создан успешно')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания курса: $error')),
        );
      }
    }
  }

  Future<void> _saveCourseMetadata() async {
    if (_currentCourse == null) return;

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      String? imageUrl = _currentCourse!.imageUrl;
      final imageBytes = ref.read(courseImageUploadProvider);
      final imageFileName = ref.read(courseImageFileNameProvider);

      // Загружаем новое изображение если выбрано
      if (imageBytes != null && imageFileName != null) {
        imageUrl = await ref.read(storageServiceProvider).uploadCourseImage(
          courseId: _currentCourse!.id,
          imageBytes: imageBytes,
          fileName: imageFileName,
        );
      }

      final updatedCourse = _currentCourse!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await ref.read(courseProvider.notifier).updateCourse(updatedCourse);
      
      // Сбрасываем флаги изменения
      ref.read(courseMetadataChangedProvider.notifier).state = false;
      ref.read(courseImageUploadProvider.notifier).state = null;
      ref.read(courseImageFileNameProvider.notifier).state = null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Курс обновлен успешно')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления курса: $error')),
        );
      }
    }
  }

  Widget _buildFullContent(BuildContext context, WidgetRef ref, Course course, List<Section> sections, List<Lesson> lessons) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование: ${course.title}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _saveCourseMetadata,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
      body: _buildContent(context, ref, course, sections, lessons),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Course? course, List<Section> sections, List<Lesson> lessons) {
    final directLessons = lessons.where((l) => l.sectionId == null).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Секция метаданных курса (только для существующих курсов)
        if (course != null) _buildMetadataSection(context, ref, course),
        
        // Разделитель
        if (course != null) const Divider(thickness: 2, height: 32),
        
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
                                  onPressed: () => _showCreateLessonDialog(context, ref, _currentCourse?.id ?? widget.courseId, null),
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
              onPressed: () => _showCreateSectionDialog(context, ref, _currentCourse?.id ?? widget.courseId),
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

  Widget _buildMetadataSection(BuildContext context, WidgetRef ref, Course? course) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Настройки курса',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Загрузка изображения
          ImageUploadWidget(
            initialImageUrl: course?.imageUrl,
            onImageSelected: (bytes, fileName) {
              ref.read(courseImageUploadProvider.notifier).state = bytes;
              ref.read(courseImageFileNameProvider.notifier).state = fileName;
              ref.read(courseMetadataChangedProvider.notifier).state = true;
            },
            onImageRemoved: () {
              ref.read(courseImageUploadProvider.notifier).state = null;
              ref.read(courseImageFileNameProvider.notifier).state = null;
              ref.read(courseMetadataChangedProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 20),

          // Название курса
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Название курса',
              hintText: 'Введите название курса',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) {
              ref.read(courseMetadataChangedProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 16),

          // Краткое описание
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Краткое описание',
              hintText: 'Введите краткое описание курса',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onChanged: (value) {
              ref.read(courseMetadataChangedProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 16),

          // Теги
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Теги',
              hintText: 'Введите теги через запятую',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              helperText: 'Разделите теги запятыми: программирование, Flutter, мобильная разработка',
            ),
            onChanged: (value) {
              ref.read(courseMetadataChangedProvider.notifier).state = true;
            },
          ),
        ],
      ),
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
        await ref.read(sectionProvider(_currentCourse?.id ?? widget.courseId).notifier).reorderSections(updated);
        ref.invalidate(sectionProvider(_currentCourse?.id ?? widget.courseId));
      },
      itemBuilder: (context, i) => _buildSectionTile(context, ref, sortedSections[i], lessons, i, Key('section_${sortedSections[i].id}')),
    );
  }

  Widget _buildSectionTile(BuildContext context, WidgetRef ref, Section section, List<Lesson> allLessons, int index, Key key) {
    final editingSectionId = ref.watch(editingSectionIdProvider);
    final isEditing = editingSectionId == section.id;
    final sectionLessons = List<Lesson>.from(allLessons.where((l) => l.sectionId == section.id))
      ..sort((a, b) => a.order.compareTo(b.order));
    final titleController = TextEditingController(text: section.title);
    final editStatus = ref.watch(sectionEditStatusProvider)[section.id] ?? EditStatus.idle;
    Future<void> saveTitle() async {
      final newTitle = titleController.text.trim();
      if (newTitle.isNotEmpty && newTitle != section.title) {
        ref.read(sectionEditStatusProvider.notifier).update((map) => {...map, section.id: EditStatus.loading});
        try {
          await ref.read(sectionProvider(_currentCourse?.id ?? widget.courseId).notifier).updateSectionTitle(section.id, newTitle);
          ref.read(sectionEditStatusProvider.notifier).update((map) => {...map, section.id: EditStatus.success});
          await Future.delayed(const Duration(seconds: 1));
          ref.read(sectionEditStatusProvider.notifier).update((map) => {...map, section.id: EditStatus.idle});
          ref.read(editingSectionIdProvider.notifier).state = null;
        } catch (e) {
          ref.read(sectionEditStatusProvider.notifier).update((map) => {...map, section.id: EditStatus.error});
          await Future.delayed(const Duration(seconds: 2));
          ref.read(sectionEditStatusProvider.notifier).update((map) => {...map, section.id: EditStatus.idle});
        }
      } else {
        ref.read(editingSectionIdProvider.notifier).state = null;
      }
    }
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
                  child: isEditing
                    ? Focus(
                        onFocusChange: (hasFocus) async {
                          if (!hasFocus) await saveTitle();
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: titleController,
                                autofocus: true,
                                onSubmitted: (_) async => await saveTitle(),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (editStatus == EditStatus.loading)
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            else if (editStatus == EditStatus.success)
                              const Icon(Icons.check_circle, color: Colors.green)
                            else if (editStatus == EditStatus.error)
                              const Icon(Icons.error, color: Colors.red)
                          ],
                        ),
                      )
                    : Text(
                        section.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Редактировать раздел',
                  onPressed: () {
                    ref.read(editingSectionIdProvider.notifier).state = section.id;
                  },
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
                  onPressed: () => _showCreateLessonDialog(context, ref, _currentCourse?.id ?? widget.courseId, section.id),
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
        final courseId = _currentCourse?.id ?? widget.courseId;
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
    final editingLessonId = ref.watch(editingLessonIdProvider);
    final isEditing = editingLessonId == lesson.id;
    final titleController = TextEditingController(text: lesson.title);
    final editStatus = ref.watch(lessonEditStatusProvider)[lesson.id] ?? EditStatus.idle;
    Future<void> saveTitle() async {
      final newTitle = titleController.text.trim();
      if (newTitle.isNotEmpty && newTitle != lesson.title) {
        ref.read(lessonEditStatusProvider.notifier).update((map) => {...map, lesson.id: EditStatus.loading});
        try {
          final courseId = _currentCourse?.id ?? widget.courseId;
          await ref.read(courseLessonsProvider(courseId).notifier).updateLessonTitle(lesson.id, newTitle);
          ref.read(lessonEditStatusProvider.notifier).update((map) => {...map, lesson.id: EditStatus.success});
          await Future.delayed(const Duration(seconds: 1));
          ref.read(lessonEditStatusProvider.notifier).update((map) => {...map, lesson.id: EditStatus.idle});
          ref.read(editingLessonIdProvider.notifier).state = null;
        } catch (e) {
          ref.read(lessonEditStatusProvider.notifier).update((map) => {...map, lesson.id: EditStatus.error});
          await Future.delayed(const Duration(seconds: 2));
          ref.read(lessonEditStatusProvider.notifier).update((map) => {...map, lesson.id: EditStatus.idle});
        }
      } else {
        ref.read(editingLessonIdProvider.notifier).state = null;
      }
    }
    return ListTile(
      key: key,
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_indicator, color: Colors.grey),
      ),
      title: isEditing
        ? Focus(
            onFocusChange: (hasFocus) async {
              if (!hasFocus) await saveTitle();
            },
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    autofocus: true,
                    onSubmitted: (_) async => await saveTitle(),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (editStatus == EditStatus.loading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else if (editStatus == EditStatus.success)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (editStatus == EditStatus.error)
                  const Icon(Icons.error, color: Colors.red)
              ],
            ),
          )
        : Text(lesson.title),
      subtitle: Text(lesson.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Редактировать урок',
            onPressed: () {
              ref.read(editingLessonIdProvider.notifier).state = lesson.id;
            },
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
          final courseId = _currentCourse?.id ?? widget.courseId;
          context.go('/admin/course/$courseId/lesson/${lesson.id}/edit');
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

  void _showCreateSectionDialog(BuildContext context, WidgetRef ref, String courseId) {
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

  void _showCreateLessonDialog(BuildContext context, WidgetRef ref, String courseId, String? sectionId) {
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
                final courseId = section.courseId;
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
                final courseId = lesson.courseId;
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