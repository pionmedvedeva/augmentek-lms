import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/features/course/providers/enrollment_provider.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/features/student/presentation/screens/student_course_view_screen.dart';
import 'package:miniapp/core/utils/string_utils.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(availableCoursesProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search only
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск курсов...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Course List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(courseProvider.notifier).loadCourses();
              },
              child: courses.when(
                data: (courseList) {
                  final filteredCourses = _filterCourses(courseList);
                  
                  if (filteredCourses.isEmpty) {
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
                            'Курсы не найдены',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Попробуйте изменить поисковый запрос',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return AvailableCourseCard(
                        course: course,
                        onView: () => _openCourse(course),
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
                        onPressed: () => ref.read(courseProvider.notifier).loadCourses(),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Course> _filterCourses(List<Course> courses) {
    return courses.where((course) {
      // Filter by search query only (courses are already active)
      final matchesSearch = _searchQuery.isEmpty ||
          course.title.toLowerCase().contains(_searchQuery) ||
          course.description.toLowerCase().contains(_searchQuery);
      
      return matchesSearch;
    }).toList();
  }

  void _openCourse(Course course) {
    context.go('/course/${course.id}', extra: course);
  }
}

class AvailableCourseCard extends ConsumerWidget {
  final Course course;
  final VoidCallback onView;

  const AvailableCourseCard({
    super.key,
    required this.course,
    required this.onView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentState = ref.watch(enrollmentProvider);
    final isEnrolled = ref.watch(isEnrolledProvider(course.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      const SizedBox(height: 8),
                      // Статистика
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            RussianPlurals.formatStudents(course.enrolledCount),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
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
            
            const SizedBox(height: 16),
            
            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onView,
                    child: const Text('Подробнее'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isEnrolled 
                        ? null 
                        : enrollmentState.isLoading 
                            ? null 
                            : () => _enrollInCourse(ref, context),
                    child: enrollmentState.isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEnrolled ? 'Записан' : 'Записаться'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enrollInCourse(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(enrollmentProvider.notifier).enrollInCourse(course.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Вы записались на курс "${course.title}"'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Открыть',
              textColor: Colors.white,
              onPressed: onView,
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка записи: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 