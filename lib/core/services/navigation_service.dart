import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';

/// NavigationService отвечает за логику роутинга и навигации
class NavigationService {
  static const NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  const NavigationService._internal();

  /// Навигация по студенческим табам
  void navigateToStudentTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/student?tab=0');
        break;
      case 1:
        context.go('/student?tab=1');
        break;
    }
  }

  /// Навигация по админским табам
  void navigateToAdminTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/admin?tab=0');
        break;
      case 1:
        context.go('/admin?tab=1');
        break;
      case 2:
        context.go('/admin?tab=2');
        break;
    }
  }

  /// Навигация по нижним табам (для админов)
  void navigateToBottomTab(BuildContext context, int index, AppUser user) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/student');
        break;
    }
  }

  /// Навигация к курсу
  void navigateToCourse(BuildContext context, String courseId, {Map<String, dynamic>? extra}) {
    if (extra != null) {
      context.push('/course/$courseId', extra: extra);
    } else {
      context.go('/course/$courseId');
    }
  }

  /// Навигация к уроку
  void navigateToLesson(BuildContext context, String courseId, String lessonId) {
    context.go('/student/course/$courseId/lesson/$lessonId');
  }

  /// Навигация к редактированию урока (для админов)
  void navigateToLessonEdit(BuildContext context, String courseId, String lessonId) {
    context.go('/admin/course/$courseId/lesson/$lessonId/edit');
  }

  /// Навигация к редактированию курса (для админов)
  void navigateToCourseEdit(BuildContext context, String courseId) {
    context.go('/admin/course/$courseId/edit');
  }

  /// Навигация к домашним заданиям
  void navigateToHomework(BuildContext context) {
    context.go('/student/homework');
  }

  /// Навигация к списку пользователей (для админов)
  void navigateToUserList(BuildContext context) {
    context.go('/admin?tab=1');
  }

  /// Навигация к профилю пользователя (для админов)
  void navigateToUserProfile(BuildContext context, int userId) {
    context.push('/admin/user/$userId');
  }

  /// Навигация к обзору домашних заданий (для админов)
  void navigateToHomeworkReview(BuildContext context) {
    context.go('/admin?tab=2');
  }

  /// Показать профиль пользователя в диалоге
  void showUserProfile(BuildContext context, AppUser user) {
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
                  user: user,
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
                        '${user.firstName} ${user.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.username?.isNotEmpty == true)
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      if (user.isAdmin)
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
                      'ID: ${user.id}',
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

  /// Показать debug логи
  void showDebugLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DebugLogScreen(
        child: SizedBox.shrink(),
        showLogs: true,
      ),
    );
  }

  /// Определяет, нужно ли показывать студенческие табы
  bool shouldShowStudentTabs(String route) {
    return route.startsWith('/student') || route.startsWith('/home');
  }

  /// Определяет, нужно ли показывать админские табы
  bool shouldShowAdminTabs(String route) {
    return route.startsWith('/admin') && !route.startsWith('/admin/course/');
  }

  /// Определяет, нужно ли показывать breadcrumbs
  bool shouldShowBreadcrumbs(String route) {
    return route.startsWith('/course/') || route.startsWith('/student/course/');
  }

  /// Определяет индекс текущего нижнего таба
  int getCurrentBottomTabIndex(String route) {
    if (route.startsWith('/admin')) {
      return 0;
    } else if (route.startsWith('/student') || route.startsWith('/course') || route.startsWith('/home')) {
      return 1;
    }
    return 0;
  }

  /// Получает параметры для TabController
  TabControllerParams? getTabControllerParams(String route) {
    if (shouldShowStudentTabs(route)) {
      final uri = Uri.parse(route);
      final tabParam = uri.queryParameters['tab'];
      final initialTab = tabParam != null ? int.tryParse(tabParam) ?? 1 : 1;
      return TabControllerParams(length: 2, initialIndex: initialTab);
    } else if (shouldShowAdminTabs(route)) {
      final uri = Uri.parse(route);
      final tabParam = uri.queryParameters['tab'];
      final initialTab = tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;
      return TabControllerParams(length: 3, initialIndex: initialTab);
    }
    return null;
  }

  /// Создаёт breadcrumbs для маршрута
  Widget buildBreadcrumbs(String route) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.home, size: 16),
          const SizedBox(width: 8),
          Text(
            'Breadcrumbs for $route',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Создаёт breadcrumbs для админских курсов
  Widget buildAdminCourseBreadcrumbs(String route) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, size: 16),
          const SizedBox(width: 8),
          Text(
            'Admin Course: $route',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Параметры для TabController
class TabControllerParams {
  final int length;
  final int initialIndex;

  const TabControllerParams({
    required this.length,
    required this.initialIndex,
  });
} 