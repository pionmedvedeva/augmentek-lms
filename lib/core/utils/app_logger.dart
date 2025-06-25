import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../shared/widgets/debug_log_screen.dart';

/// Уровни логирования для Telegram WebApp
enum LogLevel { debug, info, warning, error }

/// Централизованная система логирования, адаптированная для Telegram WebApp.
/// 
/// Особенности:
/// - Логи отображаются визуально в DebugLogScreen (нет доступа к консоли браузера)
/// - Критичные ошибки отправляются на сервер
/// - Поддержка цветовых эмодзи для быстрой идентификации типа лога
/// - Автоматическое сохранение в локальное хранилище для экспорта
class AppLogger {
  static ProviderContainer? _globalContainer;
  static final List<String> _localLogs = [];
  
  /// Инициализация логгера с глобальным контейнером
  static void initialize(ProviderContainer container) {
    _globalContainer = container;
  }
  
  /// Debug логи - для разработки и отладки
  static void debug(String message, [WidgetRef? ref]) {
    _log(LogLevel.debug, message, ref);
  }
  
  /// Информационные логи - общая информация о работе приложения
  static void info(String message, [WidgetRef? ref]) {
    _log(LogLevel.info, message, ref);
  }
  
  /// Предупреждения - потенциальные проблемы
  static void warning(String message, [WidgetRef? ref]) {
    _log(LogLevel.warning, message, ref);
  }
  
  /// Ошибки - критичные проблемы, требующие внимания
  static void error(String message, [WidgetRef? ref]) {
    _log(LogLevel.error, message, ref);
  }
  
  /// Основной метод логирования
  static void _log(LogLevel level, String message, WidgetRef? ref) {
    final timestamp = DateTime.now().toString().substring(11, 19); // HH:mm:ss
    final emoji = _getEmojiForLevel(level);
    final formattedMessage = '[$timestamp] $emoji $message';
    
    // Добавляем в визуальную панель (основной способ для Telegram WebApp)
    try {
      WidgetRef? effectiveRef = ref;
      ProviderContainer? container = _globalContainer;
      
      if (effectiveRef != null) {
        // Используем переданный ref - СИНХРОННО добавляем лог
        final debugLogsNotifier = effectiveRef.read(debugLogsProvider.notifier);
        debugLogsNotifier.addLog(formattedMessage);
      } else if (container != null) {
        // Используем глобальный container - СИНХРОННО добавляем лог
        final debugLogsNotifier = container.read(debugLogsProvider.notifier);
        debugLogsNotifier.addLog(formattedMessage);
      } else {
        // Fallback на локальное хранение
        _localLogs.add(formattedMessage);
      }
    } catch (e) {
      // Fallback на локальное хранение если провайдер недоступен
      _localLogs.add(formattedMessage);
      // НЕ выбрасываем исключение - это может сломать debug панель
    }
    
    // Сохраняем в локальное хранилище для персистентности
    _saveToLocalStorage(formattedMessage);
    
    // Для критичных ошибок - отправляем на сервер
    if (level == LogLevel.error) {
      _sendCriticalErrorToServer(message, ref);
    }
  }
  
  /// Получить эмодзи для уровня логирования
  static String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔧';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
  
  /// Сохранение в локальное хранилище
  static void _saveToLocalStorage(String logMessage) {
    try {
      SharedPreferences.getInstance().then((prefs) {
        final existingLogs = prefs.getStringList('app_logs') ?? [];
        existingLogs.add(logMessage);
        
        // Ограничиваем размер логов (последние 1000 записей)
        if (existingLogs.length > 1000) {
          existingLogs.removeRange(0, existingLogs.length - 1000);
        }
        
        prefs.setStringList('app_logs', existingLogs);
      });
    } catch (e) {
      // Игнорируем ошибки сохранения в localStorage
    }
  }
  
  /// Отправка критичных ошибок на сервер
  static void _sendCriticalErrorToServer(String message, WidgetRef? ref) {
    // Это будет реализовано в RemoteLogger
    // Пока просто отмечаем как критичную ошибку в логах
    try {
      if (ref != null) {
        ref.read(debugLogsProvider.notifier).addLog('🚨 CRITICAL ERROR LOGGED: $message');
      }
    } catch (e) {
      // Ignore if provider is not available
    }
  }
  
  /// Получить все логи для экспорта
  static Future<List<String>> getAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLogs = prefs.getStringList('app_logs') ?? [];
      
      // Объединяем сохраненные и текущие локальные логи
      final allLogs = [...storedLogs, ..._localLogs];
      return allLogs;
    } catch (e) {
      return _localLogs;
    }
  }
  
  /// Очистить все логи
  static Future<void> clearAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_logs');
      _localLogs.clear();
    } catch (e) {
      _localLogs.clear();
    }
  }
  
  /// Экспорт логов в JSON формате
  static Future<String> exportLogsAsJson() async {
    final logs = await getAllLogs();
    return jsonEncode({
      'app': 'Augmentek LMS',
      'platform': 'telegram_webapp',
      'exported_at': DateTime.now().toIso8601String(),
      'logs_count': logs.length,
      'logs': logs,
    });
  }
}

/// Провайдер для отладочных логов уже определен в shared/widgets/debug_log_screen.dart
/// Импортируем его оттуда для использования в AppLogger 