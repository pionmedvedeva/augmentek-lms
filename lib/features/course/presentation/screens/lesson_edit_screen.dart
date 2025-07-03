import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:go_router/go_router.dart';

class LessonEditScreen extends ConsumerWidget {
  final String courseId;
  final String lessonId;

  const LessonEditScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonByIdProvider(lessonId));

    return lessonAsync.when(
      data: (lesson) {
        if (lesson == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Урок не найден'),
              ],
            ),
          );
        }
        // Только контент урока и кнопка 'Сохранить', без AppBar/breadcrumbs
        return LessonEditFormScreen(lesson: lesson);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Ошибка загрузки урока: $error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(lessonByIdProvider(lessonId)),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonEditFormScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const LessonEditFormScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<LessonEditFormScreen> createState() => _LessonEditFormScreenState();
}

class _LessonEditFormScreenState extends ConsumerState<LessonEditFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _homeworkTaskController;
  late final TextEditingController _homeworkAnswerController;
  late final TextEditingController _durationController;

  YoutubePlayerController? _youtubeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson.title);
    _descriptionController = TextEditingController(text: widget.lesson.description);
    _contentController = TextEditingController(text: widget.lesson.content ?? '');
    _videoUrlController = TextEditingController(text: widget.lesson.videoUrl ?? '');
    _homeworkTaskController = TextEditingController(text: widget.lesson.homeworkTask ?? '');
    _homeworkAnswerController = TextEditingController(text: widget.lesson.homeworkAnswer ?? '');
    _durationController = TextEditingController(text: widget.lesson.durationMinutes.toString());

    _initializeVideoPlayer();
    _videoUrlController.addListener(_onVideoUrlChanged);
  }

  void _initializeVideoPlayer() {
    if (widget.lesson.videoUrl != null && widget.lesson.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  void _onVideoUrlChanged() {
    final url = _videoUrlController.text.trim();
    if (url.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
        setState(() {});
      }
    } else {
      _youtubeController?.dispose();
      _youtubeController = null;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _homeworkTaskController.dispose();
    _homeworkAnswerController.dispose();
    _durationController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _saveLesson() async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название и описание обязательны')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedLesson = widget.lesson.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
        videoUrl: _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
        homeworkTask: _homeworkTaskController.text.trim().isEmpty ? null : _homeworkTaskController.text.trim(),
        homeworkAnswer: _homeworkAnswerController.text.trim().isEmpty ? null : _homeworkAnswerController.text.trim(),
        durationMinutes: int.tryParse(_durationController.text.trim()) ?? 0,
        updatedAt: DateTime.now(),
      );

      await ref.read(lessonProvider.notifier).updateLesson(updatedLesson);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Урок обновлен успешно')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления урока: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(courseProvider);
    Course? course;
    final list = coursesAsync.asData?.value;
    if (list != null) {
      try {
        course = list.firstWhere((c) => c.id == widget.lesson.courseId);
      } catch (_) {
        course = null;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название урока
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название урока *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Краткое описание
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Краткое описание *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            // Длительность
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Длительность (минуты)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            // Основной контент урока
            const Text(
              'Содержание урока',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Текст урока',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            // Видео
            const Text(
              'Видео урока',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Ссылка на YouTube видео',
                border: OutlineInputBorder(),
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 16),
            // Превью видео
            if (_youtubeController != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Домашнее задание
            const Text(
              'Домашнее задание',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _homeworkTaskController,
              decoration: const InputDecoration(
                labelText: 'Формулировка задания',
                border: OutlineInputBorder(),
                hintText: 'Опишите что должен сделать студент...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _homeworkAnswerController,
              decoration: const InputDecoration(
                labelText: 'Правильный ответ/решение',
                border: OutlineInputBorder(),
                hintText: 'Введите правильный ответ или решение...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            // Кнопка 'Сохранить'
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90B8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseBreadcrumbs extends StatelessWidget {
  final String courseTitle;
  final VoidCallback? onCourseTap;
  final String? lessonTitle;
  final Widget? trailing;
  const CourseBreadcrumbs({
    super.key,
    required this.courseTitle,
    this.onCourseTap,
    this.lessonTitle,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    // Удаляю breadcrumbs, теперь они только глобальные в AppShell
    return const SizedBox.shrink();
  }
} 