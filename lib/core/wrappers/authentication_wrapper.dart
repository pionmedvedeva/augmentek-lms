import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/auth/providers/auth_provider.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/shared/widgets/error_widget.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:miniapp/shared/widgets/app_layout.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/core/utils/app_logger.dart';
import 'package:go_router/go_router.dart';

/// AuthenticationWrapper отвечает только за инициализацию приложения и аутентификацию пользователя
class AuthenticationWrapper extends ConsumerStatefulWidget {
  final Widget? child;
  
  const AuthenticationWrapper({super.key, this.child});

  @override
  ConsumerState<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends ConsumerState<AuthenticationWrapper> {
  bool _hasTriggeredSignIn = false;

  @override
  void initState() {
    super.initState();
    // Запускаем инициализацию при первом рендере
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTriggeredSignIn) {
        _hasTriggeredSignIn = true;
        ref.read(debugLogsProvider.notifier).addLog('🔧 App initialized, starting auth...');
        
        // Расширяем интерфейс Telegram WebApp
        _expandTelegramWebApp();
        
        // Запускаем автоматическую аутентификацию с небольшой задержкой
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

    // Определяем, показывать ли debug логи
    final webApp = TelegramWebApp.instance;
    final isInTelegram = webApp.initDataUnsafe?.user != null;
    
    // В debug режиме всегда показываем debug панель, в релизе - только в Telegram
    bool shouldShowDebugPanel;
    try {
      shouldShowDebugPanel = AppLogger.isDebugMode || isInTelegram;
    } catch (e) {
      // Fallback если возникла ошибка с TelegramWebApp
      shouldShowDebugPanel = AppLogger.isDebugMode;
    }

    Widget mainContent;

    // Показываем загрузку пока идёт аутентификация
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
    // Показываем ошибку аутентификации
    else if (authState is AsyncError) {
      mainContent = AppErrorWidget(
        error: authState.error.toString(),
        onRetry: () => ref.read(authProvider.notifier).signInAutomatically(),
      );
    }
    else {
      // Проверяем, аутентифицирован ли пользователь в Firebase
      final firebaseUser = authState.valueOrNull;
      if (firebaseUser == null) {
        // Пользователь не аутентифицирован, показываем загрузку
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
        // Пользователь аутентифицирован, проверяем данные пользователя
        mainContent = userState.when(
          data: (user) {
            if (user != null) {
              // Если child не передан, делаем автоматический редирект по роли
              if (widget.child == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final router = GoRouter.of(context);
                  final isAdmin = user.isAdmin;
                  final target = isAdmin ? '/admin?tab=0' : '/student?tab=1';
                  final currentLocation = GoRouterState.of(context).uri.toString();
                  if (currentLocation != target) {
                    router.go(target);
                  }
                });
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Перенаправление...'),
                      ],
                    ),
                  ),
                );
              }
              // Пользователь загружен, child есть
              return AppLayout(user: user, child: widget.child!);
            } else {
              // Пользователь аутентифицирован, но данных нет - показываем загрузку
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

    // Оборачиваем в debug screen если нужно
    if (shouldShowDebugPanel) {
      return DebugLogScreen(
        child: mainContent,
        showLogs: true,
      );
    } else {
      return mainContent;
    }
  }
} 