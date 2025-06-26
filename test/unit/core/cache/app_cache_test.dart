import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miniapp/core/cache/app_cache.dart';
import 'package:miniapp/shared/models/course.dart';

// Генерируем моки для SharedPreferences
@GenerateMocks([SharedPreferences])
import 'app_cache_test.mocks.dart';

/// Unit тесты для системы кеширования AppCache
/// 
/// Покрывает:
/// - Базовые операции (get/set/remove/clear)
/// - TTL и автоматическая очистка
/// - Статистика кэша
/// - Serialization/deserialization 
/// - Error handling и edge cases
/// - Memory и persistent cache integration
void main() {
  group('AppCache', () {
    late AppCache cache;
    late MockSharedPreferences mockPrefs;

    setUp(() async {
      mockPrefs = MockSharedPreferences();
      
      // Мокаем SharedPreferences по умолчанию
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
      when(mockPrefs.getString(any)).thenReturn(null);
      when(mockPrefs.remove(any)).thenAnswer((_) async => true);
      when(mockPrefs.clear()).thenAnswer((_) async => true);
      when(mockPrefs.getKeys()).thenReturn(<String>{});
      
      cache = AppCache(prefs: mockPrefs);
      await cache.initialize();
    });

    tearDown(() async {
      await cache.clear();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        expect(cache.isInitialized, isTrue);
      });

      test('should restore cache from persistent storage on init', () async {
        // Настраиваем мок с данными из persistent storage
        when(mockPrefs.getKeys()).thenReturn({'app_cache_test_key'});
        when(mockPrefs.getString('app_cache_test_key')).thenReturn(
          '{"data":"test_value","expiresAt":"2030-12-31T23:59:59.999Z","createdAt":"2024-01-01T00:00:00.000Z"}',
        );

        // Создаем новый экземпляр для тестирования инициализации
        final newCache = AppCache(prefs: mockPrefs);
        await newCache.initialize();

        final result = await newCache.get<String>('test_key');
        expect(result, 'test_value');
      });
    });

    group('Basic Operations', () {
      test('should store and retrieve data correctly', () async {
        const testKey = 'test_key';
        const testData = 'test_data';

        await cache.set(testKey, testData);
        final result = await cache.get<String>(testKey);

        expect(result, testData);
      });

      test('should return null for non-existent key', () async {
        final result = await cache.get<String>('non_existent_key');
        expect(result, isNull);
      });

      test('should remove data correctly', () async {
        const testKey = 'test_key';
        const testData = 'test_data';

        await cache.set(testKey, testData);
        expect(await cache.get<String>(testKey), testData);

        await cache.remove(testKey);
        expect(await cache.get<String>(testKey), isNull);
      });

      test('should clear all data', () async {
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');
        await cache.set('key3', 'value3');

        expect(await cache.get<String>('key1'), 'value1');
        expect(await cache.get<String>('key2'), 'value2');
        expect(await cache.get<String>('key3'), 'value3');

        await cache.clear();

        expect(await cache.get<String>('key1'), isNull);
        expect(await cache.get<String>('key2'), isNull);
        expect(await cache.get<String>('key3'), isNull);
      });
    });

    group('TTL and Expiration', () {
      test('should respect TTL and expire data', () async {
        const testKey = 'test_key';
        const testData = 'test_data';
        const ttl = Duration(milliseconds: 100);

        await cache.set(testKey, testData, ttl: ttl);
        expect(await cache.get<String>(testKey), testData);

        // Ждем больше TTL
        await Future.delayed(const Duration(milliseconds: 150));

        expect(await cache.get<String>(testKey), isNull);
      });

      test('should not expire data within TTL', () async {
        const testKey = 'test_key';
        const testData = 'test_data';
        const ttl = Duration(seconds: 1);

        await cache.set(testKey, testData, ttl: ttl);
        expect(await cache.get<String>(testKey), testData);

        // Ждем меньше TTL
        await Future.delayed(const Duration(milliseconds: 100));

        expect(await cache.get<String>(testKey), testData);
      });

      test('should handle data without TTL as never expiring', () async {
        const testKey = 'test_key';
        const testData = 'test_data';

        await cache.set(testKey, testData); // Без TTL

        // Проверяем что данные есть сейчас и через некоторое время
        expect(await cache.get<String>(testKey), testData);
        
        await Future.delayed(const Duration(milliseconds: 100));
        expect(await cache.get<String>(testKey), testData);
      });
    });

    group('Data Types', () {
      test('should handle string data', () async {
        const testData = 'string_data';
        await cache.set('string_key', testData);
        expect(await cache.get<String>('string_key'), testData);
      });

      test('should handle numeric data', () async {
        const intData = 42;
        const doubleData = 3.14;

        await cache.set('int_key', intData);
        await cache.set('double_key', doubleData);

        expect(await cache.get<int>('int_key'), intData);
        expect(await cache.get<double>('double_key'), doubleData);
      });

      test('should handle boolean data', () async {
        await cache.set('bool_true', true);
        await cache.set('bool_false', false);

        expect(await cache.get<bool>('bool_true'), isTrue);
        expect(await cache.get<bool>('bool_false'), isFalse);
      });

      test('should handle list data', () async {
        const testList = ['item1', 'item2', 'item3'];
        await cache.set('list_key', testList);
        
        final result = await cache.get<List<String>>('list_key');
        expect(result, testList);
      });

      test('should handle map data', () async {
        const testMap = {'key1': 'value1', 'key2': 'value2'};
        await cache.set('map_key', testMap);
        
        final result = await cache.get<Map<String, String>>('map_key');
        expect(result, testMap);
      });

      test('should handle complex objects with fromJson/toJson', () async {
        final testCourse = Course(
          id: 'test_course',
          title: 'Test Course',
          description: 'Test Description',
          coverImageUrl: 'https://example.com/image.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sections: [],
        );

        await cache.set('course_key', testCourse);
        final result = await cache.get<Course>('course_key');

        expect(result?.id, testCourse.id);
        expect(result?.title, testCourse.title);
        expect(result?.description, testCourse.description);
      });
    });

    group('Statistics', () {
      test('should track cache statistics', () async {
        final initialStats = cache.getStatistics();
        expect(initialStats.hits, 0);
        expect(initialStats.misses, 0);
        expect(initialStats.totalItems, 0);
        expect(initialStats.memoryUsage, 0);

        // Set и get для hit
        await cache.set('key1', 'value1');
        await cache.get<String>('key1');

        // Get несуществующего для miss
        await cache.get<String>('non_existent');

        final stats = cache.getStatistics();
        expect(stats.hits, 1);
        expect(stats.misses, 1);
        expect(stats.totalItems, 1);
        expect(stats.memoryUsage, greaterThan(0));
      });

      test('should calculate hit rate correctly', () async {
        // 2 hits, 1 miss = 66.67% hit rate
        await cache.set('key1', 'value1');
        await cache.set('key2', 'value2');
        
        await cache.get<String>('key1'); // hit
        await cache.get<String>('key2'); // hit
        await cache.get<String>('key3'); // miss

        final stats = cache.getStatistics();
        expect(stats.hitRate, closeTo(0.667, 0.01));
      });
    });

    group('Cache Size Management', () {
      test('should enforce maximum cache size', () async {
        // Настраиваем небольшой лимит для тестирования
        const smallCacheSize = 1024; // 1 KB
        final limitedCache = AppCache(prefs: mockPrefs, maxSize: smallCacheSize);
        await limitedCache.initialize();

        // Добавляем данные, превышающие лимит
        final largeData = 'x' * 500; // 500 символов
        
        await limitedCache.set('key1', largeData);
        await limitedCache.set('key2', largeData);
        await limitedCache.set('key3', largeData); // Должно вызвать очистку

        final stats = limitedCache.getStatistics();
        expect(stats.memoryUsage, lessThanOrEqualTo(smallCacheSize));
      });
    });

    group('Persistence', () {
      test('should persist data to SharedPreferences', () async {
        const testKey = 'persist_key';
        const testData = 'persist_data';

        await cache.set(testKey, testData, persist: true);

        // Проверяем что данные сохранились в SharedPreferences
        verify(mockPrefs.setString(
          'app_cache_$testKey',
          any,
        )).called(1);
      });

      test('should not persist data when persist=false', () async {
        const testKey = 'no_persist_key';
        const testData = 'no_persist_data';

        await cache.set(testKey, testData, persist: false);

        // Проверяем что данные НЕ сохранились в SharedPreferences
        verifyNever(mockPrefs.setString(
          'app_cache_$testKey',
          any,
        ));
      });
    });

    group('Error Handling', () {
      test('should handle SharedPreferences errors gracefully', () async {
        // Мокаем ошибку SharedPreferences
        when(mockPrefs.setString(any, any)).thenThrow(Exception('Storage error'));

        // Операция не должна выбрасывать исключение
        expect(
          () async => await cache.set('key', 'value', persist: true),
          returnsNormally,
        );
      });

      test('should handle malformed persistent data', () async {
        // Мокаем некорректные данные в SharedPreferences
        when(mockPrefs.getKeys()).thenReturn({'app_cache_bad_key'});
        when(mockPrefs.getString('app_cache_bad_key')).thenReturn('invalid_json');

        // Инициализация не должна выбрасывать исключение
        final newCache = AppCache(prefs: mockPrefs);
        expect(() async => await newCache.initialize(), returnsNormally);
      });

      test('should handle null data gracefully', () async {
        await cache.set('null_key', null);
        final result = await cache.get('null_key');
        expect(result, isNull);
      });
    });

    group('Cleanup Operations', () {
      test('should clean up expired entries automatically', () async {
        const shortTtl = Duration(milliseconds: 50);
        
        await cache.set('expire1', 'data1', ttl: shortTtl);
        await cache.set('expire2', 'data2', ttl: shortTtl);
        await cache.set('permanent', 'data3'); // Без TTL

        expect(await cache.get('expire1'), 'data1');
        expect(await cache.get('expire2'), 'data2');
        expect(await cache.get('permanent'), 'data3');

        // Ждем истечения TTL
        await Future.delayed(const Duration(milliseconds: 100));

        // Принудительная очистка истекших записей
        await cache.cleanupExpired();

        expect(await cache.get('expire1'), isNull);
        expect(await cache.get('expire2'), isNull);
        expect(await cache.get('permanent'), 'data3');
      });
    });

    group('Edge Cases', () {
      test('should handle empty string keys', () async {
        expect(() async => await cache.set('', 'value'), returnsNormally);
        expect(await cache.get<String>(''), 'value');
      });

      test('should handle very long keys', () async {
        final longKey = 'x' * 1000;
        expect(() async => await cache.set(longKey, 'value'), returnsNormally);
        expect(await cache.get<String>(longKey), 'value');
      });

      test('should handle concurrent access', () async {
        const key = 'concurrent_key';
        
        // Параллельные операции
        final futures = List.generate(10, (i) => cache.set('$key$i', 'value$i'));
        await Future.wait(futures);

        // Проверяем что все операции выполнились
        for (int i = 0; i < 10; i++) {
          expect(await cache.get<String>('$key$i'), 'value$i');
        }
      });
    });
  });
} 