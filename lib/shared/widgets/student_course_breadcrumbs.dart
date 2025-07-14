import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:collection/collection.dart';

class StudentCourseBreadcrumbs extends ConsumerWidget {
  final String currentRoute;
  const StudentCourseBreadcrumbs({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseId = _extractCourseId(currentRoute);
    final lessonId = _extractLessonId(currentRoute);
    final coursesAsync = ref.watch(courseProvider);
    final lessonAsync = lessonId != null ? ref.watch(lessonByIdProvider(lessonId)) : null;
    
    String? courseTitle;
    String? lessonTitle;
    Course? course;
    
    if (coursesAsync is AsyncData<List>) {
      final list = coursesAsync.value;
      if (list != null) {
        course = list.firstWhereOrNull((c) => c.id == courseId);
        courseTitle = course?.title;
      } else {
        course = null;
        courseTitle = null;
      }
    }
    
    if (lessonAsync != null && lessonAsync is AsyncData) {
      lessonTitle = lessonAsync.value?.title;
    }
    
    // Определяем маршрут для кнопки назад
    String? backRoute;
    if (lessonId != null) {
      // На экране урока — назад к курсу
      backRoute = '/student/course/$courseId';
    } else if (courseId != null) {
      // На экране курса — назад к учебе
      backRoute = '/student?tab=1';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (backRoute != null) {
                context.go(backRoute);
              }
            },
            icon: const Icon(Icons.arrow_back),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go('/student?tab=1'),
            child: const Text(
              'Учеба',
              style: TextStyle(
                color: Color(0xFF4A90B8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: courseId != null ? () => context.go('/student/course/$courseId') : null,
            child: Text(
              courseTitle ?? 'Курс',
              style: const TextStyle(
                color: Color(0xFF4A90B8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (lessonTitle != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lessonTitle,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            const Spacer(),
          ],
        ],
      ),
    );
  }

  String? _extractCourseId(String route) {
    final match = RegExp(r'/course/([^/]+)').firstMatch(route);
    return match?.group(1);
  }
  
  String? _extractLessonId(String route) {
    final match = RegExp(r'/lesson/([^/]+)').firstMatch(route);
    return match?.group(1);
  }
} 