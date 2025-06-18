import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/telegram_service.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;
  final TelegramService telegramService;

  const CourseDetailsScreen({
    super.key,
    required this.course,
    required this.telegramService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _toggleFavorite(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.imageUrl != null)
              Image.network(
                course.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Instructor: ${course.instructor}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: ${course.duration} minutes',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lessons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildLessonsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    return StreamBuilder<List<Lesson>>(
      stream: Lesson.getByCourse(course.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final lessons = snapshot.data ?? [];

        if (lessons.isEmpty) {
          return const Text('No lessons available');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: Text(lesson.name),
              subtitle: Text('${lesson.duration} minutes'),
              onTap: () => _playLesson(context, lesson),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final userId = telegramService.user?.id.toString();
      if (userId == null) {
        await telegramService.showAlert(
          title: 'Error',
          message: 'You must be logged in to add favorites',
        );
        return;
      }

      final userDoc = await telegramService.getUserDocument();
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(course.id);

      final favoriteDoc = await favoritesRef.get();
      if (favoriteDoc.exists) {
        await favoritesRef.delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course removed from favorites')),
          );
        }
      } else {
        await favoritesRef.set({
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course added to favorites')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _playLesson(BuildContext context, Lesson lesson) async {
    try {
      final confirmed = await telegramService.showConfirm(
        title: 'Play Lesson',
        message: 'Do you want to play "${lesson.name}"?',
      );

      if (confirmed && context.mounted) {
        // TODO: Implement video player
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video player not implemented yet')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
} 