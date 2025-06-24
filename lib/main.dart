import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:miniapp/core/config/firebase_options.dart';
import 'package:miniapp/core/theme/app_theme.dart';
import 'package:miniapp/core/di/di.dart';
import 'package:miniapp/features/auth/providers/auth_provider.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/home/presentation/screens/home_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/user_list_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/user_profile_screen.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/course/presentation/screens/course_list_screen.dart';
import 'package:miniapp/shared/widgets/error_widget.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Telegram WebApp and expand to full screen
    _initializeTelegramWebApp();
    
    // Initialize dependencies
    await initializeDependencies();
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stack) {
    print('Error initializing app: $e');
    print('Stack trace: $stack');
    // Still run the app even if initialization fails
    runApp(const ProviderScope(child: MyApp()));
  }
}

void _initializeTelegramWebApp() {
  try {
    final webApp = TelegramWebApp.instance;
    
    // Запрашиваем fullsize режим (не fullscreen!)
    webApp.expand();
    
    // Настраиваем тему
    webApp.setHeaderColor(const Color(0xFF673AB7)); // Deep Purple
    webApp.setBackgroundColor(const Color(0xFFFFFFFF)); // White
    
    // Показываем, что приложение готово
    webApp.ready();
    
    print('Telegram WebApp initialized in fullsize mode');
    print('Viewport height: ${webApp.viewportHeight}');
  } catch (e) {
    print('Error initializing Telegram WebApp: $e');
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const UserListScreen(),
    ),
    GoRoute(
      path: '/admin/users/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/admin/courses',
      builder: (context, state) => const CourseListScreen(),
    ),
  ],
);

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasTriggeredSignIn = false;

  @override
  void initState() {
    super.initState();
    // Trigger sign in once when widget is created with a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTriggeredSignIn) {
        _hasTriggeredSignIn = true;
        ref.read(debugLogsProvider.notifier).addLog('🔧 App initialized, starting auth...');
        
        // Дополнительно расширяем интерфейс
        _expandTelegramWebApp();
        
        // Add a small delay to ensure Firebase is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.read(authProvider.notifier).signInAutomatically();
        });
      }
    });
  }

  void _expandTelegramWebApp() {
    try {
      final webApp = TelegramWebApp.instance;
      
      // Однократный запрос fullsize режима
      webApp.expand();
      
      ref.read(debugLogsProvider.notifier).addLog('📱 Requested fullsize mode');
      ref.read(debugLogsProvider.notifier).addLog('📏 Viewport height: ${webApp.viewportHeight}px');
    } catch (e) {
      ref.read(debugLogsProvider.notifier).addLog('❌ Error requesting fullsize: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userState = ref.watch(userProvider);

    // Определяем, показывать ли debug логи (только в Telegram)
    final webApp = TelegramWebApp.instance;
    final isInTelegram = webApp.initDataUnsafe?.user != null;

    Widget mainContent;

    // Show loading while auth state is loading
    if (authState is AsyncLoading) {
      mainContent = const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading authentication...'),
            ],
          ),
        ),
      );
    }
    // Show error if auth state has error
    else if (authState is AsyncError) {
      mainContent = AppErrorWidget(
        error: authState.error.toString(),
        onRetry: () => ref.read(authProvider.notifier).signInAutomatically(),
      );
    }
    else {
      // Check if user is authenticated in Firebase
      final firebaseUser = authState.valueOrNull;
      if (firebaseUser == null) {
        // User is not authenticated, show loading while trying to sign in
        mainContent = const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Signing in...'),
              ],
            ),
          ),
        );
      } else {
        // User is authenticated, now check user data
        mainContent = userState.when(
          data: (user) {
            if (user != null) {
              return const HomeScreen();
            } else {
              // User authenticated but no user data, show loading
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading user data...'),
                    ],
                  ),
                ),
              );
            }
          },
          loading: () => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user data...'),
                ],
              ),
            ),
          ),
          error: (error, stack) => AppErrorWidget(
            error: error.toString(),
            onRetry: () => ref.read(authProvider.notifier).signInAutomatically(),
          ),
        );
      }
    }

    // Wrap with debug screen if in Telegram
    if (isInTelegram) {
      return DebugLogScreen(
        child: mainContent,
        showLogs: true,
      );
    } else {
      return mainContent;
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LMS Mini App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
