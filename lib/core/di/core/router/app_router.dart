import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/widgets/main_shell.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/admin/presentation/screens/course_management_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/course_content_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/lesson_edit_screen.dart';
import 'package:miniapp/features/student/presentation/screens/student_navigation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/admin/courses',
            builder: (context, state) => const CourseManagementScreen(),
          ),
          GoRoute(
            path: '/admin/course/:courseId/edit',
            builder: (context, state) => CourseContentScreen(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
          GoRoute(
            path: '/admin/course/:courseId/lesson/:lessonId/edit',
            builder: (context, state) => LessonEditScreen(
              courseId: state.pathParameters['courseId']!,
              lessonId: state.pathParameters['lessonId']!,
            ),
          ),
          GoRoute(
            path: '/student',
            builder: (context, state) {
              final tabIndex = int.tryParse(state.uri.queryParameters['tab'] ?? '1') ?? 1;
              return StudentNavigationScreen(tabIndex: tabIndex);
            },
          ),
        ],
      ),
    ],
  );
}); 