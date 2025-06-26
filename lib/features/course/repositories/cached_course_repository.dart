import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/cache/app_cache.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/config/app_environment.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/course.dart';

/// Репозиторий курсов с интегрированным кешированием
class CachedCourseRepository with CacheableMixin {
  final FirebaseFirestore _firestore;
  
  CachedCourseRepository(this._firestore);
  
  /// Получить все курсы с кешированием
  Future<List<Course>> getAllCourses({bool forceRefresh = false}) async {
    const cacheKey = 'courses_all';
    
    return await cached<List<Course>>(
      cacheKey,
      () => _fetchCoursesFromFirestore(),
      expiration: EnvironmentConfig.cacheDuration,
      forceRefresh: forceRefresh,
    ) ?? [];
  }
  
  /// Получить активные курсы с кешированием
  Future<List<Course>> getActiveCourses({bool forceRefresh = false}) async {
    const cacheKey = 'courses_active';
    
    return await cached<List<Course>>(
      cacheKey,
      () => _fetchActiveCoursesFromFirestore(),
      expiration: EnvironmentConfig.cacheDuration,
      forceRefresh: forceRefresh,
    ) ?? [];
  }
  
  /// Получить курс по ID с кешированием
  Future<Course?> getCourseById(String courseId, {bool forceRefresh = false}) async {
    final cacheKey = 'course_$courseId';
    
    return await cached<Course?>(
      cacheKey,
      () => _fetchCourseByIdFromFirestore(courseId),
      expiration: EnvironmentConfig.cacheDuration,
      forceRefresh: forceRefresh,
    );
  }
  
