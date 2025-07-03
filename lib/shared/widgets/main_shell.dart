import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:collection/collection.dart';

/// Основной Shell с универсальной навигацией согласно UI Guidelines
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;
  final bool showBottomNav;
  final bool showAvatar;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
    this.showBottomNav = true,
    this.showAvatar = true,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> 
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
    _initTabController();
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
      _initTabController();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initTabController() {
    // Создаем TabController для студенческих экранов
    if (_shouldShowStudentTabs()) {
      _tabController?.dispose();
      _tabController = TabController(length: 2, vsync: this);
      
      // Определяем начальный таб на основе маршрута или параметра
      final uri = Uri.parse(widget.currentRoute);
      final tabParam = uri.queryParameters['tab'];
      int initialTab = 1; // По умолчанию "Учеба"
      
      if (tabParam != null) {
        initialTab = int.tryParse(tabParam) ?? 1;
      }
      
      _tabController!.index = initialTab;
    }
    // Создаем TabController для админских экранов
    else if (_shouldShowAdminTabs()) {
      _tabController?.dispose();
      _tabController = TabController(length: 3, vsync: this);
      
      // Определяем текущий таб на основе маршрута
      int initialTab = 0; // По умолчанию "Курсы"
      if (widget.currentRoute == '/admin/users') {
        initialTab = 1; // Пользователи
      } else if (widget.currentRoute == '/admin/homework') {
        initialTab = 2; // Домашки
      }
      
      _tabController!.index = initialTab;
    }
  }

  bool _shouldShowStudentTabs() {
    // Показываем TabBar только на основных студенческих экранах (не во вложенных)
    return widget.currentRoute == '/student' ||
           (widget.currentRoute.startsWith('/student') && 
            !widget.currentRoute.contains('/course/') &&
            !widget.currentRoute.contains('/homework'));
  }

  bool _shouldShowAdminTabs() {
    // Показываем админские табы на всех admin и admin/course экранах, включая вложенные (уроки, редактор и т.д.)
    return widget.currentRoute == '/admin' ||
           widget.currentRoute == '/admin/users' ||
           widget.currentRoute == '/admin/homework' ||
           widget.currentRoute.startsWith('/admin/course/');
  }

  void _updateCurrentIndex() {
    // Определяем индекс на основе текущего маршрута (только для админов)
    if (widget.currentRoute.startsWith('/admin')) {
      _currentIndex = 0; // Учительская
    } else if (widget.currentRoute.startsWith('/student') || widget.currentRoute.startsWith('/course') || widget.currentRoute.startsWith('/home')) {
      _currentIndex = 1; // Студенческая
    } else {
      _currentIndex = 0; // По умолчанию Учительская
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return user.when(
      data: (appUser) {
        if (appUser == null) {
          return widget.child;
        }

        // Определяем список табов только для админов (BottomNav)
        final List<BottomNavigationBarItem> bottomTabs = appUser.isAdmin 
          ? [
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Учительская',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Студенческая',
              ),
            ]
          : <BottomNavigationBarItem>[];

        // Определяем, показывать ли debug логи
        final webApp = TelegramWebApp.instance;
        final isInTelegram = webApp.initDataUnsafe?.user != null;
        final shouldShowDebugPanel = AppLogger.isDebugMode || isInTelegram;

        Widget mainContent = Scaffold(
          appBar: widget.showAvatar ? AppBar(
            title: const Text('Augmentek'),
            backgroundColor: const Color(0xFF4A90B8), // primaryBlue
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              // Аватар пользователя с прямым кликом
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showUserProfile(context, appUser),
                  child: EnhancedUserAvatar(
                    user: appUser,
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            // Убираем bottom из AppBar, TabBar будет отдельно
          ) : null,
          body: Column(
            children: [
              // Студенческий TabBar (Level 1 navigation)
              if (_shouldShowStudentTabs() && _tabController != null)
                Container(
                  color: const Color(0xFF4A90B8), // primaryBlue
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    onTap: (index) => _onStudentTabChanged(index),
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
              
              // Breadcrumbs (Level 2+ navigation)
              if (widget.currentRoute.startsWith('/admin/course/'))
                AdminCourseBreadcrumbs(currentRoute: widget.currentRoute)
              else if (_shouldShowBreadcrumbs())
                _buildBreadcrumbs(),

              // Основной контент
              Expanded(child: widget.child),
            ],
          ),
          bottomNavigationBar: (widget.showBottomNav && appUser.isAdmin) ? Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 0,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _navigateToTab(index, appUser);
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 8,
              items: bottomTabs,
            ),
          ) : null,
        );

        // Добавляем плавающую дебаг иконку
        if (shouldShowDebugPanel) {
          mainContent = Stack(
            children: [
              mainContent,
              // Плавающая дебаг иконка
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: () => _showDebugLogs(context),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.bug_report),
                ),
              ),
            ],
          );
        }

        return mainContent;
      },
      loading: () => widget.child,
      error: (error, stack) => widget.child,
    );
  }

  bool _shouldShowBreadcrumbs() {
    // Показываем breadcrumbs для вложенных экранов (Level 2+)
    return widget.currentRoute.contains('/course/') ||
           widget.currentRoute.contains('/lesson/') ||
           widget.currentRoute.contains('/homework') ||
           widget.currentRoute.contains('/users/') ||
           (widget.currentRoute.startsWith('/admin') && widget.currentRoute.contains('/course/'));
  }

  Widget _buildBreadcrumbs() {
    final parts = _getBreadcrumbParts();
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
            onPressed: () => _navigateBack(),
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

  List<String> _getBreadcrumbParts() {
    final parts = <String>[];
    
    if (widget.currentRoute.contains('/student/course/')) {
      parts.add('Учеба');
      parts.add('Курс');
      
      if (widget.currentRoute.contains('/lesson/')) {
        parts.add('Урок');
      }
    } else if (widget.currentRoute.contains('/course/') && !widget.currentRoute.startsWith('/admin')) {
      // Старый формат студенческих маршрутов
      parts.add('Учеба');
      parts.add('Курс');
      
      if (widget.currentRoute.contains('/lesson/')) {
        parts.add('Урок');
      }
    } else if (widget.currentRoute.contains('/student/homework')) {
      parts.add('Учеба');
      parts.add('Домашние задания');
    } else if (widget.currentRoute.contains('/admin/users/')) {
      parts.add('Пользователи');
      parts.add('Профиль');
    } else if (widget.currentRoute.startsWith('/admin') && widget.currentRoute.contains('/course/')) {
      parts.add('Курсы');
      if (widget.currentRoute.contains('/lesson/') && widget.currentRoute.contains('/edit')) {
        parts.add('Редактирование курса');
        parts.add('Редактирование урока');
      } else if (widget.currentRoute.contains('/edit')) {
        parts.add('Редактирование курса');
      }
    }
    
    return parts;
  }

  void _navigateBack() {
    // Логика навигации назад в рамках текущего таба
    if (widget.currentRoute.contains('/lesson/')) {
      // Из урока возвращаемся к курсу
      final courseId = RegExp(r'/course/([^/]+)').firstMatch(widget.currentRoute)?.group(1);
      if (courseId != null) {
        if (widget.currentRoute.startsWith('/admin')) {
          // Админский урок -> админский курс
          context.go('/admin/course/$courseId/edit');
        } else {
          // Студенческий урок -> студенческий курс
          context.go('/student/course/$courseId');
        }
      }
    } else if (widget.currentRoute.contains('/course/')) {
      // Из курса возвращаемся к списку
      if (widget.currentRoute.startsWith('/admin')) {
        // Админский курс -> список курсов
        context.go('/admin');
      } else {
        // Студенческий курс -> учеба
        context.go('/student?tab=1');
      }
    } else if (widget.currentRoute.contains('/student/homework')) {
      // Из домашек возвращаемся к учебе
      context.go('/student?tab=1');
    } else if (widget.currentRoute.contains('/admin/users/')) {
      // Из профиля пользователя к списку пользователей
      context.go('/admin/users');
    } else {
      // Дефолтное поведение - просто назад
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  void _onStudentTabChanged(int index) {
    // Навигация между студенческими табами
    context.go('/student?tab=$index');
  }

  void _onAdminTabChanged(int index) {
    // Навигация между админскими табами
    switch (index) {
      case 0:
        context.go('/admin'); // Курсы
        break;
      case 1:
        context.go('/admin/users'); // Пользователи
        break;
      case 2:
        context.go('/admin/homework'); // Домашки
        break;
    }
  }

  void _navigateToTab(int index, appUser) {
    if (appUser.isAdmin) {
      // Для админов: 2 таба в BottomNav
      switch (index) {
        case 0:
          context.go('/admin'); // Учительская
          break;
        case 1:
          context.go('/student?tab=1'); // Студенческая (Учеба)
          break;
      }
    }
    // Для студентов навигация только через верхний TabBar
  }

  void _showUserProfile(BuildContext context, appUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Профиль пользователя'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EnhancedUserAvatar(
                  user: appUser,
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appUser.firstName} ${appUser.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appUser.username?.isNotEmpty == true)
                        Text(
                          '@${appUser.username}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (appUser.isAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8A87C), // accentOrange
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Администратор',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: ${appUser.id}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showDebugLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DebugLogScreen(
        child: SizedBox.shrink(),
        showLogs: true,
      ),
    );
  }
}

