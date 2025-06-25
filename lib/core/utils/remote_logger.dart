import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Система удаленного логирования для критичных ошибок в Telegram WebApp.
/// 
/// Отправляет важные ошибки на сервер для мониторинга и анализа.
/// Использует Firebase Functions как основной канал и Firestore как fallback.
class RemoteLogger {
  static bool _isInitialized = false;
  static final List<Map<String, dynamic>> _pendingLogs = [];
  
  /// Инициализация удаленного логгера
  static void initialize() {
    if (_isInitialized) return;
    
    _isInitialized = true;
    
    // Отправляем накопленные логи при инициализации
    _flushPendingLogs();
    
    if (kDebugMode) {
      debugPrint('RemoteLogger initialized');
    }
  }
  
  /// Отправить критичную ошибку на сервер
  static Future<void> sendCriticalError({
    required String error,
    String? stackTrace,
    required String userId,
    required String operation,
    Map<String, dynamic>? additionalData,
  }) async {
    final logData = {
      'error': error,
      'stackTrace': stackTrace,
      'userId': userId,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
      'version': '1.0.0',
      'severity': 'critical',
      'additionalData': additionalData ?? {},
    };
    
    if (!_isInitialized) {
      // Сохраняем в очереди до инициализации
      _pendingLogs.add(logData);
      return;
    }
    
    await _sendLog(logData);
  }
  
  /// Отправить предупреждение на сервер
  static Future<void> sendWarning({
    required String message,
    required String userId,
    required String operation,
    Map<String, dynamic>? additionalData,
  }) async {
    final logData = {
      'message': message,
      'userId': userId,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
      'version': '1.0.0',
      'severity': 'warning',
      'additionalData': additionalData ?? {},
    };
    
    if (!_isInitialized) {
      _pendingLogs.add(logData);
      return;
    }
    
    await _sendLog(logData);
  }
  
  /// Отправить информационное сообщение
  static Future<void> sendInfo({
    required String message,
    required String userId,
    required String operation,
    Map<String, dynamic>? additionalData,
  }) async {
    final logData = {
      'message': message,
      'userId': userId,
      'operation': operation,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
      'version': '1.0.0',
      'severity': 'info',
      'additionalData': additionalData ?? {},
    };
    
    // Информационные сообщения отправляем только в production
    if (!kReleaseMode) return;
    
    if (!_isInitialized) {
      _pendingLogs.add(logData);
      return;
    }
    
    await _sendLog(logData);
  }
  
  /// Отправить пользовательскую активность
  static Future<void> sendUserActivity({
    required String userId,
    required String action,
    Map<String, dynamic>? data,
  }) async {
    final logData = {
      'userId': userId,
      'action': action,
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
      'version': '1.0.0',
      'type': 'user_activity',
    };
    
    if (!_isInitialized) {
      _pendingLogs.add(logData);
      return;
    }
    
    await _sendLog(logData);
  }
  
  /// Отправить метрики производительности
  static Future<void> sendPerformanceMetric({
    required String operation,
    required int durationMs,
    required String userId,
    Map<String, dynamic>? additionalData,
  }) async {
    final logData = {
      'operation': operation,
      'durationMs': durationMs,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
      'version': '1.0.0',
      'type': 'performance',
      'additionalData': additionalData ?? {},
    };
    
    if (!_isInitialized) {
      _pendingLogs.add(logData);
      return;
    }
    
    await _sendLog(logData);
  }
  
  /// Основной метод отправки логов
  static Future<void> _sendLog(Map<String, dynamic> logData) async {
    try {
      // Пытаемся отправить через Firebase Functions (предпочтительный способ)
      await _sendViaCloudFunction(logData);
    } catch (functionError) {
      if (kDebugMode) {
        debugPrint('Failed to send log via Cloud Function: $functionError');
      }
      
      try {
        // Fallback - отправляем напрямую в Firestore
        await _sendViaFirestore(logData);
      } catch (firestoreError) {
        if (kDebugMode) {
          debugPrint('Failed to send log via Firestore: $firestoreError');
        }
        
        // Последний fallback - сохраняем локально для повторной попытки
        await _saveLocallyForRetry(logData);
      }
    }
  }
  
  /// Отправка через Firebase Cloud Function
  static Future<void> _sendViaCloudFunction(Map<String, dynamic> logData) async {
    final functions = FirebaseFunctions.instance;
    
    await functions.httpsCallable('logError').call(logData);
  }
  
  /// Отправка напрямую в Firestore
  static Future<void> _sendViaFirestore(Map<String, dynamic> logData) async {
    final firestore = FirebaseFirestore.instance;
    
    // Определяем коллекцию на основе типа лога
    String collection;
    switch (logData['severity'] ?? logData['type']) {
      case 'critical':
      case 'warning':
        collection = 'error_logs';
        break;
      case 'performance':
        collection = 'performance_logs';
        break;
      case 'user_activity':
        collection = 'activity_logs';
        break;
      default:
        collection = 'app_logs';
    }
    
    await firestore.collection(collection).add(logData);
  }
  
  /// Сохранение локально для повторной попытки
  static Future<void> _saveLocallyForRetry(Map<String, dynamic> logData) async {
    // В production можно использовать локальную базу данных
    // Пока просто сохраняем в памяти
    _pendingLogs.add(logData);
    
    if (kDebugMode) {
      debugPrint('Log saved locally for retry: ${logData['operation']}');
    }
  }
  
  /// Отправить накопленные логи
  static Future<void> _flushPendingLogs() async {
    if (_pendingLogs.isEmpty) return;
    
    final logsToSend = List<Map<String, dynamic>>.from(_pendingLogs);
    _pendingLogs.clear();
    
    for (final logData in logsToSend) {
      try {
        await _sendLog(logData);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to flush pending log: $e');
        }
        // Возвращаем обратно в очередь если не удалось отправить
        _pendingLogs.add(logData);
      }
    }
  }
  
  /// Получить статистику отправки логов
  static Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized,
      'pendingLogsCount': _pendingLogs.length,
      'lastFlushTime': DateTime.now().toIso8601String(),
    };
  }
  
  /// Принудительная отправка всех накопленных логов
  static Future<void> forceFlush() async {
    await _flushPendingLogs();
  }
  
  /// Очистка локальных логов (использовать с осторожностью)
  static void clearPendingLogs() {
    _pendingLogs.clear();
  }
  
  /// Создать batch для отправки множественных логов
  static Future<void> sendBatch(List<Map<String, dynamic>> logs) async {
    for (final logData in logs) {
      await _sendLog(logData);
    }
  }
}

/// Утилиты для создания стандартизированных логов
class LogDataBuilder {
  static Map<String, dynamic> createErrorLog({
    required String error,
    required String operation,
    required String userId,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return {
      'error': error,
      'stackTrace': stackTrace,
      'operation': operation,
      'userId': userId,
      'context': context ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
    };
  }
  
  static Map<String, dynamic> createPerformanceLog({
    required String operation,
    required int durationMs,
    required String userId,
    Map<String, dynamic>? metrics,
  }) {
    return {
      'operation': operation,
      'durationMs': durationMs,
      'userId': userId,
      'metrics': metrics ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
    };
  }
  
  static Map<String, dynamic> createUserActivityLog({
    required String userId,
    required String action,
    Map<String, dynamic>? properties,
  }) {
    return {
      'userId': userId,
      'action': action,
      'properties': properties ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'telegram_webapp',
    };
  }
} 