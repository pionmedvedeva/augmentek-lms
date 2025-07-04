import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'course_management_screen.dart';
import 'user_list_screen.dart';
import 'homework_review_screen.dart';

class AdminNavigationScreen extends ConsumerWidget {
  final int tabIndex;
  
  const AdminNavigationScreen({
    super.key, 
    this.tabIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Показываем контент в зависимости от выбранного таба
    // TabBar теперь управляется из AppShell
    switch (tabIndex) {
      case 0:
        return const CourseManagementScreen();
      case 1:
        return const UserListScreen();
      case 2:
        return const HomeworkReviewScreen();
      default:
        return const CourseManagementScreen();
    }
  }
} 