import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/homework_submission.dart';
import 'package:miniapp/features/course/providers/homework_provider.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';

class HomeworkReviewScreen extends ConsumerStatefulWidget {
  const HomeworkReviewScreen({super.key});

  @override
  ConsumerState<HomeworkReviewScreen> createState() => _HomeworkReviewScreenState();
}

class _HomeworkReviewScreenState extends ConsumerState<HomeworkReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _currentIndex = 0;
  bool _isReviewing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingHomework = ref.watch(pendingHomeworkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Проверка домашних заданий'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: pendingHomework.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Нет домашних заданий для проверки',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final submission = submissions[_currentIndex];

          return Column(
            children: [
              // Навигационная панель
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentIndex > 0 ? () {
                        setState(() {
                          _currentIndex--;
                          _commentController.clear();
                        });
                      } : null,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Text(
                        'Задание ${_currentIndex + 1} из ${submissions.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _currentIndex < submissions.length - 1 ? () {
                        setState(() {
                          _currentIndex++;
                          _commentController.clear();
                        });
                      } : null,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),

              // Содержимое домашки
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Информация о студенте и дате
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    submission.studentName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Отправлено: ${_formatDateTime(submission.submittedAt)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Задание (для справки)
                      const Text(
                        'Задание:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Задание урока будет загружено...',  // TODO: загружать актуальное задание
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Ответ студента
                      const Text(
                        'Ответ студента:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                        ),
                        child: Text(
                          submission.answer,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Форма для комментария
                      const Text(
                        'Комментарий (для доработки):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          labelText: 'Укажите что нужно исправить (необязательно)',
                          border: OutlineInputBorder(),
                          hintText: 'Комментарий для студента...',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Кнопки действий
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isReviewing ? null : () => _reviewHomework(
                          submission,
                          HomeworkStatus.needsWork,
                        ),
                        icon: const Icon(Icons.replay),
                        label: const Text('На доработку'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isReviewing ? null : () => _reviewHomework(
                          submission,
                          HomeworkStatus.approved,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Зачет'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка загрузки: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(pendingHomeworkProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reviewHomework(HomeworkSubmission submission, HomeworkStatus status) async {
    final user = ref.read(userProvider).value;
    if (user == null) return;

    setState(() {
      _isReviewing = true;
    });

    try {
      final homeworkNotifier = ref.read(homeworkProvider.notifier);
      
      await homeworkNotifier.reviewHomework(
        submissionId: submission.id,
        status: status,
        reviewedBy: user.id.toString(),
        adminComment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == HomeworkStatus.approved 
                ? 'Домашнее задание зачтено!' 
                : 'Домашнее задание отправлено на доработку'),
            backgroundColor: status == HomeworkStatus.approved 
                ? Colors.green 
                : Colors.orange,
          ),
        );

        // Обновляем список и переходим к следующему заданию
        ref.refresh(pendingHomeworkProvider);
        _commentController.clear();
        
        // Если это было последнее задание, возвращаемся к первому
        final submissions = await ref.read(pendingHomeworkProvider.future);
        if (_currentIndex >= submissions.length - 1) {
          setState(() {
            _currentIndex = 0;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewing = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 