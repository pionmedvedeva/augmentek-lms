import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniapp/models/user.dart';
import '../core/utils/app_logger.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<User?> getUser(String userId) async {
    try {
      AppLogger.info('Getting user with ID: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        AppLogger.info('User found: $userId');
        return User.fromJson(doc.data()!);
      }
      AppLogger.warning('User not found: $userId');
      return null;
    } catch (e) {
      AppLogger.error('Error getting user $userId: $e');
      return null;
    }
  }

  Future<void> createUser(User user) async {
    try {
      AppLogger.info('Creating user: ${user.id}');
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      AppLogger.info('User created successfully: ${user.id}');
    } catch (e) {
      AppLogger.error('Error creating user ${user.id}: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      AppLogger.info('Updating user: ${user.id}');
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      AppLogger.info('User updated successfully: ${user.id}');
    } catch (e) {
      AppLogger.error('Error updating user ${user.id}: $e');
    }
  }

  // Course operations
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      AppLogger.info('Getting courses from Firestore');
      final snapshot = await _firestore.collection('courses').get();
      final courses = snapshot.docs.map((doc) => doc.data()).toList();
      AppLogger.info('Retrieved ${courses.length} courses');
      return courses;
    } catch (e) {
      AppLogger.error('Error getting courses: $e');
      return [];
    }
  }

  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      AppLogger.info('Enrolling user $userId in course $courseId');
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });
      AppLogger.info('User $userId enrolled in course $courseId successfully');
    } catch (e) {
      AppLogger.error('Error enrolling user $userId in course $courseId: $e');
    }
  }

  Future<void> updateCourseProgress(String userId, String courseId, double progress) async {
    try {
      AppLogger.info('Updating course progress for user $userId, course $courseId: ${(progress * 100).toStringAsFixed(1)}%');
      await _firestore.collection('users').doc(userId).update({
        'courseProgress.$courseId': progress,
      });
      AppLogger.info('Course progress updated successfully');
    } catch (e) {
      AppLogger.error('Error updating course progress for user $userId, course $courseId: $e');
    }
  }
} 