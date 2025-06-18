import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/telegram_service.dart';
import '../../models/course.dart';
import 'course_details_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  final TelegramService telegramService;

  const MyCoursesScreen({
    super.key,
    required this.telegramService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: StreamBuilder<List<Course>>(
        stream: _getFavoriteCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(
              child: Text('No favorite courses yet'),
            );
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: course.imageUrl != null
                    ? Image.network(
                        course.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.book),
                title: Text(course.title),
                subtitle: Text(course.instructor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailsScreen(
                        course: course,
                        telegramService: telegramService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<Course>> _getFavoriteCourses() {
    final userId = telegramService.user?.id.toString();
    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      final courseIds = snapshot.docs.map((doc) => doc.id).toList();
      if (courseIds.isEmpty) return [];

      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      return coursesSnapshot.docs
          .map((doc) => Course.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
} 