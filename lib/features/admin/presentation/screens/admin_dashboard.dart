import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/admin/presentation/screens/course_management_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/user_list_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/homework_review_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // TabBar без AppBar
          Container(
            color: const Color(0xFF4A90B8), // primaryBlue
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(
                  icon: Icon(Icons.school),
                  text: 'Курсы',
                ),
                Tab(
                  icon: Icon(Icons.people),
                  text: 'Пользователи',
                ),
                Tab(
                  icon: Icon(Icons.assignment),
                  text: 'Домашки',
                ),
              ],
            ),
          ),
          // Контент
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CourseManagementScreen(),
                UserListScreen(),
                HomeworkReviewScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 