import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/shared/models/homework_submission.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/course/providers/homework_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonViewScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const LessonViewScreen({
    super.key,
    required this.lesson,
  });

  @override
  ConsumerState<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends ConsumerState<LessonViewScreen> {
  YoutubePlayerController? _youtubeController;
  final TextEditingController _homeworkAnswerController = TextEditingController();
  bool _isSubmittingHomework = false;
  HomeworkSubmission? _existingSubmission;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _checkExistingSubmission();
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

  Future<void> _checkExistingSubmission() async {
    final user = ref.read(userProvider).value;
    if (user != null && !user.isAdmin) {
      try {
        final homeworkNotifier = ref.read(homeworkProvider.notifier);
        final submission = await homeworkNotifier.getStudentSubmissionForLesson(
          user.id.toString(),
          widget.lesson.id,
        );
        if (mounted) {
          setState(() {
            _existingSubmission = submission;
            if (submission != null && submission.status == HomeworkStatus.needsWork) {
              _homeworkAnswerController.text = submission.answer;
            }
          });
        }
      } catch (e) {
        // Ignore error - user just hasn't submitted yet
      }
    }
  }

  @override
  void dispose() {
    _homeworkAnswerController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок урока
            Text(
              widget.lesson.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Описание урока
            Text(
              widget.lesson.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            if (widget.lesson.durationMinutes > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Длительность: ${widget.lesson.durationMinutes} мин',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Контент урока
            if (widget.lesson.content != null && widget.lesson.content!.isNotEmpty) ...[
              const Text(
                'Материал урока',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  widget.lesson.content!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Видео урока
            if (_youtubeController != null) ...[
              const Text(
                'Видео урока',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
            if (widget.lesson.homeworkTask != null && widget.lesson.homeworkTask!.isNotEmpty) ...[
              const Text(
                'Домашнее задание',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Задание:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.lesson.homeworkTask!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
                             // Форма отправки домашки (только для студентов)
               if (user != null && !user.isAdmin) ...[
                 // Показываем статус существующей домашки
                 if (_existingSubmission != null) ...[
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: _getStatusColor(_existingSubmission!.status).withOpacity(0.1),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: _getStatusColor(_existingSubmission!.status)),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(
                               _getStatusIcon(_existingSubmission!.status),
                               color: _getStatusColor(_existingSubmission!.status),
                             ),
                             const SizedBox(width: 8),
                             Text(
                               _getStatusText(_existingSubmission!.status),
                               style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: _getStatusColor(_existingSubmission!.status),
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 8),
                         Text('Ваш ответ: ${_existingSubmission!.answer}'),
                         if (_existingSubmission!.adminComment != null) ...[
                           const SizedBox(height: 8),
                           Text(
                             'Комментарий преподавателя: ${_existingSubmission!.adminComment}',
                             style: TextStyle(
                               fontStyle: FontStyle.italic,
                               color: Colors.grey[600],
                             ),
                           ),
                         ],
                       ],
                     ),
                   ),
                   const SizedBox(height: 16),
                 ],
                 
                 // Форма для отправки/переотправки
                 if (_existingSubmission == null || _existingSubmission!.status == HomeworkStatus.needsWork) ...[
                   Text(
                     _existingSubmission == null ? 'Ваш ответ' : 'Исправленный ответ',
                     style: const TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 8),
                   TextField(
                     controller: _homeworkAnswerController,
                     decoration: InputDecoration(
                       labelText: _existingSubmission == null 
                         ? 'Введите ваш ответ на домашнее задание'
                         : 'Исправьте ваш ответ',
                       border: const OutlineInputBorder(),
                       hintText: 'Опишите ваше решение...',
                     ),
                     maxLines: 5,
                   ),
                   const SizedBox(height: 12),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _isSubmittingHomework ? null : _submitHomework,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: _existingSubmission == null ? Colors.green : Colors.orange,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 12),
                       ),
                       child: _isSubmittingHomework
                           ? const Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 SizedBox(
                                   width: 20,
                                   height: 20,
                                   child: CircularProgressIndicator(
                                     strokeWidth: 2,
                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                   ),
                                 ),
                                 SizedBox(width: 8),
                                 Text('Отправляем...'),
                               ],
                             )
                           : Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Icon(Icons.send),
                                 const SizedBox(width: 8),
                                 Text(_existingSubmission == null 
                                   ? 'Отправить домашнее задание'
                                   : 'Отправить исправленное задание'),
                               ],
                             ),
                     ),
                   ),
                 ],
               ],
              
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitHomework() async {
    if (_homeworkAnswerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ответ на домашнее задание')),
      );
      return;
    }

    final user = ref.read(userProvider).value;
    if (user == null) return;

    setState(() {
      _isSubmittingHomework = true;
    });

    try {
      final homeworkNotifier = ref.read(homeworkProvider.notifier);
      
      await homeworkNotifier.submitHomework(
        lessonId: widget.lesson.id,
        courseId: widget.lesson.courseId,
        studentId: user.id.toString(),
        studentName: user.firstName + (user.lastName != null ? ' ${user.lastName}' : ''),
        answer: _homeworkAnswerController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Домашнее задание отправлено на проверку!'),
            backgroundColor: Colors.green,
          ),
        );
        _homeworkAnswerController.clear();
        _checkExistingSubmission(); // Обновляем статус
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingHomework = false;
        });
      }
    }
  }

  Color _getStatusColor(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.pending:
        return Colors.orange;
      case HomeworkStatus.approved:
        return Colors.green;
      case HomeworkStatus.needsWork:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.pending:
        return Icons.schedule;
      case HomeworkStatus.approved:
        return Icons.check_circle;
      case HomeworkStatus.needsWork:
        return Icons.error;
    }
  }

  String _getStatusText(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.pending:
        return 'Ожидает проверки';
      case HomeworkStatus.approved:
        return 'Зачтено';
      case HomeworkStatus.needsWork:
        return 'Требует доработки';
    }
  }
} 