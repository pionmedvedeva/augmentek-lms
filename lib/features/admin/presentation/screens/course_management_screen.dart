import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../course/providers/course_provider.dart';
import '../widgets/course_card.dart';

class CourseManagementScreen extends ConsumerWidget {
  const CourseManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(courseProvider.notifier).loadCourses();
        },
        child: courses.when(
          data: (courseList) => courseList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Курсы отсутствуют',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Создайте первый курс для начала работы',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courseList.length,
                  itemBuilder: (context, index) {
                    final course = courseList[index];
                    return CourseCard(
                      course: course,
                      onDelete: () => _showDeleteConfirmation(context, ref, course.id),
                      onToggleStatus: (isActive) => ref
                          .read(courseProvider.notifier)
                          .toggleCourseStatus(course.id, isActive),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Ошибка загрузки курсов: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(courseProvider.notifier).loadCourses(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateCourse(context),
        backgroundColor: Color(0xFF4A90B8), // primaryBlue
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreateCourse(BuildContext context) {
    // Создаем временный курс и переходим к его редактированию
    context.go('/admin/course/new/edit');
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить курс?'),
        content: const Text(
          'Это действие нельзя отменить. Все уроки курса также будут удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Закрываем диалог подтверждения
              
              BuildContext? loadingContext;
              
              try {
                // Показываем индикатор загрузки
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    loadingContext = dialogContext;
                    return const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Удаление курса...'),
                        ],
                      ),
                    );
                  },
                );
                
                await ref.read(courseProvider.notifier).deleteCourse(courseId);
                
                // Показываем успешное сообщение
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Курс успешно удален'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                
              } catch (error) {
                // Показываем подробную ошибку
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ошибка удаления'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Не удалось удалить курс.'),
                          const SizedBox(height: 8),
                          const Text('Детали ошибки:'),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              error.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Закрыть'),
                        ),
                      ],
                    ),
                  );
                }
              } finally {
                // Гарантированно закрываем индикатор загрузки
                if (loadingContext != null && loadingContext!.mounted) {
                  Navigator.of(loadingContext!).pop();
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
} 