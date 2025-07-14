import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/core/services/navigation_service.dart';
import 'package:miniapp/shared/widgets/admin_course_breadcrumbs.dart';
import 'package:miniapp/shared/widgets/student_course_breadcrumbs.dart';

/// AppLayout отвечает только за UI: шапка, аватар, табы, навигация, debug-кнопка
/// Не содержит логики аутентификации и инициализации
class AppLayout extends ConsumerStatefulWidget {
  final Widget child;
  final AppUser user;
  final bool showBottomNav;
  final bool showAvatar;

  const AppLayout({
    super.key,
    required this.child,
    required this.user,
    this.showBottomNav = true,
    this.showAvatar = true,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> 
    with SingleTickerProviderStateMixin {
  
  final NavigationService _navigationService = NavigationService();
  
  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    // Получаем параметры для TabController через NavigationService
    final tabParams = _navigationService.getTabControllerParams(currentRoute);
    TabController? tabController;
    
    if (tabParams != null) {
      tabController = TabController(
        length: tabParams.length,
        vsync: this,
        initialIndex: tabParams.initialIndex,
      );
    }





    Widget mainContent = Column(
      children: [
          // Студенческий TabBar (Level 1 navigation)
          if (_navigationService.shouldShowStudentTabs(currentRoute) && tabController != null)
            Container(
              color: const Color(0xFF4A90B8), // primaryBlue
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                onTap: (index) => _navigationService.navigateToStudentTab(context, index),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.sports_esports),
                    text: 'Клуб',
                  ),
                  Tab(
                    icon: Icon(Icons.school),
                    text: 'Учеба',
                  ),
                ],
              ),
            ),
          
          // Админский TabBar (Level 1 navigation)
          if (_navigationService.shouldShowAdminTabs(currentRoute) && tabController != null)
            Container(
              color: const Color(0xFF4A90B8), // primaryBlue
              child: TabBar(
                controller: tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                onTap: (index) => _navigationService.navigateToAdminTab(context, index),
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
          
          // Breadcrumbs (Level 2+ navigation)
          if (currentRoute.startsWith('/admin/course/'))
            AdminCourseBreadcrumbs(currentRoute: currentRoute)
          else if (currentRoute.startsWith('/student/course/'))
            StudentCourseBreadcrumbs(currentRoute: currentRoute)
          else if (_shouldShowBreadcrumbs(currentRoute))
            _buildBreadcrumbs(currentRoute),

          // Основной контент
          Expanded(child: widget.child),
        ],
    );

    // Удаляю Stack с debug-кнопкой, оставляю только Scaffold
    // if (shouldShowDebugPanel) {
    //   mainContent = Stack(
    //     children: [
    //       mainContent,
    //       Positioned(
    //         top: 16,
    //         right: 16,
    //         child: FloatingActionButton.small(
    //           onPressed: () => _navigationService.showDebugLogs(context),
    //           backgroundColor: Colors.blue,
    //           foregroundColor: Colors.white,
    //           child: const Icon(Icons.bug_report),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    return mainContent;
  }

  bool _shouldShowBreadcrumbs(String route) {
    // Показываем breadcrumbs для вложенных экранов (Level 2+)
    // Исключаем /admin/course/ и /student/course/ - для них есть специальные виджеты
    return (route.contains('/homework') && !route.startsWith('/student/course/')) ||
           route.contains('/users/') ||
           (route.contains('/course/') && !route.startsWith('/admin/course/') && !route.startsWith('/student/course/'));
  }

  Widget _buildBreadcrumbs(String route) {
    final parts = _getBreadcrumbParts(route);
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Кнопка назад
          IconButton(
            onPressed: () => _navigateBack(route),
            icon: const Icon(Icons.arrow_back),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          // Breadcrumb trail
          Expanded(
            child: Row(
              children: parts.map((part) {
                final isLast = part == parts.last;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (part != parts.first) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      part,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                        color: isLast ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getBreadcrumbParts(String route) {
    final parts = <String>[];
    
    if (route.contains('/student/homework')) {
      parts.add('Учеба');
      parts.add('Домашние задания');
    } else if (route.contains('/admin/users/')) {
      parts.add('Пользователи');
      parts.add('Профиль');
    } else if (route.startsWith('/admin') && route.contains('/course/')) {
      parts.add('Курсы');
      if (route.contains('/lesson/') && route.contains('/edit')) {
        parts.add('Редактирование курса');
        parts.add('Редактирование урока');
      } else if (route.contains('/edit')) {
        parts.add('Редактирование курса');
      }
    }
    
    return parts;
  }

  void _navigateBack(String route) {
    // Логика навигации назад в рамках текущего таба
    if (route.contains('/student/homework')) {
      // Из домашек возвращаемся к учебе
      context.go('/student?tab=1');
    } else if (route.contains('/admin/users/')) {
      // Из профиля пользователя к списку пользователей
      context.go('/admin?tab=1');
    } else {
      // Дефолтное поведение - просто назад
      if (context.canPop()) {
        context.pop();
      }
    }
  }
} 