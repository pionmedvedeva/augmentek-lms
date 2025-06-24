import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/features/admin/presentation/widgets/create_course_dialog.dart';
import 'package:miniapp/features/admin/presentation/widgets/course_card.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_screen.dart';

class CourseManagementScreen extends ConsumerWidget {
  const CourseManagementScreen({super.key});

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
                      onEdit: () => _showEditCourseDialog(context, ref, course),
                      onEditDescription: () => _showEditDescriptionDialog(context, ref, course),
                      onDelete: () => _showDeleteConfirmation(context, ref, course.id),
                      onToggleStatus: (isActive) => ref
                          .read(courseProvider.notifier)
                          .toggleCourseStatus(course.id, isActive),
                      onManageContent: () => _navigateToCourseContent(context, course),
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
        onPressed: () => _showCreateCourseDialog(context, ref),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCourseContent(BuildContext context, course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseContentScreen(course: course),
      ),
    );
  }

  void _showCreateCourseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => CreateCourseDialog(
        onCourseCreated: (course) {
          ref.read(courseProvider.notifier).createCourse(course);
        },
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, WidgetRef ref, course) {
    showDialog(
      context: context,
      builder: (context) => CreateCourseDialog(
        course: course,
        onCourseCreated: (updatedCourse) {
          ref.read(courseProvider.notifier).updateCourse(updatedCourse);
        },
      ),
    );
  }

  void _showEditDescriptionDialog(BuildContext context, WidgetRef ref, course) {
    final controller = TextEditingController(text: course.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать описание'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Описание курса',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final updatedCourse = course.copyWith(
                  description: controller.text.trim(),
                  updatedAt: DateTime.now(),
                );
                await ref.read(courseProvider.notifier).updateCourse(updatedCourse);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Описание обновлено')),
                  );
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
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