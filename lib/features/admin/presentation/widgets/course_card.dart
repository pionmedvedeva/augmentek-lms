import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/features/course/providers/course_stats_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourseCard extends ConsumerWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onEditDescription;
  final VoidCallback onDelete;
  final Function(bool) onToggleStatus;
  final VoidCallback? onManageContent;

  const CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onEditDescription,
    required this.onDelete,
    required this.onToggleStatus,
    this.onManageContent,
  });

    @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseStats = ref.watch(courseStatsProvider(course.id));
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка курса слева
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: course.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: course.imageUrl!,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.school,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.school,
                        color: Colors.grey,
                        size: 20,
                      ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Основная информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название курса + кнопка редактирования названия + переключатель активности
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: onManageContent,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    course.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: onManageContent != null ? Colors.blue[600] : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit),
                              iconSize: 16,
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(),
                              tooltip: 'Редактировать название',
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Маленький слайдер переключатель
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: course.isActive,
                          onChanged: onToggleStatus,
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.grey,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Описание курса + кнопка редактирования описания
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onEditDescription,
                        icon: const Icon(Icons.edit),
                        iconSize: 14,
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(),
                        tooltip: 'Редактировать описание',
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Нижняя строка: Статистика + управление содержимым + удаление
                  Row(
                    children: [
                      // Количество студентов
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrolledCount}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Управление содержимым (кликабельное)
                      if (onManageContent != null)
                        InkWell(
                          onTap: onManageContent,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: courseStats.when(
                              data: (stats) => Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${stats.sectionsCount}',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${stats.lessonsCount}',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                                ),
                              ),
                              error: (_, __) => Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '—',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '—',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Кнопка удаления
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        iconSize: 18,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        color: Colors.red,
                        tooltip: 'Удалить курс',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 