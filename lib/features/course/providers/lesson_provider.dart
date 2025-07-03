import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';

class LessonNotifier extends StateNotifier<AsyncValue<List<Lesson>>> {
  LessonNotifier(this._ref, {String? courseId, String? sectionId}) : super(const AsyncValue.loading()) {
    if (sectionId != null) {
      loadLessonsBySection(sectionId);
    } else if (courseId != null) {
      loadLessonsByCourse(courseId);
    } else {
      loadLessons();
    }
  }

  final Ref _ref;
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadLessons() async {
    try {
      state = const AsyncValue.loading();
      _ref.read(debugLogsProvider.notifier).addLog('📖 Loading all lessons');
      
      final snapshot = await _firestore
          .collection('lessons')
          .orderBy('order', descending: false)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      _ref.read(debugLogsProvider.notifier).addLog('✅ Loaded ${lessons.length} lessons');
      state = AsyncValue.data(lessons);
    } catch (error, stackTrace) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error loading lessons: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadLessonsByCourse(String courseId) async {
    try {
      state = const AsyncValue.loading();
      _ref.read(debugLogsProvider.notifier).addLog('📖 Loading lessons for course: $courseId');
      
      final snapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      // Сортируем на клиенте
      lessons.sort((a, b) => a.order.compareTo(b.order));

      _ref.read(debugLogsProvider.notifier).addLog('✅ Loaded ${lessons.length} lessons for course');
      state = AsyncValue.data(lessons);
    } catch (error, stackTrace) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error loading course lessons: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadLessonsBySection(String sectionId) async {
    try {
      state = const AsyncValue.loading();
      _ref.read(debugLogsProvider.notifier).addLog('📖 Loading lessons for section: $sectionId');
      
      final snapshot = await _firestore
          .collection('lessons')
          .where('sectionId', isEqualTo: sectionId)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      // Сортируем на клиенте
      lessons.sort((a, b) => a.order.compareTo(b.order));

      _ref.read(debugLogsProvider.notifier).addLog('✅ Loaded ${lessons.length} lessons for section');
      state = AsyncValue.data(lessons);
    } catch (error, stackTrace) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error loading section lessons: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createLesson({
    required String courseId,
    String? sectionId,
    required String title,
    required String description,
    String? content,
    String? videoUrl,
    String? documentUrl,
    String? homeworkTask,
    String? homeworkAnswer,
    int? durationMinutes,
  }) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('➕ Creating lesson: $title');
      
      // Определяем порядок для нового урока
      final existingLessons = state.value ?? [];
      final lessonsInSameContainer = sectionId != null
          ? existingLessons.where((l) => l.sectionId == sectionId).toList()
          : existingLessons.where((l) => l.courseId == courseId && l.sectionId == null).toList();
      final order = lessonsInSameContainer.length;

      final lessonData = {
        'courseId': courseId,
        'sectionId': sectionId,
        'title': title,
        'description': description,
        'content': content,
        'videoUrl': videoUrl,
        'documentUrl': documentUrl,
        'homeworkTask': homeworkTask,
        'homeworkAnswer': homeworkAnswer,
        'order': order,
        'durationMinutes': durationMinutes ?? 0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('lessons').add(lessonData);
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Lesson created successfully');
      
      // Перезагружаем соответствующие уроки
      if (sectionId != null) {
        await loadLessonsBySection(sectionId);
      } else {
        await loadLessonsByCourse(courseId);
      }
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error creating lesson: $error');
      throw Exception('Ошибка создания урока: $error');
    }
  }

  Future<void> updateLesson(Lesson lesson) async {
    try {
      await _firestore
          .collection('lessons')
          .doc(lesson.id)
          .update(lesson.copyWith(updatedAt: DateTime.now()).toJson());
      
      await loadLessons();
    } catch (error) {
      throw Exception('Ошибка обновления урока: $error');
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore
          .collection('lessons')
          .doc(lessonId)
          .delete();
      
      await loadLessons();
    } catch (error) {
      throw Exception('Ошибка удаления урока: $error');
    }
  }

  Future<void> reorderLessons(List<String> lessonIds) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🔄 Reordering lessons: ${lessonIds.length} lessons');
      
      final batch = _firestore.batch();
      
      for (int i = 0; i < lessonIds.length; i++) {
        final docRef = _firestore.collection('lessons').doc(lessonIds[i]);
        batch.update(docRef, {
          'order': i,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
      
      // Перезагружаем уроки в зависимости от контекста
      final currentLessons = state.value ?? [];
      if (currentLessons.isNotEmpty) {
        final firstLesson = currentLessons.first;
        if (firstLesson.sectionId != null) {
          await loadLessonsBySection(firstLesson.sectionId!);
        } else {
          await loadLessonsByCourse(firstLesson.courseId);
        }
      }
      
      _ref.read(debugLogsProvider.notifier).addLog('✅ Lessons reordered successfully');
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error reordering lessons: $error');
      throw Exception('Ошибка изменения порядка уроков: $error');
    }
  }

  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('📖 Loading lesson by ID: $lessonId');
      
      final doc = await _firestore
          .collection('lessons')
          .doc(lessonId)
          .get();

      if (doc.exists) {
        final lesson = Lesson.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
        
        _ref.read(debugLogsProvider.notifier).addLog('✅ Loaded lesson: ${lesson.title}');
        return lesson;
      } else {
        _ref.read(debugLogsProvider.notifier).addLog('❌ Lesson not found: $lessonId');
        return null;
      }
    } catch (error) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error loading lesson: $error');
      throw Exception('Ошибка загрузки урока: $error');
    }
  }
}

final lessonProvider = StateNotifierProvider<LessonNotifier, AsyncValue<List<Lesson>>>(
  (ref) => LessonNotifier(ref),
);

final courseLessonsProvider = StateNotifierProvider.family<LessonNotifier, AsyncValue<List<Lesson>>, String>(
  (ref, courseId) => LessonNotifier(ref, courseId: courseId),
);

final sectionLessonsProvider = StateNotifierProvider.family<LessonNotifier, AsyncValue<List<Lesson>>, String>(
  (ref, sectionId) => LessonNotifier(ref, sectionId: sectionId),
);

final lessonByIdProvider = FutureProvider.family<Lesson?, String>((ref, lessonId) async {
  final notifier = LessonNotifier(ref);
  return await notifier.getLessonById(lessonId);
}); 