class AdminCourseBreadcrumbs extends ConsumerWidget {
  final String currentRoute;
  const AdminCourseBreadcrumbs({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseId = _extractCourseId(currentRoute);
    final lessonId = _extractLessonId(currentRoute);
    final coursesAsync = ref.watch(courseProvider);
    final lessonAsync = lessonId != null ? ref.watch(lessonByIdProvider(lessonId)) : null;
    String? courseTitle;
    String? lessonTitle;
    Course? course;
    if (coursesAsync is AsyncData<List>) {
      final list = coursesAsync.value;
      if (list != null) {
        course = list.firstWhereOrNull((c) => c.id == courseId);
        courseTitle = course?.title;
      } else {
        course = null;
        courseTitle = null;
      }
    }
    if (lessonAsync != null && lessonAsync is AsyncData) {
      lessonTitle = lessonAsync.value?.title;
    }
    // Определяем маршрут для кнопки назад
    String? backRoute;
    if (lessonId != null) {
      // На экране урока — назад к курсу
      backRoute = '/admin/course/$courseId/edit';
    } else if (courseId != null) {
      // На экране курса — назад к списку курсов
      backRoute = '/admin';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (backRoute != null) {
                context.go(backRoute);
              }
            },
            icon: const Icon(Icons.arrow_back),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: courseId != null ? () => context.go('/admin/course/$courseId/edit') : null,
            child: Text(
              courseTitle ?? 'Курс',
              style: const TextStyle(
                color: Color(0xFF4A90B8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (lessonTitle != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                lessonTitle,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            const Spacer(),
          ],
        ],
      ),
    );
  }

  String? _extractCourseId(String route) {
    final match = RegExp(r'/course/([^/]+)').firstMatch(route);
    return match?.group(1);
  }
  String? _extractLessonId(String route) {
    final match = RegExp(r'/lesson/([^/]+)').firstMatch(route);
    return match?.group(1);
  }
} 