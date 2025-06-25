import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/admin/presentation/screens/course_management_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/user_list_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/homework_review_screen.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';

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
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учительская'),
        centerTitle: true,
                  backgroundColor: Color(0xFF4A90B8), // primaryBlue
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
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
      body: user.when(
        data: (appUser) {
          if (appUser?.isAdmin != true) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Доступ запрещен',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'У вас нет прав доступа в учительскую',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              CourseManagementScreen(),
              UserListScreen(),
              HomeworkReviewScreen(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: const DebugToggleButton(),
    );
  }
} 