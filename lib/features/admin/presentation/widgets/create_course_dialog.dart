import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/course.dart';
import 'package:miniapp/shared/widgets/image_upload_widget.dart';
import 'package:miniapp/services/storage_service.dart';
import '../../../../core/utils/app_logger.dart';

class CreateCourseDialog extends ConsumerStatefulWidget {
  final Course? course;
  final Function(Course) onCourseCreated;

  const CreateCourseDialog({
    super.key,
    this.course,
    required this.onCourseCreated,
  });

  @override
  ConsumerState<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends ConsumerState<CreateCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageFileName;
  String? _imageUrl;
  bool _imageRemoved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _tagsController = TextEditingController(
      text: widget.course?.tags.join(', ') ?? '',
    );
    _imageUrl = widget.course?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Редактировать курс' : 'Создать новый курс',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Загрузка изображения
                ImageUploadWidget(
                  initialImageUrl: _imageUrl,
                  onImageSelected: (bytes, fileName) {
                    setState(() {
                      _selectedImageBytes = bytes;
                      _selectedImageFileName = fileName;
                      _imageRemoved = false;
                    });
                  },
                  onImageRemoved: () {
                    setState(() {
                      _selectedImageBytes = null;
                      _selectedImageFileName = null;
                      _imageRemoved = true;
                      _imageUrl = null;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Название курса
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название курса',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название курса';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Описание
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите описание курса';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Теги
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Теги (через запятую)',
                    border: OutlineInputBorder(),
                    hintText: 'например: программирование, веб-разработка',
                  ),
                ),
                const SizedBox(height: 24),

                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(isEditing ? 'Сохранить' : 'Создать'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      String? finalImageUrl = _imageUrl;

      // Загружаем новое изображение если выбрано
      if (_selectedImageBytes != null && _selectedImageFileName != null) {
        AppLogger.info('Starting image upload process', ref);
        
        // Убеждаемся что Firebase инициализирован
        await Future.delayed(const Duration(milliseconds: 200));
        
        final courseId = widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        AppLogger.info('Course ID for upload: $courseId', ref);
        AppLogger.info('Image file name: $_selectedImageFileName', ref);
        AppLogger.info('Image size: ${_selectedImageBytes!.length} bytes', ref);
        
        try {
          AppLogger.info('Calling storage service', ref);
          finalImageUrl = await ref.read(storageServiceProvider).uploadCourseImage(
            courseId: courseId,
            imageBytes: _selectedImageBytes!,
            fileName: _selectedImageFileName!,
          );
          AppLogger.info('Image upload successful, URL: $finalImageUrl', ref);
        } catch (storageError) {
          AppLogger.error('Storage error occurred: $storageError', ref);
          // Показываем конкретную ошибку Storage
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка загрузки изображения: $storageError'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return; // Прерываем сохранение если изображение не загрузилось
        }
      }

      AppLogger.info('Creating course object', ref);

      // Удаляем старое изображение если нужно
      if (_imageRemoved && widget.course?.imageUrl != null) {
        try {
          await ref.read(storageServiceProvider).deleteCourseImage(widget.course!.imageUrl!);
        } catch (e) {
          // Логируем ошибку, но не прерываем процесс
          AppLogger.warning('Не удалось удалить старое изображение: $e', ref);
        }
        finalImageUrl = null;
      }

      final course = widget.course?.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        imageUrl: finalImageUrl,
        updatedAt: DateTime.now(),
      ) ?? Course(
        id: '', // Будет установлен в CourseProvider
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: tags,
        imageUrl: finalImageUrl,
        isActive: true,
        enrolledCount: 0,
        createdBy: '', // TODO: установить текущего пользователя
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AppLogger.info('Calling onCourseCreated callback', ref);
      widget.onCourseCreated(course);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('General error occurred: $e', ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 