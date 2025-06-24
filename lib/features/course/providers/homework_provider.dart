import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/homework_submission.dart';

class HomeworkProvider extends StateNotifier<List<HomeworkSubmission>> {
  HomeworkProvider() : super([]);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Отправить домашнее задание
  Future<void> submitHomework({
    required String lessonId,
    required String courseId,
    required String studentId,
    required String studentName,
    required String answer,
  }) async {
    try {
      final submission = HomeworkSubmission(
        id: _firestore.collection('homework_submissions').doc().id,
        lessonId: lessonId,
        courseId: courseId,
        studentId: studentId,
        studentName: studentName,
        answer: answer,
        status: HomeworkStatus.pending,
        submittedAt: DateTime.now(),
      );

      await _firestore
          .collection('homework_submissions')
          .doc(submission.id)
          .set(submission.toJson());

      // Обновляем локальный список
      state = [...state, submission];
    } catch (e) {
      throw Exception('Ошибка отправки домашнего задания: $e');
    }
  }

  // Получить домашние задания для урока
  Future<void> loadHomeworkForLesson(String lessonId) async {
    try {
      final querySnapshot = await _firestore
          .collection('homework_submissions')
          .where('lessonId', isEqualTo: lessonId)
          .orderBy('submittedAt', descending: true)
          .get();

      final submissions = querySnapshot.docs
          .map((doc) => HomeworkSubmission.fromJson(doc.data()))
          .toList();

      state = submissions;
    } catch (e) {
      throw Exception('Ошибка загрузки домашних заданий: $e');
    }
  }

  // Получить домашние задания студента
  Future<List<HomeworkSubmission>> getStudentHomework(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('homework_submissions')
          .where('studentId', isEqualTo: studentId)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HomeworkSubmission.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки домашних заданий студента: $e');
    }
  }

  // Проверить домашнее задание (админ)
  Future<void> reviewHomework({
    required String submissionId,
    required HomeworkStatus status,
    required String reviewedBy,
    String? adminComment,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'reviewedBy': reviewedBy,
        'reviewedAt': DateTime.now().toIso8601String(),
      };

      if (adminComment != null && adminComment.isNotEmpty) {
        updateData['adminComment'] = adminComment;
      }

      await _firestore
          .collection('homework_submissions')
          .doc(submissionId)
          .update(updateData);

      // Обновляем локальный список
      state = state.map((submission) {
        if (submission.id == submissionId) {
          return submission.copyWith(
            status: status,
            reviewedBy: reviewedBy,
            reviewedAt: DateTime.now(),
            adminComment: adminComment,
          );
        }
        return submission;
      }).toList();
    } catch (e) {
      throw Exception('Ошибка проверки домашнего задания: $e');
    }
  }

  // Получить все непроверенные домашние задания
  Future<List<HomeworkSubmission>> getPendingHomework() async {
    try {
      final querySnapshot = await _firestore
          .collection('homework_submissions')
          .where('status', isEqualTo: HomeworkStatus.pending.name)
          .orderBy('submittedAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => HomeworkSubmission.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки непроверенных заданий: $e');
    }
  }

  // Проверить есть ли уже отправленное задание от студента для урока
  Future<HomeworkSubmission?> getStudentSubmissionForLesson(
    String studentId,
    String lessonId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('homework_submissions')
          .where('studentId', isEqualTo: studentId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return HomeworkSubmission.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final homeworkProvider = StateNotifierProvider<HomeworkProvider, List<HomeworkSubmission>>(
  (ref) => HomeworkProvider(),
);

// Провайдер для получения домашних заданий студента
final studentHomeworkProvider = FutureProvider.family<List<HomeworkSubmission>, String>(
  (ref, studentId) async {
    final homeworkNotifier = ref.read(homeworkProvider.notifier);
    return await homeworkNotifier.getStudentHomework(studentId);
  },
);

// Провайдер для получения непроверенных заданий
final pendingHomeworkProvider = FutureProvider<List<HomeworkSubmission>>(
  (ref) async {
    final homeworkNotifier = ref.read(homeworkProvider.notifier);
    return await homeworkNotifier.getPendingHomework();
  },
); 