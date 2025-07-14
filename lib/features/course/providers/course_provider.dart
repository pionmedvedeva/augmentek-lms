import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/course.dart';

class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  CourseNotifier() : super(const AsyncValue.loading()) {
    loadCourses();
  }

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadCourses() async {
    try {
      state = const AsyncValue.loading();
      
      final snapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();

      final courses = snapshot.docs
          .map((doc) => Course.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      state = AsyncValue.data(courses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> createCourse(Course course) async {
    try {
      final docRef = _firestore.collection('courses').doc();
      final courseWithId = course.copyWith(id: docRef.id);
      
      await docRef.set(courseWithId.toJson());
      await loadCourses();
      return docRef.id;
    } catch (error) {
      throw Exception('Ошибка создания курса: $error');
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      await _firestore
          .collection('courses')
          .doc(course.id)
          .update(course.copyWith(updatedAt: DateTime.now()).toJson());
      
      await loadCourses();
    } catch (error) {
      throw Exception('Ошибка обновления курса: $error');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      // Удаляем все уроки курса
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in lessonsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Удаляем сам курс
      batch.delete(_firestore.collection('courses').doc(courseId));
      
      await batch.commit();
      await loadCourses();
    } catch (error) {
      throw Exception('Ошибка удаления курса: $error');
    }
  }

  Future<void> toggleCourseStatus(String courseId, bool isActive) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .update({
            'isActive': isActive,
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      await loadCourses();
    } catch (error) {
      throw Exception('Ошибка изменения статуса курса: $error');
    }
  }
}

// Provider для всех курсов (для админов)
final courseProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>(
  (ref) => CourseNotifier(),
);

// Provider для активных курсов (для обычных пользователей)
final activeCoursesProvider = Provider<AsyncValue<List<Course>>>((ref) {
  final allCourses = ref.watch(courseProvider);
  
  return allCourses.when(
    data: (courses) {
      final activeCourses = courses.where((course) => course.isActive).toList();
      return AsyncValue.data(activeCourses);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}); 