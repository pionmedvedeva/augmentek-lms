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
import 'package:miniapp/main.dart' show AuthWrapper;

/// Основной Shell с универсальной навигацией согласно UI Guidelines
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showAvatar;

  const AppShell({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.showAvatar = true,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> 
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final user = ref.watch(userProvider);

    // Определяем параметры для TabController
    TabController? tabController;
    int? tabLength;
    int? initialTab;
    if (user is AsyncData && user.value != null) {
      if (_shouldShowStudentTabs(currentRoute)) {
        tabLength = 2;
        final uri = Uri.parse(currentRoute);
        final tabParam = uri.queryParameters['tab'];
        initialTab = tabParam != null ? int.tryParse(tabParam) ?? 1 : 1;
      } else if (_shouldShowAdminTabs(currentRoute)) {
        tabLength = 3;
        final uri = Uri.parse(currentRoute);
        final tabParam = uri.queryParameters['tab'];
        initialTab = tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;
      }
      if (tabLength != null && initialTab != null) {
        tabController = TabController(
          length: tabLength,
          vsync: this,
          initialIndex: initialTab,
        );
      }
    }

    // Определяем индекс нижней навигации
    int currentIndex = 0;
    if (currentRoute.startsWith('/admin')) {
      currentIndex = 0;
    } else if (currentRoute.startsWith('/student') || currentRoute.startsWith('/course') || currentRoute.startsWith('/home')) {
      currentIndex = 1;
    }

    return user.when(
      data: (appUser) {
        if (appUser == null) {
          // Показываем AuthWrapper для инициации аутентификации
          return const AuthWrapper();
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
              if (_shouldShowStudentTabs(currentRoute) && tabController != null)
                Container(
                  color: const Color(0xFF4A90B8), // primaryBlue
                  child: TabBar(
                    controller: tabController,
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
              
              // Админский TabBar (Level 1 navigation)
              if (_shouldShowAdminTabs(currentRoute) && tabController != null)
                Container(
                  color: const Color(0xFF4A90B8), // primaryBlue
                  child: TabBar(
                    controller: tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    onTap: (index) => _onAdminTabChanged(index),
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
              else if (_shouldShowBreadcrumbs(currentRoute))
                _buildBreadcrumbs(currentRoute),

              // Основной контент
              Expanded(child: widget.child),
            ],
          ),
          bottomNavigationBar: (widget.showBottomNav && appUser.isAdmin) ? Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 0,
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
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

  bool _shouldShowStudentTabs(String route) {
    // Показываем TabBar только на основных студенческих экранах (не во вложенных)
    return route == '/student' ||
           (route.startsWith('/student') && 
            !route.contains('/course/') &&
            !route.contains('/homework'));
  }

  bool _shouldShowAdminTabs(String route) {
    // Показываем админские табы на всех admin экранах, включая с query параметрами
    return route.startsWith('/admin') && !route.startsWith('/admin/course/');
  }

  bool _shouldShowBreadcrumbs(String route) {
    // Показываем breadcrumbs для вложенных экранов (Level 2+)
    return route.contains('/course/') ||
           route.contains('/lesson/') ||
           route.contains('/homework') ||
           route.contains('/users/') ||
           (route.startsWith('/admin') && route.contains('/course/'));
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
    
    if (route.contains('/student/course/')) {
      parts.add('Учеба');
      parts.add('Курс');
      
      if (route.contains('/lesson/')) {
        parts.add('Урок');
      }
    } else if (route.contains('/course/') && !route.startsWith('/admin')) {
      // Старый формат студенческих маршрутов
      parts.add('Учеба');
      parts.add('Курс');
      
      if (route.contains('/lesson/')) {
        parts.add('Урок');
      }
    } else if (route.contains('/student/homework')) {
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
    if (route.contains('/lesson/')) {
      // Из урока возвращаемся к курсу
      final courseId = RegExp(r'/course/([^/]+)').firstMatch(route)?.group(1);
      if (courseId != null) {
        if (route.startsWith('/admin')) {
          // Админский урок -> админский курс
          context.go('/admin/course/$courseId/edit');
        } else {
          // Студенческий урок -> студенческий курс
          context.go('/student/course/$courseId');
        }
      }
    } else if (route.contains('/course/')) {
      // Из курса возвращаемся к списку
      if (route.startsWith('/admin')) {
        // Админский курс -> список курсов
        context.go('/admin');
      } else {
        // Студенческий курс -> учеба
        context.go('/student?tab=1');
      }
    } else if (route.contains('/student/homework')) {
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

  void _onStudentTabChanged(int index) {
    // Навигация между студенческими табами
    context.go('/student?tab=$index');
  }

  void _onAdminTabChanged(int index) {
    // Навигация между админскими табами
    context.go('/admin?tab=$index');
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