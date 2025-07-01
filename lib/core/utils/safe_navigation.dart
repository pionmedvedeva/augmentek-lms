import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:miniapp/core/utils/notification_service.dart';

/// Сервис для безопасной навигации
/// Предотвращает зависание приложения при нажатии "назад" с deep link экранов
class SafeNavigation {
  
  /// Безопасная навигация "назад"
  /// Если невозможно вернуться назад - направляет на соответствующий главный экран
  static Future<void> safeGoBack(BuildContext context, WidgetRef ref) async {
    AppLogger.info('🧭 SafeNavigation: safeGoBack() called');
    AppLogger.info('🧭 Current route: ${GoRouterState.of(context).uri.toString()}');
    AppLogger.info('🧭 Can pop: ${context.canPop()}');
    
    // Показываем loading
    final loadingOverlay = NotificationService.showLoading('Переход...');
    
    try {
      // В Telegram WebApp всегда используем fallback навигацию для стабильности
      AppLogger.info('🧭 Using fallback navigation for Telegram WebApp');
      await _navigateToSafeScreen(context, ref);
    } catch (e) {
      AppLogger.error('❌ Error in safeGoBack: $e');
      NotificationService.showError('Ошибка навигации');
      // Критический fallback - всегда идем на главную
      if (context.mounted) {
        context.go('/');
      }
    } finally {
      // Убираем loading
      loadingOverlay.remove();
    }
  }
  
  /// Безопасная навигация "назад" для админских экранов
  static Future<void> safeGoBackForAdmin(BuildContext context, WidgetRef ref, String? courseId) async {
    AppLogger.info('🧭 SafeNavigation: safeGoBackForAdmin() called with courseId: $courseId');
    AppLogger.info('🧭 Current route: ${GoRouterState.of(context).uri.toString()}');
    
    // Показываем loading
    final loadingOverlay = NotificationService.showLoading('Переход...');
    
    try {
      // В Telegram WebApp используем прямую навигацию
      if (courseId != null) {
        AppLogger.info('🧭 Safe admin navigation: to course content $courseId');
        context.go('/admin/courses/$courseId');
      } else {
        AppLogger.info('🧭 Safe admin navigation: to course management');
        context.go('/admin/courses');
      }
      
      // Небольшая задержка для обработки навигации
      await Future.delayed(const Duration(milliseconds: 300));
      AppLogger.info('✅ Admin navigation completed');
      
    } catch (e) {
      AppLogger.error('❌ Error in safeGoBackForAdmin: $e');
      NotificationService.showError('Ошибка навигации');
      // Fallback на админский дашборд
      if (context.mounted) {
        context.go('/admin');
      }
    } finally {
      // Убираем loading
      loadingOverlay.remove();
    }
  }
  
  /// Безопасная навигация "назад" для студенческих экранов
  static Future<void> safeGoBackForStudent(BuildContext context, WidgetRef ref, String? courseId) async {
    AppLogger.info('🧭 SafeNavigation: safeGoBackForStudent() called with courseId: $courseId');
    AppLogger.info('🧭 Current route: ${GoRouterState.of(context).uri.toString()}');
    
    // Показываем loading
    final loadingOverlay = NotificationService.showLoading('Переход...');
    
    try {
      // В Telegram WebApp используем прямую навигацию
      if (courseId != null) {
        AppLogger.info('🧭 Safe student navigation: to student course $courseId');
        context.go('/student/course/$courseId');
      } else {
        AppLogger.info('🧭 Safe student navigation: to student dashboard');
        context.go('/student');
      }
      
      // Небольшая задержка для обработки навигации
      await Future.delayed(const Duration(milliseconds: 300));
      AppLogger.info('✅ Student navigation completed');
      
    } catch (e) {
      AppLogger.error('❌ Error in safeGoBackForStudent: $e');
      NotificationService.showError('Ошибка навигации');
      // Fallback на студенческий дашборд
      if (context.mounted) {
        context.go('/student');
      }
    } finally {
      // Убираем loading
      loadingOverlay.remove();
    }
  }
  
