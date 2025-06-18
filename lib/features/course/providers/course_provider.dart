import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../../shared/models/course.dart';

final logger = Logger();

final coursesProvider = StreamProvider<List<Course>>((ref) {
  return FirebaseFirestore.instance
      .collection('courses')
      .where('isPublished', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Course.fromJson(doc.data()))
          .toList());
});

final courseProvider = StreamProvider.family<Course?, String>((ref, courseId) {
  return FirebaseFirestore.instance
      .collection('courses')
      .doc(courseId)
      .snapshots()
      .map((doc) => doc.exists ? Course.fromJson(doc.data()!) : null);
});

final favoriteCoursesProvider = StreamProvider<List<Course>>((ref) {
  final user = ref.watch(authProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('favorites')
      .snapshots()
      .asyncMap((snapshot) async {
        final courseIds = snapshot.docs.map((doc) => doc.id).toList();
        if (courseIds.isEmpty) return [];

        final courses = await Future.wait(
          courseIds.map((id) => FirebaseFirestore.instance
              .collection('courses')
              .doc(id)
              .get()
              .then((doc) => doc.exists ? Course.fromJson(doc.data()!) : null)
              .catchError((e) {
            logger.e('Error fetching course $id', e);
            return null;
          })),
        );

        return courses.whereType<Course>().toList();
      });
});

final courseNotifierProvider = StateNotifierProvider<CourseNotifier, AsyncValue<void>>((ref) {
  return CourseNotifier(
    FirebaseFirestore.instance,
    ref.watch(authProvider).value,
  );
});

class CourseNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final User? _user;

  CourseNotifier(this._firestore, this._user) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(String courseId) async {
    if (_user == null) {
      throw Exception('User must be authenticated to toggle favorites');
    }

    try {
      state = const AsyncValue.loading();
      final favoriteRef = _firestore
          .collection('users')
          .doc(_user!.id)
          .collection('favorites')
          .doc(courseId);

      final doc = await favoriteRef.get();
      if (doc.exists) {
        await favoriteRef.delete();
        logger.i('Course $courseId removed from favorites');
      } else {
        await favoriteRef.set({'addedAt': FieldValue.serverTimestamp()});
        logger.i('Course $courseId added to favorites');
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      logger.e('Error toggling favorite', e, stack);
      rethrow;
    }
  }

  Future<void> updateCourseProgress(String courseId, double progress) async {
    if (_user == null) {
      throw Exception('User must be authenticated to update progress');
    }

    try {
      state = const AsyncValue.loading();
      await _firestore
          .collection('users')
          .doc(_user!.id)
          .collection('progress')
          .doc(courseId)
          .set({
        'progress': progress,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      logger.i('Course progress updated: $courseId - $progress');
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      logger.e('Error updating course progress', e, stack);
      rethrow;
    }
  }
} 