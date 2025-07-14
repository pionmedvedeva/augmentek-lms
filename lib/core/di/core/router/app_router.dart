import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/admin/presentation/screens/course_management_screen.dart';
import 'package:miniapp/features/student/presentation/screens/student_navigation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboard(),
        ),
      ),
      GoRoute(
        path: '/student',
        pageBuilder: (context, state) {
          final tabIndex = int.tryParse(state.uri.queryParameters['tab'] ?? '1') ?? 1;
          return NoTransitionPage(
            child: StudentNavigationScreen(tabIndex: tabIndex),
          );
        },
      ),
      GoRoute(
        path: '/admin/courses',
        builder: (context, state) => const CourseManagementScreen(),
      ),
    ],
  );
}); 