  /// Создать новый курс
  Future<String> createCourse(Course course) async {
    AppLogger.info('📚 Creating new course: ${course.title}');
    
    try {
      // Создаем в Firestore
      final docRef = await _firestore
          .collection(AppEndpoints.courses)
          .add(course.toJson());
      
      final courseWithId = course.copyWith(id: docRef.id);
      
      // Обновляем кеш
      await _updateCourseCache(courseWithId);
      await _invalidateCoursesListCache();
      
      AppLogger.info('✅ Course created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      AppLogger.error('❌ Failed to create course: $e');
      rethrow;
    }
  }
  
  /// Обновить курс
  Future<void> updateCourse(Course course) async {
    AppLogger.info('📝 Updating course: ${course.id}');
    
    try {
      // Обновляем в Firestore
      await _firestore
          .collection(AppEndpoints.courses)
          .doc(course.id)
          .update(course.toJson());
      
      // Обновляем кеш
      await _updateCourseCache(course);
      await _invalidateCoursesListCache();
      
      AppLogger.info('✅ Course updated successfully: ${course.id}');
    } catch (e) {
      AppLogger.error('❌ Failed to update course: $e');
      rethrow;
    }
  }
  
  /// Удалить курс
  Future<void> deleteCourse(String courseId) async {
    AppLogger.info('🗑️ Deleting course: $courseId');
    
    try {
      // Удаляем из Firestore
      await _firestore
          .collection(AppEndpoints.courses)
          .doc(courseId)
          .delete();
      
      // Очищаем кеш
      await cache.remove('course_$courseId');
      await _invalidateCoursesListCache();
      
      AppLogger.info('✅ Course deleted successfully: $courseId');
    } catch (e) {
      AppLogger.error('❌ Failed to delete course: $e');
      rethrow;
    }
  }
  
  /// Поиск курсов с кешированием результатов
  Future<List<Course>> searchCourses(String query, {bool forceRefresh = false}) async {
    if (query.trim().isEmpty) {
      return getActiveCourses(forceRefresh: forceRefresh);
    }
    
    final cacheKey = 'courses_search_${query.toLowerCase().trim()}';
    
    return await cached<List<Course>>(
      cacheKey,
      () => _searchCoursesInFirestore(query),
      expiration: const Duration(minutes: 30), // Короткий кеш для поиска
      forceRefresh: forceRefresh,
    ) ?? [];
  }
  
  /// Получить курсы пользователя с кешированием
  Future<List<Course>> getUserEnrolledCourses(String userId, {bool forceRefresh = false}) async {
    final cacheKey = 'user_courses_$userId';
    
    return await cached<List<Course>>(
      cacheKey,
      () => _fetchUserCoursesFromFirestore(userId),
      expiration: const Duration(hours: 1), // Средний кеш для пользовательских данных
      forceRefresh: forceRefresh,
    ) ?? [];
  }
  
  /// Получить статистику курса с кешированием
  Future<CourseStats> getCourseStats(String courseId, {bool forceRefresh = false}) async {
    final cacheKey = 'course_stats_$courseId';
    
    return await cached<CourseStats>(
      cacheKey,
      () => _fetchCourseStatsFromFirestore(courseId),
      expiration: const Duration(minutes: 15), // Быстрое обновление для статистики
      forceRefresh: forceRefresh,
    ) ?? CourseStats.empty();
  }
  
  // Приватные методы для работы с Firestore
  
  Future<List<Course>> _fetchCoursesFromFirestore() async {
    AppLogger.debug('🔄 Fetching all courses from Firestore');
    
    final snapshot = await _firestore
        .collection(AppEndpoints.courses)
        .get();
    
    final courses = snapshot.docs
        .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    
    AppLogger.debug('📚 Fetched ${courses.length} courses from Firestore');
    return courses;
  }
  
  Future<List<Course>> _fetchActiveCoursesFromFirestore() async {
    AppLogger.debug('🔄 Fetching active courses from Firestore');
    
    final snapshot = await _firestore
        .collection(AppEndpoints.courses)
        .where('isActive', isEqualTo: true)
        .get();
    
    final courses = snapshot.docs
        .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    
    AppLogger.debug('📚 Fetched ${courses.length} active courses from Firestore');
    return courses;
  }
  
  Future<Course?> _fetchCourseByIdFromFirestore(String courseId) async {
    AppLogger.debug('🔄 Fetching course by ID from Firestore: $courseId');
    
    final doc = await _firestore
        .collection(AppEndpoints.courses)
        .doc(courseId)
        .get();
    
    if (!doc.exists) {
      AppLogger.warning('⚠️ Course not found: $courseId');
      return null;
    }
    
    final course = Course.fromJson({...doc.data()!, 'id': doc.id});
    AppLogger.debug('📚 Fetched course from Firestore: ${course.title}');
    return course;
  }
  
  Future<List<Course>> _searchCoursesInFirestore(String query) async {
    AppLogger.debug('🔍 Searching courses in Firestore: $query');
    
    // Простой поиск по заголовку (в реальности можно использовать Algolia или другие решения)
    final snapshot = await _firestore
        .collection(AppEndpoints.courses)
        .where('isActive', isEqualTo: true)
        .get();
    
    final queryLower = query.toLowerCase();
    final courses = snapshot.docs
        .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
        .where((course) => 
            course.title.toLowerCase().contains(queryLower) ||
            course.description.toLowerCase().contains(queryLower))
        .toList();
    
    AppLogger.debug('🔍 Found ${courses.length} courses matching: $query');
    return courses;
  }
  
  Future<List<Course>> _fetchUserCoursesFromFirestore(String userId) async {
    AppLogger.debug('🔄 Fetching user enrolled courses: $userId');
    
    // Получаем записи пользователя
    final enrollmentsSnapshot = await _firestore
        .collection(AppEndpoints.enrollments)
        .where('userId', isEqualTo: userId)
        .get();
    
    if (enrollmentsSnapshot.docs.isEmpty) {
      return [];
    }
    
    // Получаем ID курсов
    final courseIds = enrollmentsSnapshot.docs
        .map((doc) => doc.data()['courseId'] as String)
        .toList();
    
    // Получаем курсы (используем батчи для больших списков)
    final courses = <Course>[];
    const batchSize = 10; // Firestore limit for 'in' queries
    
    for (int i = 0; i < courseIds.length; i += batchSize) {
      final batch = courseIds.skip(i).take(batchSize).toList();
      
      final snapshot = await _firestore
          .collection(AppEndpoints.courses)
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      
      courses.addAll(
        snapshot.docs.map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
      );
    }
    
    AppLogger.debug('📚 Fetched ${courses.length} enrolled courses for user: $userId');
    return courses;
  }
  
  Future<CourseStats> _fetchCourseStatsFromFirestore(String courseId) async {
    AppLogger.debug('📊 Fetching course stats: $courseId');
    
    // Получаем количество записанных пользователей
    final enrollmentsSnapshot = await _firestore
        .collection(AppEndpoints.enrollments)
        .where('courseId', isEqualTo: courseId)
        .get();
    
    final enrolledCount = enrollmentsSnapshot.docs.length;
    
    // Можно добавить другие статистики (завершения, рейтинги и т.д.)
    
    final stats = CourseStats(
      courseId: courseId,
      enrolledCount: enrolledCount,
      completedCount: 0, // TODO: Реализовать подсчет завершений
      averageRating: 0.0, // TODO: Реализовать рейтинги
      lastUpdated: DateTime.now(),
    );
    
    AppLogger.debug('📊 Course stats: enrolled=$enrolledCount');
    return stats;
  }
  
  // Методы для управления кешем
  
  Future<void> _updateCourseCache(Course course) async {
    await cache.set('course_${course.id}', course);
  }
  
  Future<void> _invalidateCoursesListCache() async {
    await cache.remove('courses_all');
    await cache.remove('courses_active');
    // Также можно очистить кеш поиска, но это может быть избыточно
  }
  
  /// Очистить весь кеш курсов
  Future<void> clearCache() async {
    AppLogger.info('🧹 Clearing courses cache');
    
    final stats = await cache.getStats();
    AppLogger.debug('📊 Cache stats before clearing: $stats');
    
    // Очищаем все записи курсов в кеше
    // В реальности нужна более сложная логика для выборочной очистки
    await cache.clear();
    
    AppLogger.info('✅ Courses cache cleared');
  }
  
  /// Принудительно обновить все кеши курсов
  Future<void> refreshAllCaches() async {
    AppLogger.info('🔄 Refreshing all course caches');
    
    await Future.wait([
      getAllCourses(forceRefresh: true),
      getActiveCourses(forceRefresh: true),
    ]);
    
    AppLogger.info('✅ All course caches refreshed');
  }
}

/// Статистика курса
class CourseStats {
  final String courseId;
  final int enrolledCount;
  final int completedCount;
  final double averageRating;
  final DateTime lastUpdated;
  
  const CourseStats({
    required this.courseId,
    required this.enrolledCount,
    required this.completedCount,
    required this.averageRating,
    required this.lastUpdated,
  });
  
  factory CourseStats.empty() => CourseStats(
    courseId: '',
    enrolledCount: 0,
    completedCount: 0,
    averageRating: 0.0,
    lastUpdated: DateTime.now(),
  );
  
  @override
  String toString() => 'CourseStats(enrolled: $enrolledCount, completed: $completedCount, rating: $averageRating)';
}

/// Провайдер для кешированного репозитория курсов
final cachedCourseRepositoryProvider = Provider<CachedCourseRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return CachedCourseRepository(firestore);
}); 