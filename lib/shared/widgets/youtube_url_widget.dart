import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../models/lesson.dart';

/// Виджет для добавления YouTube видео в урок
class YouTubeUrlWidget extends StatefulWidget {
  final String? initialUrl;
  final Function(MediaItem? youtubeItem) onYouTubeChanged;
  final String title;
  
  const YouTubeUrlWidget({
    super.key,
    this.initialUrl,
    required this.onYouTubeChanged,
    this.title = 'YouTube видео',
  });

  @override
  State<YouTubeUrlWidget> createState() => _YouTubeUrlWidgetState();
}

class _YouTubeUrlWidgetState extends State<YouTubeUrlWidget> {
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  YoutubePlayerController? _youtubeController;
  bool _isValidUrl = false;
  String? _videoId;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    
    _urlController.addListener(_onUrlChanged);
    
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _validateAndSetupYouTube(widget.initialUrl!);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _clearYouTube();
      return;
    }
    
    _validateAndSetupYouTube(url);
  }

  void _validateAndSetupYouTube(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    
    if (videoId != null && videoId != _videoId) {
      setState(() {
        _videoId = videoId;
        _isValidUrl = true;
        _showPreview = false;
      });
      
      _youtubeController?.dispose();
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      
      // Если title пустой, попробуем установить заголовок
      if (_titleController.text.isEmpty) {
        _titleController.text = 'YouTube видео';
      }
      
      _notifyChange();
      
      AppLogger.info('YouTube video validated: $videoId');
    } else if (videoId == null) {
      setState(() {
        _isValidUrl = false;
        _videoId = null;
        _showPreview = false;
      });
      
      _youtubeController?.dispose();
      _youtubeController = null;
      
      widget.onYouTubeChanged(null);
      
      if (url.isNotEmpty) {
        AppLogger.warning('Invalid YouTube URL: $url');
      }
    }
  }

  void _clearYouTube() {
    setState(() {
      _isValidUrl = false;
      _videoId = null;
      _showPreview = false;
    });
    
    _youtubeController?.dispose();
    _youtubeController = null;
    _titleController.clear();
    _descriptionController.clear();
    
    widget.onYouTubeChanged(null);
  }

  void _notifyChange() {
    if (_isValidUrl && _videoId != null) {
      final mediaItem = MediaItem(
        id: 'youtube_$_videoId',
        type: MediaType.youtube,
        url: _urlController.text.trim(),
        title: _titleController.text.trim().isEmpty 
            ? 'YouTube видео' 
            : _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        thumbnailUrl: 'https://img.youtube.com/vi/$_videoId/maxresdefault.jpg',
        order: 0,
        createdAt: DateTime.now(),
      );
      
      widget.onYouTubeChanged(mediaItem);
    } else {
      widget.onYouTubeChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // URL input
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: 'Ссылка на YouTube видео',
            hintText: 'https://www.youtube.com/watch?v=...',
            border: const OutlineInputBorder(),
            suffixIcon: _urlController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _urlController.clear();
                      _clearYouTube();
                    },
                  )
                : null,
            prefixIcon: Icon(
              Icons.video_library,
              color: _isValidUrl ? Colors.green : Colors.grey,
            ),
          ),
          onChanged: (_) {}, // Обрабатывается через listener
        ),
        
        // URL validation status
        if (_urlController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _isValidUrl ? Icons.check_circle : Icons.error,
                size: 16,
                color: _isValidUrl ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                _isValidUrl 
                    ? 'Валидная ссылка YouTube' 
                    : 'Невалидная ссылка YouTube',
                style: TextStyle(
                  fontSize: 12,
                  color: _isValidUrl ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
        
        // Metadata inputs (показываем только для валидного URL)
        if (_isValidUrl) ...[
          const SizedBox(height: 16),
          
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Заголовок видео (необязательно)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _notifyChange(),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Описание видео (необязательно)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (_) => _notifyChange(),
          ),
          
          const SizedBox(height: 16),
          
          // Preview toggle
          Row(
            children: [
              Switch(
                value: _showPreview,
                onChanged: (value) {
                  setState(() {
                    _showPreview = value;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text('Показать предпросмотр'),
            ],
          ),
        ],
        
        // YouTube player preview
        if (_isValidUrl && _showPreview && _youtubeController != null) ...[
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                bottomActions: [
                  const SizedBox(width: 14.0),
                  CurrentPosition(),
                  const SizedBox(width: 8.0),
                  ProgressBar(isExpanded: true),
                  RemainingDuration(),
                  const PlaybackSpeedButton(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Video info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Предпросмотр видео',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _titleController.text.isEmpty 
                      ? 'YouTube видео' 
                      : _titleController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _descriptionController.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Video ID: $_videoId',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Help text
        if (!_isValidUrl && _urlController.text.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Поддерживаемые форматы:\n'
            '• https://www.youtube.com/watch?v=VIDEO_ID\n'
            '• https://youtu.be/VIDEO_ID\n'
            '• https://m.youtube.com/watch?v=VIDEO_ID',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
} 