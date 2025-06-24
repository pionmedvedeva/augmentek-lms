import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseStats {
  final int sectionsCount;
  final int lessonsCount;

  const CourseStats({
    required this.sectionsCount,
    required this.lessonsCount,
  });
}

class CourseStatsNotifier extends StateNotifier<AsyncValue<CourseStats>> {
  CourseStatsNotifier(this._courseId) : super(const AsyncValue.loading()) {
    loadStats();
  }

  final String _courseId;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();

      // Получаем количество разделов
      final sectionsSnapshot = await _firestore
          .collection('sections')
          .where('courseId', isEqualTo: _courseId)
          .get();

      // Получаем количество уроков
      final lessonsSnapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: _courseId)
          .get();

      final stats = CourseStats(
        sectionsCount: sectionsSnapshot.docs.length,
        lessonsCount: lessonsSnapshot.docs.length,
      );

      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Провайдер для получения статистики конкретного курса
final courseStatsProvider = StateNotifierProvider.family<CourseStatsNotifier, AsyncValue<CourseStats>, String>(
  (ref, courseId) => CourseStatsNotifier(courseId),
); 