import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/telegram_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRouter {
  static GoRouter createRouter(ProviderRef ref) {
    final authState = ref.watch(authProvider);
    final telegramState = ref.watch(telegramUserProvider);

    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Show loading screen while initializing
        if (authState.isLoading) {
          return '/loading';
        }

        // Handle authentication errors
        if (authState.hasError) {
          return '/error';
        }

        // Redirect to login if not authenticated
        final isAuthenticated = authState.value != null;
        final isLoginRoute = state.matchedLocation == '/login';
        
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/loading',
          builder: (context, state) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: '/error',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Text('Error: ${authState.error}'),
            ),
          ),
        ),
      ],
    );
  }
}

// Placeholder screens - these will be implemented in separate files
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('An error occurred'),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Screen'),
      ),
    );
  }
}

class LMSTabsScreen extends StatelessWidget {
  final Widget child;

  const LMSTabsScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/courses');
              break;
            case 2:
              context.go('/favorites');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen'),
    );
  }
}

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Courses Screen'),
    );
  }
}

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Course Details Screen: $courseId'),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Favorites Screen'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen'),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Screen'),
    );
  }
} 