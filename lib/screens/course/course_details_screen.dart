import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/models/lesson.dart';
import 'package:miniapp/features/course/providers/lesson_provider.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load lessons for this course
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonProvider.notifier).loadLessons(widget.courseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now, we'll use mock course data since we don't have a single course provider
    final course = _getMockCourse();
    final lessons = ref.watch(lessonProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with course image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  course.imageUrl != null
                      ? Image.network(
                          course.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return _buildGradientBackground();
                          },
                        )
                      : _buildGradientBackground(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Поделиться курсом')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {
                  // TODO: Implement bookmark functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Добавлено в закладки')),
                  );
                },
              ),
            ],
          ),

          // Course Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryDisplayName(course.category),
                          style: TextStyle(
                            color: Colors.deepPurple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.schedule,
                        label: 'Длительность',
                        value: '4 недели', // TODO: Calculate from lessons
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.play_lesson,
                        label: 'Уроков',
                        value: lessons.when(
                          data: (lessonList) => lessonList.length.toString(),
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.people,
                        label: 'Студентов',
                        value: '1.2K', // TODO: Get from course data
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Enroll Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement course enrollment
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Записались на курс: ${course.title}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Записаться на курс',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                tabs: const [
                  Tab(text: 'Описание'),
                  Tab(text: 'Уроки'),
                  Tab(text: 'Отзывы'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Description Tab
                _buildDescriptionTab(course),
                
                // Lessons Tab
                _buildLessonsTab(lessons),
                
                // Reviews Tab
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple,
            Colors.purple.shade300,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.school,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(Course course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'О курсе',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: const TextStyle(
              height: 1.6,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (course.tags.isNotEmpty) ...[
            const Text(
              'Темы курса',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: course.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.deepPurple.withOpacity(0.1),
                  labelStyle: TextStyle(color: Colors.deepPurple[700]),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 24),
          
          const Text(
            'Что вы изучите',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Mock learning outcomes
          ..._getMockLearningOutcomes().map((outcome) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      outcome,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(AsyncValue<List<Lesson>> lessons) {
    return lessons.when(
      data: (lessonList) {
        if (lessonList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_lesson_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Уроки пока не добавлены',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Скоро здесь появятся уроки курса',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessonList.length,
          itemBuilder: (context, index) {
            final lesson = lessonList[index];
            final isLocked = index > 0; // Mock: first lesson is free
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isLocked 
                      ? Colors.grey[300] 
                      : Colors.deepPurple.withOpacity(0.1),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.play_arrow,
                    color: isLocked ? Colors.grey[600] : Colors.deepPurple,
                  ),
                ),
                title: Text(
                  lesson.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isLocked ? Colors.grey[600] : null,
                  ),
                ),
                subtitle: Text(
                  lesson.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLocked ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                trailing: Text(
                  '${lesson.durationMinutes} мин',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                onTap: isLocked ? null : () {
                  // TODO: Navigate to lesson
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Открываем урок: ${lesson.title}')),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка загрузки уроков: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(lessonProvider.notifier).loadLessons(widget.courseId),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Mock reviews
    final mockReviews = _getMockReviews();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockReviews.length,
      itemBuilder: (context, index) {
        final review = mockReviews[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      child: Text(
                        review['name'][0],
                        style: TextStyle(color: Colors.deepPurple[700]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < review['rating'] 
                                    ? Icons.star 
                                    : Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review['comment'],
                  style: const TextStyle(height: 1.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Course _getMockCourse() {
    return Course(
      id: widget.courseId,
      title: 'Flutter для начинающих',
      description: 'Изучите основы Flutter и создайте свое первое мобильное приложение. Этот курс подходит для начинающих программистов и тех, кто хочет освоить кросс-платформенную разработку.',
      category: 'programming',
      tags: ['Flutter', 'Dart', 'Мобильная разработка', 'UI/UX'],
      imageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      createdBy: 'admin',
    );
  }

  List<String> _getMockLearningOutcomes() {
    return [
      'Основы языка программирования Dart',
      'Создание пользовательских интерфейсов с Flutter',
      'Работа с виджетами и состоянием приложения',
      'Навигация между экранами',
      'Работа с API и базами данных',
      'Публикация приложения в магазинах приложений',
    ];
  }

  List<Map<String, dynamic>> _getMockReviews() {
    return [
      {
        'name': 'Анна Петрова',
        'rating': 5,
        'date': '15 июня',
        'comment': 'Отличный курс! Все объясняется очень доступно. Уже создала свое первое приложение.',
      },
      {
        'name': 'Михаил Иванов',
        'rating': 4,
        'date': '10 июня',
        'comment': 'Хороший курс для начинающих. Немного не хватает практических заданий.',
      },
      {
        'name': 'Елена Сидорова',
        'rating': 5,
        'date': '5 июня',
        'comment': 'Преподаватель объясняет сложные концепции простым языком. Рекомендую!',
      },
    ];
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'programming':
        return 'Программирование';
      case 'design':
        return 'Дизайн';
      case 'business':
        return 'Бизнес';
      case 'marketing':
        return 'Маркетинг';
      case 'languages':
        return 'Языки';
      case 'science':
        return 'Наука';
      case 'arts':
        return 'Искусство';
      default:
        return category;
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
} 