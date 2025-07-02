import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/course/providers/enrollment_provider.dart';
import 'package:miniapp/features/student/presentation/screens/student_course_view_screen.dart';
import 'package:miniapp/shared/models/course.dart';

class EnrolledCoursesScreen extends ConsumerWidget {
  const EnrolledCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledCourses = ref.watch(enrolledCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои курсы'),
      ),
      body: enrolledCourses.when(
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(
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
                    'Ты нигде не учишься. Выгляни в коридор, чтобы найти что-нибудь интересное!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return EnrolledCourseCard(
                course: course,
                onTap: () => _openCourse(context, course),
              );
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
              Text('Ошибка загрузки курсов: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(enrolledCoursesProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCourse(BuildContext context, Course course) {
    context.go('/course/${course.id}', extra: course);
  }
}

class EnrolledCourseCard extends ConsumerWidget {
  final Course course;
  final VoidCallback onTap;

  const EnrolledCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(courseProgressProvider(course.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Иконка/обложка курса
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: course.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              course.imageUrl!,
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
                  
                  // Информация о курсе
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.description,
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
              
              const SizedBox(height: 16),
              
              // Прогресс
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              if (course.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: course.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 