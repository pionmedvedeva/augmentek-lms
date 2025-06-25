import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';
import '../utils/remote_logger.dart';

/// Централизованная обработка ошибок для Telegram WebApp.
/// 
/// Особенности:
/// - Логирует все ошибки в визуальную панель отладки
/// - Отправляет критичные ошибки на сервер
/// - Показывает пользовательские уведомления для важных ошибок
/// - Адаптирован для работы без доступа к консоли браузера
class TelegramErrorHandler {
  /// Обработать ошибку с полным контекстом
  static void handleError(
    WidgetRef ref,
    String operation,
    dynamic error, {
    bool showToUser = false,
    BuildContext? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    // Логируем в визуальную панель
    AppLogger.error('$operation failed: $error', ref);
    
    // Отправляем критичные ошибки на сервер
    if (_isCritical(error)) {
      RemoteLogger.sendCriticalError(
        error: error.toString(),
        stackTrace: stackTrace?.toString(),
        operation: operation,
        userId: _getUserId(ref),
        additionalData: additionalData,
      );
    }
    
    // Показываем пользователю если нужно
    if (showToUser && context != null) {
      _showUserFriendlyError(context, _getUserMessage(error));
    }
  }
  
  /// Быстрая обработка ошибки без дополнительного контекста
  static void handleSimpleError(
    WidgetRef ref,
    String operation,
    dynamic error,
  ) {
    handleError(ref, operation, error);
  }
  
  /// Обработка сетевых ошибок
  static void handleNetworkError(
    WidgetRef ref,
    String operation,
    dynamic error, {
    BuildContext? context,
    bool showToUser = true,
  }) {
    AppLogger.warning('Network error in $operation: $error', ref);
    
    if (showToUser && context != null) {
      _showUserFriendlyError(
        context, 
        'Проблемы с подключением к интернету. Проверьте соединение.',
        icon: Icons.wifi_off,
        color: Colors.orange,
      );
    }
  }
  
  /// Обработка ошибок аутентификации
  static void handleAuthError(
    WidgetRef ref,
    String operation,
    dynamic error, {
    BuildContext? context,
    bool showToUser = true,
  }) {
    AppLogger.error('Auth error in $operation: $error', ref);
    
    // Отправляем на сервер - проблемы с аутентификацией критичны
    RemoteLogger.sendCriticalError(
      error: error.toString(),
      operation: operation,
      userId: _getUserId(ref),
      additionalData: {'error_type': 'authentication'},
    );
    
    if (showToUser && context != null) {
      _showUserFriendlyError(
        context,
        'Ошибка входа в систему. Попробуйте перезапустить приложение.',
        icon: Icons.lock_outline,
        color: Colors.red,
      );
    }
  }
  
  /// Обработка ошибок валидации
  static void handleValidationError(
    WidgetRef ref,
    String operation,
    String validationMessage, {
    BuildContext? context,
    bool showToUser = true,
  }) {
    AppLogger.warning('Validation error in $operation: $validationMessage', ref);
    
    if (showToUser && context != null) {
      _showUserFriendlyError(
        context,
        validationMessage,
        icon: Icons.error_outline,
        color: Colors.amber,
      );
    }
  }
  
  /// Показать пользователю дружественное сообщение об ошибке
  static void _showUserFriendlyError(
    BuildContext context, 
    String message, {
    IconData? icon,
    Color? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? Icons.error, 
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  /// Определить, является ли ошибка критичной
  static bool _isCritical(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Критичные ошибки - проблемы с безопасностью, целостностью данных
    final criticalPatterns = [
      'firebase',
      'authentication',
      'permission',
      'unauthorized',
      'network',
      'timeout',
      'connection',
      'database',
      'storage',
    ];
    
    return criticalPatterns.any((pattern) => errorString.contains(pattern));
  }
  
  /// Получить пользовательское сообщение для ошибки
  static String _getUserMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Переводим техничские ошибки в понятные пользователю сообщения
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Проблемы с подключением к интернету';
    }
    
    if (errorString.contains('timeout')) {
      return 'Превышено время ожидания. Попробуйте позже';
    }
    
    if (errorString.contains('permission') || errorString.contains('unauthorized')) {
      return 'Недостаточно прав доступа';
    }
    
    if (errorString.contains('not found')) {
      return 'Запрашиваемые данные не найдены';
    }
    
    if (errorString.contains('firebase') || errorString.contains('database')) {
      return 'Проблемы с сервером. Попробуйте позже';
    }
    
    // Общее сообщение для неизвестных ошибок
    return 'Что-то пошло не так. Попробуйте еще раз';
  }
  
  /// Получить ID пользователя для логирования
  static String _getUserId(WidgetRef ref) {
    try {
      // Пытаемся получить ID пользователя из провайдера
      // Это будет зависеть от структуры вашего приложения
      // final user = ref.read(userProvider).value;
      // return user?.id.toString() ?? 'unknown';
      return 'telegram_user'; // Временное значение
    } catch (e) {
      return 'unknown';
    }
  }
  
  /// Обёртка для async операций с автоматической обработкой ошибок
  static Future<T?> wrapAsyncOperation<T>(
    WidgetRef ref,
    String operationName,
    Future<T> Function() operation, {
    BuildContext? context,
    bool showErrorToUser = false,
    T? defaultValue,
  }) async {
    try {
      AppLogger.info('Starting $operationName', ref);
      final result = await operation();
      AppLogger.info('Completed $operationName successfully', ref);
      return result;
    } catch (error, stackTrace) {
      handleError(
        ref,
        operationName,
        error,
        showToUser: showErrorToUser,
        context: context,
        stackTrace: stackTrace,
      );
      return defaultValue;
    }
  }
  
  /// Обёртка для sync операций с автоматической обработкой ошибок
  static T? wrapSyncOperation<T>(
    WidgetRef ref,
    String operationName,
    T Function() operation, {
    BuildContext? context,
    bool showErrorToUser = false,
    T? defaultValue,
  }) {
    try {
      AppLogger.debug('Executing $operationName', ref);
      return operation();
    } catch (error, stackTrace) {
      handleError(
        ref,
        operationName,
        error,
        showToUser: showErrorToUser,
        context: context,
        stackTrace: stackTrace,
      );
      return defaultValue;
    }
  }
}

/// Типы ошибок для более точной категоризации
enum ErrorType {
  network,
  authentication,
  validation,
  permission,
  server,
  unknown,
}

/// Результат операции с информацией об ошибке
class OperationResult<T> {
  final T? data;
  final String? error;
  final ErrorType? errorType;
  final bool isSuccess;
  
  const OperationResult._({
    this.data,
    this.error,
    this.errorType,
    required this.isSuccess,
  });
  
  factory OperationResult.success(T data) {
    return OperationResult._(data: data, isSuccess: true);
  }
  
  factory OperationResult.error(String error, [ErrorType? errorType]) {
    return OperationResult._(
      error: error,
      errorType: errorType ?? ErrorType.unknown,
      isSuccess: false,
    );
  }
  
  /// Выполнить действие при успехе
  OperationResult<T> onSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
    return this;
  }
  
  /// Выполнить действие при ошибке
  OperationResult<T> onError(void Function(String error, ErrorType? type) action) {
    if (!isSuccess && error != null) {
      action(error!, errorType);
    }
    return this;
  }
} 