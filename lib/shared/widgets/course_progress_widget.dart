import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../models/course_progress.dart';
import '../../features/course/providers/progress_provider.dart';

class CourseProgressWidget extends ConsumerWidget {
  const CourseProgressWidget({
    super.key,
    required this.userId,
    required this.courseId,
    this.showDetails = true,
    this.showMotivation = false,
    this.compact = false,
  });

  final String userId;
  final String courseId;
  final bool showDetails;
  final bool showMotivation;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(courseProgressProvider('${userId}_$courseId'));

    return progressAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error),
      data: (progress) => progress != null 
          ? _buildProgressContent(context, progress)
          : _buildNoProgressState(context),
    );
  }

  Widget _buildLoadingState() {
    if (compact) {
      return const SizedBox(
        height: 4,
        child: LinearProgressIndicator(),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Загрузка прогресса...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    if (compact) {
      return Container(
        height: 4,
        color: Colors.red.withOpacity(0.3),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Ошибка загрузки прогресса',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProgressState(BuildContext context) {
    if (compact) {
      return Container(
        height: 4,
        color: Colors.grey.withOpacity(0.3),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_outline, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  'Готов к изучению',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
            if (showMotivation) ...[
              const SizedBox(height: 8),
              Text(
                'Время начать! Первый урок ждет тебя 🚀',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildProgressContent(BuildContext context, CourseProgress progress) {
    if (compact) {
      return LinearProgressIndicator(
        value: progress.completionPercentage,
        backgroundColor: Colors.grey.withOpacity(0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          ProgressHelper.getCourseProgressColor(progress.completionPercentage),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с иконкой статуса
            Row(
              children: [
                Icon(
                  _getStatusIcon(progress.status),
                  color: _getStatusColor(progress.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusText(progress.status),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${progress.completionPercent}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ProgressHelper.getCourseProgressColor(progress.completionPercentage),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Полоска прогресса
            LinearProgressIndicator(
              value: progress.completionPercentage,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                ProgressHelper.getCourseProgressColor(progress.completionPercentage),
              ),
            ),
            
            if (showDetails) ...[
              const SizedBox(height: 12),
              
              // Детальная статистика
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    context,
                    Icons.article,
                    progress.progressText,
                    AppTheme.primaryBlue,
                  ),
                  if (progress.totalHomework > 0)
                    _buildStatChip(
                      context,
                      Icons.assignment,
                      '${progress.completedHomework}/${progress.totalHomework} домашек',
                      AppTheme.accentOrange,
                    ),
                  if (progress.totalTimeSpentSeconds > 0)
                    _buildStatChip(
                      context,
                      Icons.access_time,
                      ProgressHelper.formatStudyTime(progress.totalTimeSpentSeconds),
                      AppTheme.lightBlue,
                    ),
                  if (progress.hasPendingHomework)
                    _buildStatChip(
                      context,
                      Icons.pending_actions,
                      '${progress.pendingHomework} на проверке',
                      Colors.orange,
                    ),
                ],
              ),
            ],
            
            if (showMotivation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ProgressHelper.getCourseProgressColor(progress.completionPercentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 20,
                      color: ProgressHelper.getCourseProgressColor(progress.completionPercentage),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ProgressHelper.getMotivationalMessage(progress),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(CourseStatus status) {
    switch (status) {
      case CourseStatus.notStarted:
        return Icons.play_circle_outline;
      case CourseStatus.inProgress:
        return Icons.pending_actions;
      case CourseStatus.completed:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.notStarted:
        return Colors.grey;
      case CourseStatus.inProgress:
        return Colors.orange;
      case CourseStatus.completed:
        return Colors.green;
    }
  }

  String _getStatusText(CourseStatus status) {
    switch (status) {
      case CourseStatus.notStarted:
        return 'Готов к изучению';
      case CourseStatus.inProgress:
        return 'В процессе изучения';
      case CourseStatus.completed:
        return 'Курс завершен';
    }
  }
}

/// Компактная версия прогресса для карточек курсов
class CompactCourseProgress extends StatelessWidget {
  const CompactCourseProgress({
    super.key,
    required this.userId,
    required this.courseId,
  });

  final String userId;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return CourseProgressWidget(
      userId: userId,
      courseId: courseId,
      compact: true,
      showDetails: false,
      showMotivation: false,
    );
  }
} 