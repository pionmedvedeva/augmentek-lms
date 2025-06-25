import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/student/presentation/screens/student_dashboard.dart';
import 'package:miniapp/features/course/presentation/screens/course_list_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return user.when(
      data: (appUser) {
        if (appUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Augmentek'),
            actions: [
              // Аватар пользователя с прямым кликом
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showUserProfile(context, appUser),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: appUser.photoUrl != null && appUser.photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              appUser.photoUrl!,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  appUser.firstName.isNotEmpty 
                                      ? appUser.firstName[0].toUpperCase() 
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            appUser.firstName.isNotEmpty 
                                ? appUser.firstName[0].toUpperCase() 
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 4 : 0,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 8,
              items: tabs,
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка: $error'),
            ],
          ),
        ),
      ),
    );
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
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: appUser.photoUrl != null && appUser.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            appUser.photoUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                appUser.firstName.isNotEmpty 
                                    ? appUser.firstName[0].toUpperCase() 
                                    : 'U',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                          ),
                        )
                      : Text(
                          appUser.firstName.isNotEmpty 
                              ? appUser.firstName[0].toUpperCase() 
                              : 'U',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
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
                  Text(
                    'Telegram ID: ${appUser.id}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
} 