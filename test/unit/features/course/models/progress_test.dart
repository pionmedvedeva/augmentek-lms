import 'package:flutter_test/flutter_test.dart';
import 'package:miniapp/shared/models/lesson_progress.dart';
import 'package:miniapp/shared/models/course_progress.dart';

void main() {
  group('LessonProgress', () {
    test('should create lesson progress with default values', () {
      final progress = LessonProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        lessonId: 'lesson_1',
        lessonTitle: 'Test Lesson',
        courseTitle: 'Test Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(progress.id, 'test_id');
      expect(progress.isStarted, false);
      expect(progress.isCompleted, false);
      expect(progress.completionPercentage, 0.0);
      expect(progress.hasHomework, false);
      expect(progress.homeworkSubmitted, false);
      expect(progress.homeworkCompleted, false);
    });

    test('should calculate correct status for different states', () {
      final baseProgress = LessonProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        lessonId: 'lesson_1',
        lessonTitle: 'Test Lesson',
        courseTitle: 'Test Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Not started
      expect(baseProgress.status, LessonStatus.notStarted);

      // In progress
      final inProgress = baseProgress.copyWith(isStarted: true);
      expect(inProgress.status, LessonStatus.inProgress);

      // Completed without homework
      final completed = baseProgress.copyWith(isStarted: true, isCompleted: true);
      expect(completed.status, LessonStatus.completed);

      // Completed with homework
      final completedWithHomework = baseProgress.copyWith(
        isStarted: true,
        isCompleted: true,
        hasHomework: true,
        homeworkCompleted: true,
      );
      expect(completedWithHomework.status, LessonStatus.completed);

      // Homework pending review
      final pendingReview = baseProgress.copyWith(
        isStarted: true,
        isCompleted: true,
        hasHomework: true,
        homeworkSubmitted: true,
        homeworkCompleted: false,
      );
      expect(pendingReview.status, LessonStatus.pendingReview);
    });

    test('should calculate isFullyCompleted correctly', () {
      final baseProgress = LessonProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        lessonId: 'lesson_1',
        lessonTitle: 'Test Lesson',
        courseTitle: 'Test Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Not completed
      expect(baseProgress.isFullyCompleted, false);

      // Completed without homework
      final completedNoHomework = baseProgress.copyWith(
        isCompleted: true,
        hasHomework: false,
      );
      expect(completedNoHomework.isFullyCompleted, true);

      // Completed with homework but homework not done
      final completedHomeworkPending = baseProgress.copyWith(
        isCompleted: true,
        hasHomework: true,
        homeworkCompleted: false,
      );
      expect(completedHomeworkPending.isFullyCompleted, false);

      // Fully completed with homework
      final fullyCompleted = baseProgress.copyWith(
        isCompleted: true,
        hasHomework: true,
        homeworkCompleted: true,
      );
      expect(fullyCompleted.isFullyCompleted, true);
    });
  });

  group('CourseProgress', () {
    test('should create course progress with default values', () {
      final progress = CourseProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        courseTitle: 'Test Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(progress.completionPercentage, 0.0);
      expect(progress.totalLessons, 0);
      expect(progress.completedLessons, 0);
      expect(progress.totalHomework, 0);
      expect(progress.completedHomework, 0);
      expect(progress.pendingHomework, 0);
      expect(progress.achievements, isEmpty);
      expect(progress.streak, 0);
    });

    test('should calculate status correctly', () {
      final baseProgress = CourseProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        courseTitle: 'Test Course',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Not started
      expect(baseProgress.status, CourseStatus.notStarted);

      // In progress
      final inProgress = baseProgress.copyWith(
        totalLessons: 10,
        completedLessons: 5,
      );
      expect(inProgress.status, CourseStatus.inProgress);

      // Completed without homework
      final completedNoHomework = baseProgress.copyWith(
        totalLessons: 10,
        completedLessons: 10,
        totalHomework: 0,
        completedHomework: 0,
      );
      expect(completedNoHomework.status, CourseStatus.completed);

      // Completed with homework
      final fullyCompleted = baseProgress.copyWith(
        totalLessons: 10,
        completedLessons: 10,
        totalHomework: 5,
        completedHomework: 5,
      );
      expect(fullyCompleted.status, CourseStatus.completed);

      // Lessons done but homework pending
      final homeworkPending = baseProgress.copyWith(
        totalLessons: 10,
        completedLessons: 10,
        totalHomework: 5,
        completedHomework: 3,
      );
      expect(homeworkPending.status, CourseStatus.inProgress);
    });

    test('should calculate properties correctly', () {
      final progress = CourseProgress(
        id: 'test_id',
        userId: 'user_1',
        courseId: 'course_1',
        courseTitle: 'Test Course',
        completionPercentage: 0.75,
        totalLessons: 10,
        completedLessons: 7,
        pendingHomework: 2,
        nextLessonId: 'lesson_8',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(progress.completionPercent, 75);
      expect(progress.progressText, '7 из 10 уроков');
      expect(progress.hasPendingHomework, true);
      expect(progress.hasNextLesson, true);
    });
  });

  group('ProgressCalculator', () {
    test('should calculate course progress from lesson progresses', () {
      final lessonProgresses = [
        LessonProgress(
          id: 'user_1_lesson_1',
          userId: 'user_1',
          courseId: 'course_1',
          lessonId: 'lesson_1',
          lessonTitle: 'Lesson 1',
          courseTitle: 'Course 1',
          isStarted: true,
          isCompleted: true,
          hasHomework: true,
          homeworkCompleted: true,
          timeSpentSeconds: 300,
          startedAt: DateTime.now().subtract(Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LessonProgress(
          id: 'user_1_lesson_2',
          userId: 'user_1',
          courseId: 'course_1',
          lessonId: 'lesson_2',
          lessonTitle: 'Lesson 2',
          courseTitle: 'Course 1',
          isStarted: true,
          isCompleted: false,
          hasHomework: false,
          timeSpentSeconds: 150,
          startedAt: DateTime.now().subtract(Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final allLessonIds = ['lesson_1', 'lesson_2', 'lesson_3'];

      final courseProgress = ProgressCalculator.calculateFromLessons(
        userId: 'user_1',
        courseId: 'course_1',
        courseTitle: 'Course 1',
        lessonProgresses: lessonProgresses,
        allLessonIds: allLessonIds,
      );

      expect(courseProgress.totalLessons, 3);
      expect(courseProgress.completedLessons, 1);
      expect(courseProgress.lessonsInProgress, 1);
      expect(courseProgress.totalHomework, 1);
      expect(courseProgress.completedHomework, 1);
      expect(courseProgress.totalTimeSpentSeconds, 450);
      expect(courseProgress.completionPercentage, closeTo(0.33, 0.01));
      expect(courseProgress.nextLessonId, 'lesson_2'); // Current lesson in progress
    });

    test('should handle empty lesson progresses', () {
      final courseProgress = ProgressCalculator.calculateFromLessons(
        userId: 'user_1',
        courseId: 'course_1',
        courseTitle: 'Course 1',
        lessonProgresses: [],
        allLessonIds: ['lesson_1', 'lesson_2'],
      );

      expect(courseProgress.totalLessons, 2);
      expect(courseProgress.completedLessons, 0);
      expect(courseProgress.lessonsInProgress, 0);
      expect(courseProgress.totalHomework, 0);
      expect(courseProgress.completedHomework, 0);
      expect(courseProgress.totalTimeSpentSeconds, 0);
      expect(courseProgress.completionPercentage, 0.0);
      expect(courseProgress.nextLessonId, 'lesson_1');
    });
  });
} 