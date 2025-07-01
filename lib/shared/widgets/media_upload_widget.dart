import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/utils/app_logger.dart';
import '../../services/media_storage_service.dart';
import '../models/lesson.dart';

/// Универсальный виджет для загрузки медиафайлов
/// Поддерживает: изображения, видео, аудио, документы
class MediaUploadWidget extends StatefulWidget {
  final List<MediaType> allowedTypes;
  final List<MediaItem> initialMediaItems;
  final Function(List<MediaItem> mediaItems) onMediaChanged;
  final String title;
  final String? hint;
  final int? maxFiles;
  final String lessonId; // ID урока для организации файлов в Storage

  const MediaUploadWidget({
    super.key,
    this.allowedTypes = const [MediaType.image, MediaType.video, MediaType.audio, MediaType.document],
    this.initialMediaItems = const [],
    required this.onMediaChanged,
    required this.lessonId,
    this.title = 'Медиафайлы',
    this.hint,
    this.maxFiles,
  });

  @override
  State<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends State<MediaUploadWidget> {
  List<MediaItem> _mediaItems = [];
  List<PendingMediaItem> _pendingItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaItems = List.from(widget.initialMediaItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_canAddMore()) ...[
              IconButton(
                onPressed: _isLoading ? null : _pickFiles,
                icon: const Icon(Icons.add),
                tooltip: 'Добавить файлы',
              ),
            ],
          ],
        ),
        
        if (widget.hint != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.hint!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Список медиафайлов
        if (_mediaItems.isNotEmpty || _pendingItems.isNotEmpty) ...[
          ..._mediaItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildMediaCard(item, index);
          }),
          
          // Pending items (загружающиеся)
          ..._pendingItems.map((item) => _buildPendingCard(item)),
          
          const SizedBox(height: 16),
        ],
        
        // Зона добавления файлов
        if (_canAddMore() && _mediaItems.isEmpty && _pendingItems.isEmpty) ...[
          _buildUploadZone(),
        ],
        
          // Supported formats info
  if (_mediaItems.isEmpty && _pendingItems.isEmpty) ...[
    const SizedBox(height: 8),
    _buildSupportedFormats(),
  ],
  
  // Video upload progress info
  if (_isLoading && _pendingItems.isNotEmpty) ...[
    const SizedBox(height: 8),
    _buildVideoUploadInfo(),
  ],
      ],
    );
  }

  bool _canAddMore() {
    if (widget.maxFiles == null) return true;
    return (_mediaItems.length + _pendingItems.length) < widget.maxFiles!;
  }

  Widget _buildUploadZone() {
    return Column(
      children: [
        // Основная зона drag & drop
        GestureDetector(
          onTap: _isLoading ? null : _pickFiles,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            color: _isLoading ? Colors.grey : Colors.deepPurple,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            child: Container(
              height: 120,
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
                  Icon(
                    _getUploadIcon(),
                    size: 32,
                    color: _isLoading ? Colors.grey : Colors.deepPurple,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading ? 'Загрузка...' : 'Перетащите файлы или нажмите для выбора',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isLoading ? Colors.grey : Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Файлы до 500MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isLoading ? Colors.grey : Colors.deepPurple.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        

      ],
    );
  }

  Widget _buildMediaCard(MediaItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon по типу файла
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Информация о файле
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Медиафайл',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    '${_getTypeName(item.type)} • ${_formatFileSize(item.sizeBytes)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Действия
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Переместить вверх
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => _moveItem(index, index - 1),
                    iconSize: 20,
                  ),
                
                // Переместить вниз
                if (index < _mediaItems.length - 1)
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => _moveItem(index, index + 1),
                    iconSize: 20,
                  ),
                
                // Удалить
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(PendingMediaItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: item.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTypeColor(item.type),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Загрузка ${(item.progress * 100).toStringAsFixed(0)}% • ${_formatFileSize(item.bytes.length)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Отмена загрузки
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _cancelPendingItem(item),
                  iconSize: 20,
                ),
              ],
            ),
            
            // Линейный прогресс бар
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: item.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTypeColor(item.type),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedFormats() {
    final formats = <String>[];
    
    if (widget.allowedTypes.contains(MediaType.video)) {
      formats.add('Видео: MP4, WebM, MOV, AVI (до 500MB)');
    }
    if (widget.allowedTypes.contains(MediaType.image)) {
      formats.add('Изображения: JPG, PNG, GIF');
    }
    if (widget.allowedTypes.contains(MediaType.audio)) {
      formats.add('Аудио: MP3, WAV, AAC');
    }
    if (widget.allowedTypes.contains(MediaType.document)) {
      formats.add('Документы: PDF, DOC, TXT');
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Поддерживаемые форматы:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          ...formats.map((format) => Text(
            '• $format',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final input = html.FileUploadInputElement();
      input.multiple = widget.maxFiles != 1;
      input.accept = _getAcceptString();
      
      input.click();
      
      await input.onChange.first;
      
      if (input.files?.isNotEmpty == true) {
        for (final file in input.files!) {
          await _processFile(file);
        }
      }
    } catch (e) {
      AppLogger.error('Error picking files: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getAcceptString() {
    final accepts = <String>[];
    
    if (widget.allowedTypes.contains(MediaType.image)) {
      accepts.add('image/*');
    }
    if (widget.allowedTypes.contains(MediaType.video)) {
      accepts.add('video/*');
    }
    if (widget.allowedTypes.contains(MediaType.audio)) {
      accepts.add('audio/*');
    }
    if (widget.allowedTypes.contains(MediaType.document)) {
      accepts.addAll(['.pdf', '.doc', '.docx', '.txt']);
    }
    
    return accepts.join(',');
  }

  Future<void> _processFile(html.File file) async {
    try {
      // Определяем тип файла
      final mediaType = _getMediaTypeFromFile(file);
      if (mediaType == null) {
        AppLogger.warning('Unsupported file type: ${file.type}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неподдерживаемый тип файла: ${file.type}')),
        );
        return;
      }

      // Читаем файл
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      
      final bytes = reader.result as List<int>;
      
      // Добавляем в pending
      final pendingItem = PendingMediaItem(
        fileName: file.name,
        bytes: Uint8List.fromList(bytes),
        type: mediaType,
      );
      
      setState(() {
        _pendingItems.add(pendingItem);
      });
      
      // Загружаем в Firebase Storage
      final mediaItem = await MediaStorageService.uploadMediaFile(
        fileBytes: Uint8List.fromList(bytes),
        fileName: file.name,
        type: mediaType,
        lessonId: widget.lessonId,
        onProgress: (progress) {
          setState(() {
            pendingItem.progress = progress;
          });
          AppLogger.info('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );
      
      setState(() {
        _pendingItems.remove(pendingItem);
        _mediaItems.add(mediaItem.copyWith(order: _mediaItems.length));
      });
      
      widget.onMediaChanged(_mediaItems);
      
      AppLogger.info('Media file uploaded successfully: ${file.name}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Файл "${file.name}" загружен успешно')),
        );
      }
      
    } catch (e) {
      AppLogger.error('Error processing file: $e');
      
      // Удаляем из pending при ошибке
      setState(() {
        _pendingItems.removeWhere((item) => item.fileName == file.name);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки файла "${file.name}": $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  MediaType? _getMediaTypeFromFile(html.File file) {
    final type = file.type.toLowerCase();
    
    if (type.startsWith('image/') && widget.allowedTypes.contains(MediaType.image)) {
      return MediaType.image;
    }
    if (type.startsWith('video/') && widget.allowedTypes.contains(MediaType.video)) {
      return MediaType.video;
    }
    if (type.startsWith('audio/') && widget.allowedTypes.contains(MediaType.audio)) {
      return MediaType.audio;
    }
    if ((type.contains('pdf') || type.contains('document') || type.contains('text')) 
        && widget.allowedTypes.contains(MediaType.document)) {
      return MediaType.document;
    }
    
    return null;
  }

  void _moveItem(int from, int to) {
    setState(() {
      final item = _mediaItems.removeAt(from);
      _mediaItems.insert(to, item);
      
      // Обновляем order
      for (int i = 0; i < _mediaItems.length; i++) {
        _mediaItems[i] = _mediaItems[i].copyWith(order: i);
      }
    });
    
    widget.onMediaChanged(_mediaItems);
  }

  void _removeItem(int index) {
    setState(() {
      _mediaItems.removeAt(index);
      
      // Обновляем order
      for (int i = 0; i < _mediaItems.length; i++) {
        _mediaItems[i] = _mediaItems[i].copyWith(order: i);
      }
    });
    
    widget.onMediaChanged(_mediaItems);
  }

  void _cancelPendingItem(PendingMediaItem item) {
    setState(() {
      _pendingItems.remove(item);
    });
  }

  IconData _getUploadIcon() {
    if (widget.allowedTypes.length == 1) {
      switch (widget.allowedTypes.first) {
        case MediaType.image:
          return Icons.add_photo_alternate_outlined;
        case MediaType.video:
          return Icons.video_call_outlined;
        case MediaType.audio:
          return Icons.audiotrack_outlined;
        case MediaType.document:
          return Icons.description_outlined;
        case MediaType.youtube:
          return Icons.play_circle_outline;
      }
    }
    return Icons.attach_file_outlined;
  }

  IconData _getTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.video_file;
      case MediaType.audio:
        return Icons.audio_file;
      case MediaType.document:
        return Icons.description;
      case MediaType.youtube:
        return Icons.play_circle;
    }
  }

  Color _getTypeColor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return Colors.green;
      case MediaType.video:
        return Colors.blue;
      case MediaType.audio:
        return Colors.orange;
      case MediaType.document:
        return Colors.red;
      case MediaType.youtube:
        return Colors.purple;
    }
  }

  String _getTypeName(MediaType type) {
    switch (type) {
      case MediaType.image:
        return 'Изображение';
      case MediaType.video:
        return 'Видео';
      case MediaType.audio:
        return 'Аудио';
      case MediaType.document:
        return 'Документ';
      case MediaType.youtube:
        return 'YouTube';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildVideoUploadInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Загрузка больших видео',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Видео до 2GB загружаются в Firebase Storage с CDN доставкой. '
            'Оптимальный формат: MP4 (H.264), разрешение 720p-1080p.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Временный класс для файлов в процессе загрузки
class PendingMediaItem {
  final String fileName;
  final Uint8List bytes;
  final MediaType type;
  double progress;

  PendingMediaItem({
    required this.fileName,
    required this.bytes,
    required this.type,
    this.progress = 0.0,
  });
} 