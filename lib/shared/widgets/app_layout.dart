import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/core/services/navigation_service.dart';

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

    // Получаем индекс нижней навигации через NavigationService
    final currentIndex = _navigationService.getCurrentBottomTabIndex(currentRoute);

    // Определяем список табов только для админов (BottomNav)
    final List<BottomNavigationBarItem> bottomTabs = widget.user.isAdmin 
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
              onTap: () => _navigationService.showUserProfile(context, widget.user),
              child: EnhancedUserAvatar(
                user: widget.user,
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
      body: Column(
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
            _navigationService.buildAdminCourseBreadcrumbs(currentRoute)
          else if (_navigationService.shouldShowBreadcrumbs(currentRoute))
            _navigationService.buildBreadcrumbs(currentRoute),

          // Основной контент
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: (widget.showBottomNav && widget.user.isAdmin) ? Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 0,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _navigationService.navigateToBottomTab(context, index, widget.user),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 8,
          items: bottomTabs,
        ),
      ) : null,
    );

    // Добавляем плавающую debug-кнопку
    if (shouldShowDebugPanel) {
      mainContent = Stack(
        children: [
          mainContent,
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => _navigationService.showDebugLogs(context),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.bug_report),
            ),
          ),
        ],
      );
    }

    return mainContent;
  }
} 