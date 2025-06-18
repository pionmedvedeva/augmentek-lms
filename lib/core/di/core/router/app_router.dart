import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/student/presentation/screens/student_dashboard.dart';

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
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
    ],
  );
}); 