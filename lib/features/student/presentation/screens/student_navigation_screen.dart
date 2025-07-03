import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/course/providers/enrollment_provider.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';

class StudentNavigationScreen extends ConsumerWidget {
  final int tabIndex;
  
  const StudentNavigationScreen({
    super.key,
    this.tabIndex = 1, // По умолчанию "Учеба"
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return user.when(
      data: (appUser) {
        if (appUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Показываем контент в зависимости от выбранного таба
        // TabBar теперь управляется из AppShell
        switch (tabIndex) {
          case 0:
            return const ClubTab();
          case 1:
          default:
            return const StudyTab();
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Ошибка: $error')),
    );
  }
}

class ClubTab extends StatelessWidget {
  const ClubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          const Text(
            'Клуб',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Плейсхолдер для будущих тренажеров и активностей
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.sports_esports_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Скоро здесь появятся тренажеры и внеклассные активности!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Развивай навыки, участвуй в соревнованиях и получай достижения',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudyTab extends ConsumerWidget {
  const StudyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextLesson = ref.watch(nextLessonProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          const Text(
            'Учеба',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Панель быстрых действий
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Быстрые действия',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.play_arrow,
                          title: 'Следующий урок',
                          color: const Color(0xFF4A90B8), // primaryBlue
                          onTap: () => _navigateToNextLesson(context, nextLesson, ref),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.assignment,
                          title: 'Мои домашки',
                          color: const Color(0xFFE8A87C), // accentOrange
                          onTap: () {
                            context.go('/student/homework');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Список курсов
          const Text(
            'Курсы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Полный список всех курсов
          ref.watch(activeCoursesProvider).when(
            data: (allCourses) {
              if (allCourses.isEmpty) {
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
                          'Пока нет доступных курсов',
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
              
              return Column(
                children: allCourses.map((course) => _buildCourseCard(context, course, ref)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Ошибка загрузки курсов: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, course, WidgetRef ref) {
    // Проверяем, записан ли студент на этот курс
    final isEnrolled = ref.watch(isEnrolledProvider(course.id));
    final progress = ref.watch(courseProgressProvider(course.id));
        
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isEnrolled) {
            context.go('/student/course/${course.id}', extra: {'course': course, 'tab': 1});
          } else {
            context.go('/courses');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Иконка курса
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90B8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Color(0xFF4A90B8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.description ?? 'Описание курса',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Статус записи
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnrolled 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEnrolled 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isEnrolled ? 'Записан' : 'Не записан',
                      style: TextStyle(
                        color: isEnrolled ? Colors.green : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isEnrolled) ...[
                const SizedBox(height: 16),
                
                // Прогресс (только для записанных курсов)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Прогресс',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A90B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90B8)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNextLesson(BuildContext context, nextLesson, WidgetRef ref) {
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
              context.go('/student/course/${course.id}', extra: course);
            } else {
              // Если есть последний урок, показываем информацию и переходим к курсу
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Продолжаем изучение курса "${course.title}"'),
                  action: SnackBarAction(
                    label: 'Открыть',
                    onPressed: () {
                      context.go('/student/course/${course.id}', extra: course);
                    },
                  ),
                ),
              );
              
              // Автоматически переходим к курсу через секунду
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  context.go('/student/course/${course.id}', extra: course);
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