  /// Определяет куда направить пользователя в зависимости от роли
  static Future<void> _navigateToSafeScreen(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userProvider).value;
    
    AppLogger.info('🧭 _navigateToSafeScreen: user = ${user?.firstName ?? "null"}');
    AppLogger.info('🧭 _navigateToSafeScreen: isAdmin = ${user?.isAdmin ?? false}');
    
    if (user == null) {
      AppLogger.info('🧭 Safe navigation: user not found, going to home');
      context.go('/');
      return;
    }
    
    if (user.isAdmin) {
      AppLogger.info('🧭 Safe navigation: admin user, going to admin dashboard');
      context.go('/admin');
    } else {
      AppLogger.info('🧭 Safe navigation: student user, going to student dashboard');
      context.go('/student');
    }
    
    // Небольшая задержка для обработки навигации
    await Future.delayed(const Duration(milliseconds: 100));
    AppLogger.info('✅ Safe screen navigation completed');
  }
  
  /// Проверяет, находится ли пользователь на экране с нижней навигацией
  static bool isOnMainNavigationScreen(String currentRoute) {
    const mainRoutes = [
      '/',
      '/student',
      '/admin',
      '/courses',
    ];
    
    return mainRoutes.any((route) => currentRoute == route || currentRoute.startsWith('$route?'));
  }
  
  /// Получает правильный родительский маршрут для текущего экрана
  static String getParentRoute(String currentRoute, bool isAdmin) {
    AppLogger.info('🧭 getParentRoute: currentRoute = $currentRoute, isAdmin = $isAdmin');
    
    // Для уроков
    if (currentRoute.contains('/lesson/')) {
      // Извлекаем courseId из маршрута
      final courseIdMatch = RegExp(r'/course/([^/]+)').firstMatch(currentRoute);
      if (courseIdMatch != null) {
        final courseId = courseIdMatch.group(1);
        final parentRoute = isAdmin ? '/admin/courses/$courseId' : '/student/course/$courseId';
        AppLogger.info('🧭 getParentRoute: lesson route -> $parentRoute');
        return parentRoute;
      }
    }
    
    // Для курсов админа
    if (currentRoute.contains('/admin/courses/') && !currentRoute.contains('/lesson/')) {
      AppLogger.info('🧭 getParentRoute: admin course -> /admin/courses');
      return '/admin/courses';
    }
    
    // Для курсов студента
    if (currentRoute.contains('/student/course/') && !currentRoute.contains('/lesson/')) {
      AppLogger.info('🧭 getParentRoute: student course -> /student');
      return '/student';
    }
    
    // По умолчанию возвращаем соответствующий главный экран
    final defaultRoute = isAdmin ? '/admin' : '/student';
    AppLogger.info('🧭 getParentRoute: default -> $defaultRoute');
    return defaultRoute;
  }
  
  /// Кастомная кнопка "назад" для AppBar
  static Widget buildSafeBackButton(BuildContext context, WidgetRef ref, {String? courseId}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () async {
        AppLogger.info('🧭 Safe back button pressed');
        await safeGoBack(context, ref);
      },
      tooltip: 'Назад',
    );
  }
  
  /// Кастомная кнопка "назад" для админских экранов
  static Widget buildSafeAdminBackButton(BuildContext context, WidgetRef ref, {String? courseId}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () async {
        AppLogger.info('🧭 Safe admin back button pressed');
        await safeGoBackForAdmin(context, ref, courseId);
      },
      tooltip: 'Назад',
    );
  }
  
  /// Кастомная кнопка "назад" для студенческих экранов
  static Widget buildSafeStudentBackButton(BuildContext context, WidgetRef ref, {String? courseId}) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () async {
        AppLogger.info('🧭 Safe student back button pressed');
        await safeGoBackForStudent(context, ref, courseId);
      },
      tooltip: 'Назад',
    );
  }
  
  /// Экстренная навигация на главную страницу
  static void emergencyNavigateHome(BuildContext context) {
    AppLogger.error('🚨 Emergency navigation to home');
    try {
      context.go('/');
    } catch (e) {
      AppLogger.error('❌ Emergency navigation failed: $e');
    }
  }
} 