import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/student/presentation/screens/student_navigation_screen.dart';

class MainContentSwitcher extends ConsumerStatefulWidget {
  final String section;
  final String? tab;

  const MainContentSwitcher({
    super.key,
    required this.section,
    this.tab,
  });

  @override
  ConsumerState<MainContentSwitcher> createState() => _MainContentSwitcherState();
}

class _MainContentSwitcherState extends ConsumerState<MainContentSwitcher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.section == 'admin' ? 0 : 1,
    );
  }

  @override
  void didUpdateWidget(MainContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section != widget.section) {
      final newIndex = widget.section == 'admin' ? 0 : 1;
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Нижние табы в стиле верхних
        Container(
          color: const Color(0xFF4A90B8),
          child: SafeArea(
            top: false,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              onTap: (index) {
                final newSection = index == 0 ? 'admin' : 'student';
                // Обновляем URL без навигации
                // context.go('/main?section=$newSection${widget.tab != null ? '&tab=${widget.tab}' : ''}');
              },
              tabs: const [
                Tab(
                  icon: Icon(Icons.admin_panel_settings),
                  text: 'Учительская',
                ),
                Tab(
                  icon: Icon(Icons.school),
                  text: 'Студенческая',
                ),
              ],
            ),
          ),
        ),
        // Контент
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Админская часть
              const AdminDashboard(),
              // Студенческая часть
              StudentNavigationScreen(
                tabIndex: widget.tab != null ? int.tryParse(widget.tab!) ?? 1 : 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 