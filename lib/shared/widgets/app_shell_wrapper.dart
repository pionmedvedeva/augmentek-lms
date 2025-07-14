import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/core/services/navigation_service.dart';

/// AppShellWrapper - фиксированная оболочка с шапкой на уровне 0 навигации
/// Обеспечивает стабильность AppBar при переключении между режимами
class AppShellWrapper extends ConsumerWidget {
  final Widget child;
  final AppUser user;
  final bool showAvatar;
  final bool showBottomNav;

  const AppShellWrapper({
    super.key,
    required this.child,
    required this.user,
    this.showAvatar = true,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationService navigationService = NavigationService();

    return Scaffold(
      // Фиксированная шапка на уровне 0
      appBar: showAvatar ? AppBar(
        title: const Text('Augmentek'),
        backgroundColor: const Color(0xFF4A90B8), // primaryBlue
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Аватар пользователя
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => navigationService.showUserProfile(context, user),
              child: EnhancedUserAvatar(
                user: user,
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
      
      // Контент приложения (AppLayout без своего AppBar)
      body: child,
      
      // Нижняя навигация только для админов
      bottomNavigationBar: (showBottomNav && user.isAdmin) 
        ? _buildBottomNavigationBar(context, navigationService)
        : null,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, NavigationService navigationService) {
    // Определяем текущий индекс из URL
    final currentRoute = GoRouterState.of(context).uri.toString();
    final currentIndex = navigationService.getCurrentBottomTabIndex(currentRoute);
    
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 0,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => navigationService.navigateToBottomTab(context, index, user),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Учительская',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Студенческая',
          ),
        ],
      ),
    );
  }
} 