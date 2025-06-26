import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_environment.dart';
import '../utils/app_logger.dart';

/// Система кеширования для Augmentek LMS
class AppCache {
  static AppCache? _instance;
  static AppCache get instance => _instance ??= AppCache._internal();
  
  AppCache._internal();
  
  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  
  /// Инициализация кеша
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _cleanupExpiredEntries();
      AppLogger.info('🗄️ AppCache инициализирован');
    } catch (e) {
      AppLogger.error('Ошибка инициализации AppCache: $e');
    }
  }
  
  /// Сохранение данных в кеш
  Future<void> set<T>(
    String key,
    T data, {
    Duration? expiration,
    bool memoryOnly = false,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(expiration ?? EnvironmentConfig.cacheDuration);
      
      final cacheEntry = CacheEntry<T>(
        data: data,
        createdAt: now,
        expiresAt: expiresAt,
      );
      
      // Сохраняем в память
      _memoryCache[key] = cacheEntry;
      
      // Сохраняем в постоянное хранилище (если не только в памяти)
      if (!memoryOnly && _prefs != null) {
        await _saveToStorage(key, cacheEntry);
      }
      
      AppLogger.debug('💾 Данные сохранены в кеш: $key');
    } catch (e) {
      AppLogger.error('Ошибка сохранения в кеш [$key]: $e');
    }
  }
  
  /// Получение данных из кеша
  Future<T?> get<T>(String key) async {
    try {
      // Проверяем память
      if (_memoryCache.containsKey(key)) {
        final entry = _memoryCache[key]!;
        if (!entry.isExpired) {
          AppLogger.debug('🏃 Данные получены из памяти: $key');
          return entry.data as T?;
        } else {
          _memoryCache.remove(key);
        }
      }
      
      // Проверяем постоянное хранилище
      if (_prefs != null) {
        final entry = await _loadFromStorage<T>(key);
        if (entry != null && !entry.isExpired) {
          // Восстанавливаем в память
          _memoryCache[key] = entry;
          AppLogger.debug('💽 Данные получены из хранилища: $key');
          return entry.data;
        } else if (entry != null) {
          // Удаляем устаревшие данные
          await _prefs!.remove(_storageKey(key));
        }
      }
      
      AppLogger.debug('❌ Данные не найдены в кеше: $key');
      return null;
    } catch (e) {
      AppLogger.error('Ошибка получения из кеша [$key]: $e');
      return null;
    }
  }
  
  /// Проверка наличия данных в кеше
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }
  
  /// Удаление конкретной записи
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      if (_prefs != null) {
        await _prefs!.remove(_storageKey(key));
      }
      AppLogger.debug('🗑️ Данные удалены из кеша: $key');
    } catch (e) {
      AppLogger.error('Ошибка удаления из кеша [$key]: $e');
    }
  }
  
  /// Очистка всего кеша
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      
      if (_prefs != null) {
        final keys = _prefs!.getKeys()
            .where((key) => key.startsWith(_cachePrefix))
            .toList();
        
        for (final key in keys) {
          await _prefs!.remove(key);
        }
      }
      
      AppLogger.info('🧹 Кеш полностью очищен');
    } catch (e) {
      AppLogger.error('Ошибка очистки кеша: $e');
    }
  }
  
  /// Очистка устаревших записей
  Future<void> _cleanupExpiredEntries() async {
    try {
      if (_prefs == null) return;
      
      final keys = _prefs!.getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .toList();
      
      int removedCount = 0;
      
      for (final storageKey in keys) {
        final cacheKey = storageKey.substring(_cachePrefix.length);
        final entry = await _loadFromStorage(cacheKey);
        
        if (entry == null || entry.isExpired) {
          await _prefs!.remove(storageKey);
          _memoryCache.remove(cacheKey);
          removedCount++;
        }
      }
      
      if (removedCount > 0) {
        AppLogger.info('🧹 Удалено устаревших записей из кеша: $removedCount');
      }
    } catch (e) {
      AppLogger.error('Ошибка очистки устаревших записей: $e');
    }
  }
  
  /// Получение статистики кеша
  Future<CacheStats> getStats() async {
    try {
      final memorySize = _memoryCache.length;
      
      int storageSize = 0;
      int totalSize = 0;
      
      if (_prefs != null) {
        final keys = _prefs!.getKeys()
            .where((key) => key.startsWith(_cachePrefix));
        
        storageSize = keys.length;
        
        for (final key in keys) {
          final value = _prefs!.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return CacheStats(
        memoryEntries: memorySize,
        storageEntries: storageSize,
        totalSizeBytes: totalSize,
        maxSizeBytes: EnvironmentConfig.maxCacheSize,
      );
    } catch (e) {
      AppLogger.error('Ошибка получения статистики кеша: $e');
      return CacheStats.empty();
    }
  }
  
  /// Сохранение в постоянное хранилище
  Future<void> _saveToStorage<T>(String key, CacheEntry<T> entry) async {
    try {
      final json = {
        'data': _serializeData(entry.data),
        'createdAt': entry.createdAt.millisecondsSinceEpoch,
        'expiresAt': entry.expiresAt.millisecondsSinceEpoch,
      };
      
      await _prefs!.setString(_storageKey(key), jsonEncode(json));
    } catch (e) {
      AppLogger.error('Ошибка сохранения в storage [$key]: $e');
    }
  }
  
  /// Загрузка из постоянного хранилища
  Future<CacheEntry<T>?> _loadFromStorage<T>(String key) async {
    try {
      final jsonString = _prefs!.getString(_storageKey(key));
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final data = _deserializeData<T>(json['data']);
      final createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(json['expiresAt']);
      
      if (data != null) {
        return CacheEntry<T>(
          data: data,
          createdAt: createdAt,
          expiresAt: expiresAt,
        );
      }
      return null;
    } catch (e) {
      AppLogger.error('Ошибка загрузки из storage [$key]: $e');
      return null;
    }
  }
  
  /// Сериализация данных
  dynamic _serializeData<T>(T data) {
    if (data == null) return null;
    
    // Основные типы
    if (data is String || data is num || data is bool) {
      return data;
    }
    
    // Списки и карты
    if (data is List || data is Map) {
      return data;
    }
    
    // Пытаемся сериализовать как JSON
    try {
      return jsonDecode(jsonEncode(data));
    } catch (e) {
      AppLogger.warning('Не удалось сериализовать данные: $e');
      return data.toString();
    }
  }
  
  /// Десериализация данных
  T? _deserializeData<T>(dynamic data) {
    if (data == null) return null;
    
    try {
      return data as T;
    } catch (e) {
      AppLogger.warning('Не удалось десериализовать данные: $e');
      return null;
    }
  }
  
  String get _cachePrefix => 'cache_';
  String _storageKey(String key) => '$_cachePrefix$key';
}

/// Запись в кеше
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime expiresAt;
  
  const CacheEntry({
    required this.data,
    required this.createdAt,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  Duration get age => DateTime.now().difference(createdAt);
  Duration get timeToLive => expiresAt.difference(DateTime.now());
  
  @override
  String toString() => 'CacheEntry(age: ${age.inMinutes}min, ttl: ${timeToLive.inMinutes}min)';
}

/// Статистика кеша
class CacheStats {
  final int memoryEntries;
  final int storageEntries;
  final int totalSizeBytes;
  final int maxSizeBytes;
  
  const CacheStats({
    required this.memoryEntries,
    required this.storageEntries,
    required this.totalSizeBytes,
    required this.maxSizeBytes,
  });
  
  factory CacheStats.empty() => const CacheStats(
    memoryEntries: 0,
    storageEntries: 0,
    totalSizeBytes: 0,
    maxSizeBytes: 0,
  );
  
  double get usagePercentage => maxSizeBytes > 0 ? (totalSizeBytes / maxSizeBytes) * 100 : 0;
  String get formattedSize => _formatBytes(totalSizeBytes);
  String get formattedMaxSize => _formatBytes(maxSizeBytes);
  
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  
  @override
  String toString() => 'CacheStats(memory: $memoryEntries, storage: $storageEntries, size: $formattedSize/$formattedMaxSize)';
}

/// Миксин для компонентов с кешированием
mixin CacheableMixin {
  AppCache get cache => AppCache.instance;
  
  /// Кеширование результата асинхронной операции
  Future<T?> cached<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? expiration,
    bool forceRefresh = false,
  }) async {
    // Проверяем кеш (если не принудительное обновление)
    if (!forceRefresh) {
      final cached = await cache.get<T>(key);
      if (cached != null) {
        return cached;
      }
    }
    
    // Выполняем операцию и кешируем результат
    try {
      final result = await fetcher();
      if (result != null) {
        await cache.set(key, result, expiration: expiration);
      }
      return result;
    } catch (e) {
      AppLogger.error('Ошибка при выполнении операции для кеширования [$key]: $e');
      
      // В случае ошибки возвращаем устаревшие данные из кеша
      return await cache.get<T>(key);
    }
  }
  
  /// Инвалидация кеша по паттерну
  Future<void> invalidateCache(String pattern) async {
    // Базовая реализация - удаление точного ключа
    await cache.remove(pattern);
  }
} 