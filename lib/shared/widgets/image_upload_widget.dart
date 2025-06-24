import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(Uint8List bytes, String fileName) onImageSelected;
  final VoidCallback? onImageRemoved;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _imageUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _selectedImageBytes != null || _imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Обложка курса',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        if (hasImage) ...[
          // Показываем изображение
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Изображение
                  if (_selectedImageBytes != null)
                    Image.memory(
                      _selectedImageBytes!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else if (_imageUrl != null)
                    Image.network(
                      _imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Не удалось загрузить изображение',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  
                  // Кнопки управления
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Кнопка замены
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _pickImage,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            tooltip: 'Заменить изображение',
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Кнопка удаления
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _removeImage,
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'Удалить изображение',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // Зона загрузки
          GestureDetector(
            onTap: _isLoading ? null : _pickImage,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              color: _isLoading ? Colors.grey : Colors.deepPurple,
              strokeWidth: 2,
              dashPattern: const [8, 4],
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isLoading
                      ? Colors.grey.withOpacity(0.05)
                      : Colors.deepPurple.withOpacity(0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Загрузка изображения...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Нажмите для выбора изображения',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Камера • Галерея • Файлы',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Поддерживаются: JPG, PNG, WebP (макс. 5 МБ)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        
        if (_selectedFileName != null) ...[
          const SizedBox(height: 8),
          Text(
            'Выбран файл: $_selectedFileName',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  void _pickImage() {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      print('ImageUpload: Creating file input...');
      
      // Создаем HTML input элемент
      final html.InputElement input = html.InputElement(type: 'file');
      input.accept = 'image/*';
      input.capture = 'environment'; // Открывает камеру на мобильных
      
      input.onChange.listen((event) async {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          
          print('ImageUpload: File selected: ${file.name}, size: ${file.size}');
          
          // Проверяем размер файла (5 МБ максимум)
          if (file.size > 5 * 1024 * 1024) {
            _showError('Файл слишком большой. Максимальный размер: 5 МБ');
            setState(() => _isLoading = false);
            return;
          }
          
          // Проверяем тип файла
          if (!file.type.startsWith('image/')) {
            _showError('Выберите файл изображения');
            setState(() => _isLoading = false);
            return;
          }
          
          try {
            // Читаем файл
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);
            
            reader.onLoadEnd.listen((event) {
              if (reader.result != null) {
                final bytes = Uint8List.fromList(reader.result as List<int>);
                
                setState(() {
                  _selectedImageBytes = bytes;
                  _selectedFileName = file.name;
                  _imageUrl = null; // Убираем старую ссылку
                  _isLoading = false;
                });
                
                print('ImageUpload: Calling onImageSelected callback...');
                widget.onImageSelected(bytes, file.name);
                print('ImageUpload: Image selection completed successfully');
              } else {
                _showError('Не удалось прочитать файл');
                setState(() => _isLoading = false);
              }
            });
            
            reader.onError.listen((event) {
              _showError('Ошибка чтения файла');
              setState(() => _isLoading = false);
            });
            
          } catch (e) {
            print('ImageUpload: Error reading file: $e');
            _showError('Ошибка чтения файла: $e');
            setState(() => _isLoading = false);
          }
        } else {
          setState(() => _isLoading = false);
        }
      });
      
      // Программно кликаем на input
      input.click();
      
    } catch (e) {
      print('ImageUpload: Error creating input: $e');
      _showError('Ошибка выбора файла: $e');
      setState(() => _isLoading = false);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBytes = null;
      _selectedFileName = null;
      _imageUrl = null;
    });
    
    if (widget.onImageRemoved != null) {
      widget.onImageRemoved!();
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 