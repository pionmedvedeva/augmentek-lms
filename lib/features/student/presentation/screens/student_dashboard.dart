import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/course/providers/enrollment_provider.dart';
import 'package:miniapp/features/student/presentation/screens/student_homework_screen.dart';
import 'package:miniapp/features/student/presentation/screens/student_course_view_screen.dart';
import 'package:miniapp/features/student/presentation/screens/enrolled_courses_screen.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final enrolledCourses = ref.watch(enrolledCoursesProvider);
    final nextLesson = ref.watch(nextLessonProvider);

    return user.when(
      data: (appUser) {
        if (appUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.play_arrow,
                      title: 'Следующий урок',
                      color: Color(0xFF4A90B8), // primaryBlue
                      onTap: () => _navigateToNextLesson(context, nextLesson, ref),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.assignment,
                      title: 'Домашки',
                      color: Color(0xFFE8A87C), // accentOrange
                      onTap: () {
                        context.go('/student/homework');
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Current Course Section (replacing Popular Courses)
              const Text(
                'Продолжить обучение',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Active Course Preview
              enrolledCourses.when(
                data: (courseList) {
                  if (courseList.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Show the most recent active course
                  final activeCourse = courseList.first;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.go('/course/${activeCourse.id}', extra: activeCourse);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4A90B8).withOpacity(0.8), // primaryBlue
                                    Color(0xFF87CEEB).withOpacity(0.6), // lightBlue
                                  ],
                                ),
                              ),
                              child: activeCourse.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        activeCourse.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return const Center(
                                            child: Icon(
                                              Icons.school,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.school,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeCourse.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeCourse.description,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Card(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Ошибка загрузки курсов',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNextLesson(BuildContext context, AsyncValue<Map<String, String>?> nextLesson, WidgetRef ref) {
    nextLesson.when(
      data: (lessonData) {
        if (lessonData == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!'),
            ),
          );
          return;
        }
        
        final courseId = lessonData['courseId']!;
        final lessonId = lessonData['lessonId']!;
        
        // Найдем курс из записанных курсов
        final enrolledCourses = ref.read(enrolledCoursesProvider);
        enrolledCourses.when(
          data: (courses) {
            final course = courses.firstWhere((c) => c.id == courseId);
            
            if (lessonId.isEmpty) {
              // Если нет последнего урока, открываем просто курс
              context.go('/course/${course.id}', extra: course);
            } else {
              // Если есть последний урок, показываем информацию и переходим к курсу
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Продолжаем изучение курса "${course.title}"'),
                  action: SnackBarAction(
                    label: 'Открыть',
                    onPressed: () {
                      context.go('/course/${course.id}', extra: course);
                    },
                  ),
                ),
              );
              
              // Автоматически переходим к курсу через секунду
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.go('/course/${course.id}', extra: course);
                }
              });
            }
          },
          loading: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Загрузка курсов...')),
          ),
          error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка загрузки курса')),
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Поиск следующего урока...')),
      ),
      error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка поиска следующего урока')),
      ),
    );
  }
} 