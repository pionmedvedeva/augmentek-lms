import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/admin/presentation/screens/course_management_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Показываем CourseManagementScreen как дефолтный экран админа
    // TabBar теперь управляется из AppShell
    return const CourseManagementScreen();
  }
} 