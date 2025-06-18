import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniapp/models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  // Course operations
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });
    } catch (e) {
      print('Error enrolling in course: $e');
    }
  }

  Future<void> updateCourseProgress(String userId, String courseId, double progress) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'courseProgress.$courseId': progress,
      });
    } catch (e) {
      print('Error updating course progress: $e');
    }
  }
} 