import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/student/presentation/screens/student_dashboard.dart';
import 'package:miniapp/features/course/presentation/screens/course_list_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

/// Основной Shell с постоянным нижним навбаром
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;
  final bool showBottomNav;
  final bool showAvatar;

  const MainShell({
    super.key,
    required this.child,
    required this.currentRoute,
    this.showBottomNav = true,
    this.showAvatar = true,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    // Определяем индекс на основе текущего маршрута
    switch (widget.currentRoute) {
      case '/home':
      case '/student':
      case '/student/courses':
      case '/student/homework':
        _currentIndex = 0;
        break;
      case '/courses':
      case '/admin/courses':
        _currentIndex = 1;
        break;
      case '/admin':
      case '/admin/users':
      case '/admin/homework':
        _currentIndex = 2;
        break;
      default:
        _currentIndex = 0;
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

        // Определяем список экранов в зависимости от роли пользователя
        final screens = [
          const StudentDashboard(),
          const CourseListScreen(),
          if (appUser.isAdmin) const AdminDashboard(),
        ];

        // Определяем список табов
        final tabs = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'За парту',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'В коридор',
          ),
          if (appUser.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Учительская',
            ),
        ];

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
          ) : null,
          body: widget.child,
          bottomNavigationBar: widget.showBottomNav ? Container(
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
              items: tabs,
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

  void _navigateToTab(int index, appUser) {
    switch (index) {
      case 0:
        // Первый таб - всегда студенческая панель или домашняя страница
        context.go('/home');
        break;
      case 1:
        // Второй таб - курсы
        context.go('/courses');
        break;
      case 2:
        // Третий таб - только для админов
        if (appUser.isAdmin) {
          context.go('/admin');
        }
        break;
    }
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