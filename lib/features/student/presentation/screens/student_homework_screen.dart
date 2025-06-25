import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/homework_submission.dart';
import 'package:miniapp/features/course/providers/homework_provider.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';

class StudentHomeworkScreen extends ConsumerWidget {
  const StudentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final studentHomework = ref.watch(studentHomeworkProvider(user.id.toString()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои домашние задания'),
        backgroundColor: Color(0xFF4A90B8), // primaryBlue
        foregroundColor: Colors.white,
      ),
      body: studentHomework.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'У вас пока нет домашних заданий',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return _buildHomeworkCard(context, submission);
            },
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
                onPressed: () => ref.refresh(studentHomeworkProvider(user.id.toString())),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkSubmission submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с датой и статусом
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Урок: ${submission.lessonId}', // TODO: получать название урока
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Отправлено: ${_formatDateTime(submission.submittedAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(submission.status),
              ],
            ),

            const SizedBox(height: 12),

            // Ответ студента
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ваш ответ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    submission.answer,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Комментарий преподавателя (если есть)
            if (submission.adminComment != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(submission.status).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(submission.status).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          size: 16,
                          color: _getStatusColor(submission.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Комментарий преподавателя:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(submission.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      submission.adminComment!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],

            // Дата проверки (если проверено)
            if (submission.reviewedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Проверено: ${_formatDateTime(submission.reviewedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(HomeworkStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: _getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
        return 'На проверке';
      case HomeworkStatus.approved:
        return 'Зачтено';
      case HomeworkStatus.needsWork:
        return 'Доработка';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 