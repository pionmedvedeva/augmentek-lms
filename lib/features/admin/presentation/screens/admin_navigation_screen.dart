import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'course_management_screen.dart';
import 'user_list_screen.dart';
import 'homework_review_screen.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/features/course/presentation/screens/course_content_screen.dart';

class AdminNavigationScreen extends ConsumerStatefulWidget {
  final int tabIndex;
  const AdminNavigationScreen({Key? key, this.tabIndex = 0}) : super(key: key);

  @override
  ConsumerState<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends ConsumerState<AdminNavigationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.tabIndex;
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Сбросить выбранный курс при смене таба
        if (_tabController.index != 0) {
          _selectedCourse = null;
        }
      });
    }
  }

  void _openCourse(Course course) {
    setState(() {
      _selectedCourse = course;
    });
  }

  void _closeCourse() {
    setState(() {
      _selectedCourse = null;
    });
  }

  Widget _buildBreadcrumbs() {
    if (_selectedCourse == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _closeCourse,
            icon: const Icon(Icons.arrow_back, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Text(
            _selectedCourse!.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF4A90B8),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.school), text: 'Курсы'),
              Tab(icon: Icon(Icons.people), text: 'Пользователи'),
              Tab(icon: Icon(Icons.assignment), text: 'Домашки'),
            ],
          ),
        ),
        // Breadcrumbs только для таба "Курсы" и если выбран курс
        if (_tabController.index == 0 && _selectedCourse != null)
          _buildBreadcrumbs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Курсы
              _selectedCourse == null
                  ? CourseManagementScreen(onOpenCourse: _openCourse)
                  : CourseContentScreen(courseId: _selectedCourse!.id),
              // Пользователи
              const UserListScreen(),
              // Домашки
              const HomeworkReviewScreen(),
            ],
          ),
        ),
      ],
    );
  }
} 