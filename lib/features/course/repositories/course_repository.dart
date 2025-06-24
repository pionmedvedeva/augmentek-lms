import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniapp/shared/models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();
  Future<Course?> getCourse(String courseId);
  Future<void> createCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String courseId);
}

class CourseRepository implements ICourseRepository {
  CourseRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Course> get _coursesCollection =>
      _firestore.collection('courses').withConverter<Course>(
            fromFirestore: (snapshot, _) => Course.fromJson(snapshot.data()!),
            toFirestore: (course, _) => course.toJson(),
          );

  @override
  Future<List<Course>> getCourses() async {
    final snapshot = await _coursesCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Course?> getCourse(String courseId) async {
    final snapshot = await _coursesCollection.doc(courseId).get();
    return snapshot.data();
  }

  @override
  Future<void> createCourse(Course course) async {
    await _coursesCollection.doc(course.id).set(course);
  }

  @override
  Future<void> updateCourse(Course course) async {
    await _coursesCollection.doc(course.id).set(course, SetOptions(merge: true));
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _coursesCollection.doc(courseId).delete();
  }
} 