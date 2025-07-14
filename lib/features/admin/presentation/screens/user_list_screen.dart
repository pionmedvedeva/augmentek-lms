import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/admin/providers/user_list_provider.dart';
import 'package:miniapp/features/admin/presentation/widgets/user_card.dart';
import 'package:miniapp/features/course/providers/course_provider.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/widgets/enhanced_user_avatar.dart';
import 'package:miniapp/core/utils/string_utils.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(userListProvider.notifier).loadUsers();
        },
        child: users.when(
          data: (userList) => userList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Пользователи отсутствуют',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Пользователи появятся после регистрации',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.deepPurple.withOpacity(0.1),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Всего ${RussianPlurals.formatUsers(userList.length)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          final user = userList[index];
                          return UserCard(
                            user: user,
                            onTap: () => _showUserDetails(context, user),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Ошибка загрузки пользователей: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(userListProvider.notifier).loadUsers(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  EnhancedUserAvatar(
                    user: user,
                    radius: 30,
                    backgroundColor: Color(0xFF4A90B8), // primaryBlue
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.username?.isNotEmpty == true)
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (user.isAdmin)
                    const Chip(
                      label: Text('Админ'),
                      backgroundColor: Colors.orange,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final allCoursesAsync = ref.watch(courseProvider);
                    
                    return ListView(
                      controller: scrollController,
                      children: [
                        _buildInfoCard('Telegram ID', user.id.toString()),
                        _buildInfoCard('Firebase ID', user.firebaseId ?? 'Неизвестно'),
                        if (user.languageCode?.isNotEmpty == true)
                          _buildInfoCard('Язык', user.languageCode!),
                        _buildInfoCard(
                          'Дата регистрации',
                          user.createdAt != null
                              ? _formatDate(user.createdAt!)
                              : 'Неизвестно',
                        ),
                        _buildInfoCard(
                          'Последнее обновление',
                          user.updatedAt != null
                              ? _formatDate(user.updatedAt!)
                              : 'Неизвестно',
                        ),
                        
                        // Информация о курсах
                        const SizedBox(height: 16),
                        const Text(
                          'Учебная информация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A90B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        if (user.enrolledCourses.isNotEmpty) ...[
                          allCoursesAsync.when(
                            data: (allCourses) {
                              final enrolledCourses = allCourses.where((course) => 
                                user.enrolledCourses.contains(course.id)).toList();
                              
                              return Column(
                                children: [
                                  _buildInfoCard(
                                    'Записан на курсы',
                                    enrolledCourses.isNotEmpty
                                        ? enrolledCourses.map((c) => '• ${c.title}').join('\n')
                                        : 'Курсы не найдены',
                                  ),
                                  
                                  // Прогресс по курсам
                                  if (user.courseProgress.isNotEmpty)
                                    _buildProgressCard(user.courseProgress, enrolledCourses),
                                  
                                  // Последняя активность по курсам
                                  if (user.lastAccessedAt.isNotEmpty)
                                    _buildActivityCard(user.lastAccessedAt, user.lastLessonId, enrolledCourses),
                                ],
                              );
                            },
                            loading: () => const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Загрузка информации о курсах...'),
                                  ],
                                ),
                              ),
                            ),
                            error: (_, __) => _buildInfoCard(
                              'Записан на курсы',
                              'Записан на ${RussianPlurals.formatCourses(user.enrolledCourses.length)}',
                            ),
                          ),
                        ] else ...[
                          _buildInfoCard('Записан на курсы', 'Не записан ни на один курс'),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Map<String, double> courseProgress, List<Course> enrolledCourses) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Прогресс по курсам',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...courseProgress.entries.map((entry) {
              final course = enrolledCourses.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => Course(
                  id: entry.key,
                  title: 'Неизвестный курс',
                  description: '',
                  imageUrl: '',
                  tags: [],
                  isActive: false,
                  createdBy: 'unknown',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  enrolledCount: 0,
                ),
              );
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${(entry.value * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.value == 1.0 ? Colors.green : Color(0xFF4A90B8),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, DateTime> lastAccessedAt, Map<String, String> lastLessonId, List<Course> enrolledCourses) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Последняя активность',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            ...lastAccessedAt.entries.map((entry) {
              final course = enrolledCourses.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => Course(
                  id: entry.key,
                  title: 'Неизвестный курс',
                  description: '',
                  imageUrl: '',
                  tags: [],
                  isActive: false,
                  createdBy: 'unknown',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  enrolledCount: 0,
                ),
              );
              
              final lastLesson = lastLessonId[entry.key];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatLastActivity(entry.value),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (lastLesson != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Урок: ${lastLesson.split('_').last}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatLastActivity(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${dateTime.day}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 