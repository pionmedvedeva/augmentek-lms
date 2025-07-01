import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/lesson_progress.dart';
import '../../../shared/models/course_progress.dart';
import '../../../shared/models/lesson.dart';
import '../../../shared/models/homework_submission.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Коллекции Firestore
  CollectionReference get _lessonsProgressCollection => 
      _firestore.collection('lessons_progress');
  CollectionReference get _coursesProgressCollection => 
      _firestore.collection('courses_progress');
  CollectionReference get _lessonsCollection => 
      _firestore.collection('lessons');
  CollectionReference get _coursesCollection => 
      _firestore.collection('courses');
  CollectionReference get _homeworkSubmissionsCollection => 
      _firestore.collection('homework_submissions');

  /// Получить прогресс урока для пользователя
  Future<LessonProgress?> getLessonProgress(String userId, String lessonId) async {
    try {
      final doc = await _lessonsProgressCollection
          .doc('${userId}_$lessonId')
          .get();
      
      if (doc.exists) {
        return LessonProgress.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      AppLogger.error('Ошибка получения прогресса урока: $e');
      rethrow;
    }
  }

  /// Получить все прогрессы уроков пользователя для курса
  Future<List<LessonProgress>> getLessonProgressesForCourse(String userId, String courseId) async {
    try {
      final query = await _lessonsProgressCollection
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();
      
      return query.docs.map((doc) => 
          LessonProgress.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Ошибка получения прогрессов уроков курса: $e');
      rethrow;
    }
  }

  /// Создать или обновить прогресс урока
  Future<void> updateLessonProgress(LessonProgress progress) async {
    try {
      await _lessonsProgressCollection
          .doc('${progress.userId}_${progress.lessonId}')
          .set(progress.toJson(), SetOptions(merge: true));
      
      AppLogger.info('Прогресс урока обновлен');
    } catch (e) {
      AppLogger.error('Ошибка обновления прогресса урока: $e');
      rethrow;
    }
  }

  /// Отметить урок как начатый
  Future<void> markLessonStarted(String userId, String courseId, String lessonId) async {
    try {
      // Получаем информацию об уроке
      final lessonDoc = await _lessonsCollection.doc(lessonId).get();
      if (!lessonDoc.exists) {
        throw Exception('Урок не найден');
      }
      
      final lesson = Lesson.fromJson(lessonDoc.data() as Map<String, dynamic>);
      
      // Получаем информацию о курсе
      final courseDoc = await _coursesCollection.doc(courseId).get();
      final courseTitle = courseDoc.exists 
          ? (courseDoc.data() as Map<String, dynamic>)['title'] ?? 'Неизвестный курс'
          : 'Неизвестный курс';

      final progressId = '${userId}_$lessonId';
      final existingProgress = await getLessonProgress(userId, lessonId);
      
      final progress = existingProgress?.copyWith(
        isStarted: true,
        startedAt: existingProgress.startedAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      ) ?? LessonProgress(
        id: progressId,
        userId: userId,
        courseId: courseId,
        lessonId: lessonId,
        lessonTitle: lesson.title,
        courseTitle: courseTitle,
        isStarted: true,
        hasHomework: lesson.homeworkTask?.isNotEmpty == true,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await updateLessonProgress(progress);
    } catch (e) {
      AppLogger.error('Ошибка отметки урока как начатого: $e');
      rethrow;
    }
  }

  /// Отметить урок как завершенный
  Future<void> markLessonCompleted(String userId, String courseId, String lessonId) async {
    try {
      final existingProgress = await getLessonProgress(userId, lessonId);
      if (existingProgress == null) {
        // Сначала отмечаем как начатый
        await markLessonStarted(userId, courseId, lessonId);
      }
      
      final progress = existingProgress?.copyWith(
        isCompleted: true,
        completionPercentage: 1.0,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ) ?? await _createInitialProgress(userId, courseId, lessonId, isCompleted: true);

      await updateLessonProgress(progress);
      
      // Обновляем общий прогресс курса
      await _updateCourseProgress(userId, courseId);
      
    } catch (e) {
      AppLogger.error('Ошибка отметки урока как завершенного: $e');
      rethrow;
    }
  }

  /// Обновить прогресс по домашнему заданию
  Future<void> updateHomeworkProgress(String userId, String lessonId, {
    bool? submitted,
    bool? completed,
  }) async {
    try {
      final existingProgress = await getLessonProgress(userId, lessonId);
      if (existingProgress == null) return;
      
      final progress = existingProgress.copyWith(
        homeworkSubmitted: submitted ?? existingProgress.homeworkSubmitted,
        homeworkCompleted: completed ?? existingProgress.homeworkCompleted,
        updatedAt: DateTime.now(),
      );

      await updateLessonProgress(progress);
      
      // Обновляем общий прогресс курса
      await _updateCourseProgress(userId, existingProgress.courseId);
      
    } catch (e) {
      AppLogger.error('Ошибка обновления прогресса домашки: $e');
      rethrow;
    }
  }

  /// Получить общий прогресс курса
  Future<CourseProgress?> getCourseProgress(String userId, String courseId) async {
    try {
      final doc = await _coursesProgressCollection
          .doc('${userId}_$courseId')
          .get();
      
      if (doc.exists) {
        return CourseProgress.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      AppLogger.error('Ошибка получения прогресса курса: $e');
      rethrow;
    }
  }

  /// Получить все прогрессы курсов пользователя
  Future<List<CourseProgress>> getUserCourseProgresses(String userId) async {
    try {
      final query = await _coursesProgressCollection
          .where('userId', isEqualTo: userId)
          .orderBy('lastAccessedAt', descending: true)
          .get();
      
      return query.docs.map((doc) => 
          CourseProgress.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Ошибка получения прогрессов курсов: $e');
      rethrow;
    }
  }

  /// Найти следующий урок для изучения
  Future<Map<String, String>?> getNextLesson(String userId) async {
    try {
      final courseProgresses = await getUserCourseProgresses(userId);
      
      for (final courseProgress in courseProgresses) {
        if (courseProgress.hasNextLesson) {
          // Получаем информацию об уроке
          final lessonDoc = await _lessonsCollection.doc(courseProgress.nextLessonId!).get();
          final lessonTitle = lessonDoc.exists 
              ? (lessonDoc.data() as Map<String, dynamic>)['title'] ?? 'Урок'
              : 'Урок';
          
          return {
            'courseId': courseProgress.courseId,
            'courseTitle': courseProgress.courseTitle,
            'lessonId': courseProgress.nextLessonId!,
            'lessonTitle': lessonTitle,
          };
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Ошибка поиска следующего урока: $e');
      rethrow;
    }
  }

  /// Приватный метод для обновления общего прогресса курса
  Future<void> _updateCourseProgress(String userId, String courseId) async {
    try {
      // Получаем все уроки курса
      final lessonsQuery = await _lessonsCollection
          .where('courseId', isEqualTo: courseId)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();
      
      final allLessonIds = lessonsQuery.docs.map((doc) => doc.id).toList();
      
      // Получаем прогрессы по урокам
      final lessonProgresses = await getLessonProgressesForCourse(userId, courseId);
      
      // Получаем информацию о курсе
      final courseDoc = await _coursesCollection.doc(courseId).get();
      final courseTitle = courseDoc.exists 
          ? (courseDoc.data() as Map<String, dynamic>)['title'] ?? 'Неизвестный курс'
          : 'Неизвестный курс';

      // Вычисляем общий прогресс
      final courseProgress = ProgressCalculator.calculateFromLessons(
        userId: userId,
        courseId: courseId,
        courseTitle: courseTitle,
        lessonProgresses: lessonProgresses,
        allLessonIds: allLessonIds,
      );

      // Сохраняем в Firestore
      await _coursesProgressCollection
          .doc('${userId}_$courseId')
          .set(courseProgress.toJson(), SetOptions(merge: true));
          
    } catch (e) {
      AppLogger.error('Ошибка обновления прогресса курса: $e');
      rethrow;
    }
  }

  /// Приватный метод для создания начального прогресса
  Future<LessonProgress> _createInitialProgress(String userId, String courseId, String lessonId, {bool isCompleted = false}) async {
    final lessonDoc = await _lessonsCollection.doc(lessonId).get();
    final lesson = Lesson.fromJson(lessonDoc.data() as Map<String, dynamic>);
    
    final courseDoc = await _coursesCollection.doc(courseId).get();
    final courseTitle = courseDoc.exists 
        ? (courseDoc.data() as Map<String, dynamic>)['title'] ?? 'Неизвестный курс'
        : 'Неизвестный курс';

    return LessonProgress(
      id: '${userId}_$lessonId',
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
      lessonTitle: lesson.title,
      courseTitle: courseTitle,
      isStarted: true,
      isCompleted: isCompleted,
      completionPercentage: isCompleted ? 1.0 : 0.0,
      hasHomework: lesson.homeworkTask?.isNotEmpty == true,
      startedAt: DateTime.now(),
      completedAt: isCompleted ? DateTime.now() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Автоматическое обновление прогресса на основе статуса домашки
  Future<void> syncHomeworkProgress(String userId, String lessonId, HomeworkStatus status) async {
    try {
      await updateHomeworkProgress(
        userId, 
        lessonId,
        submitted: status != HomeworkStatus.pending ? true : null,
        completed: status == HomeworkStatus.approved,
      );
    } catch (e) {
      AppLogger.error('Ошибка синхронизации прогресса домашки: $e');
      rethrow;
    }
  }
} 