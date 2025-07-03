import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/app_logger.dart';

/// Продвинутый HTML5 видеоплеер для Telegram WebApp
/// Поддерживает .mp4, .webm, .mov, .avi
class EnhancedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? description;
  final bool autoPlay;
  final bool showControls;
  final Color? accentColor;

  const EnhancedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.title,
    this.description,
    this.autoPlay = false,
    this.showControls = true,
    this.accentColor,
  });

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  late String _elementId;
  html.VideoElement? _videoElement;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _elementId = 'video-player-${const Uuid().v4()}';
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    try {
      AppLogger.info('🎬 Initializing video player for: ${widget.videoUrl}');
      _videoElement = html.VideoElement()
        ..src = widget.videoUrl
        ..controls = false // Кастомные контролы
        ..preload = 'metadata'
        ..id = _elementId
        ..style.borderRadius = '12px';

      // Регистрируем элемент в DOM
      ui_web.platformViewRegistry.registerViewFactory(
        _elementId,
        (int viewId) => _videoElement!,
      );

      _setupVideoListeners();

      if (widget.autoPlay) {
        _play();
      }
    } catch (e) {
      AppLogger.error('❌ Error initializing video player: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка инициализации: $e';
      });
    }
  }

  void _setupVideoListeners() {
    if (_videoElement == null) return;

    _videoElement!.onLoadedMetadata.listen((_) {
      if (mounted) {
        setState(() {
          _totalDuration = Duration(milliseconds: (_videoElement!.duration * 1000).toInt());
          _isLoading = false;
          _hasError = false;
        });
        AppLogger.info('🎬 Video metadata loaded: ${_totalDuration.inSeconds}s');
      }
    });

    _videoElement!.onPlay.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
        AppLogger.info('🎬 Video playback started');
      }
    });

    _videoElement!.onPause.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        AppLogger.info('🎬 Video playback paused');
      }
    });

    _videoElement!.onEnded.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        AppLogger.info('🎬 Video playback ended');
      }
    });

    _videoElement!.onTimeUpdate.listen((_) {
      if (mounted && _videoElement!.currentTime != null) {
        final position = Duration(milliseconds: (_videoElement!.currentTime! * 1000).toInt());
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _videoElement!.onError.listen((event) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Ошибка загрузки видео';
          _isLoading = false;
          _isPlaying = false;
        });
        AppLogger.error('❌ Video playback error: $event');
      }
    });

    _videoElement!.onLoadedData.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    });
  }

  void _play() {
    if (_videoElement != null && !_hasError) {
      try {
        _videoElement!.play();
      } catch (e) {
        AppLogger.error('❌ Error playing video: $e');
        setState(() {
          _hasError = true;
          _errorMessage = 'Ошибка воспроизведения: $e';
        });
      }
    }
  }

  void _pause() {
    if (_videoElement != null) {
      _videoElement!.pause();
    }
  }

  void _seek(double position) {
    if (_videoElement != null) {
      _videoElement!.currentTime = position;
      setState(() {
        _currentPosition = Duration(milliseconds: (position * 1000).toInt());
      });
    }
  }

  void _toggleMute() {
    if (_videoElement != null) {
      setState(() {
        _isMuted = !_isMuted;
        _videoElement!.muted = _isMuted;
      });
    }
  }

  void _setVolume(double value) {
    if (_videoElement != null) {
      setState(() {
        _volume = value;
        _videoElement!.volume = value;
      });
    }
  }

  void _toggleFullscreen() {
    if (_videoElement != null) {
      _videoElement!.requestFullscreen();
      setState(() {
        _isFullscreen = true;
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildError(_errorMessage ?? 'Ошибка видео');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                HtmlElementView(viewType: _elementId),
                if (widget.showControls) _buildControls(),
              ],
            ),
          ),
        ),
        if (widget.title != null || widget.description != null) ...[
          const SizedBox(height: 12),
          _buildVideoInfo(),
        ],
      ],
    );
  }

  Widget _buildControls() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(0.25),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                onPressed: _isPlaying ? _pause : _play,
              ),
              Text(
                _formatDuration(_currentPosition),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  min: 0,
                  max: _totalDuration.inSeconds.toDouble().clamp(1, double.infinity),
                  onChanged: (value) => _seek(value),
                  activeColor: widget.accentColor ?? Colors.blue,
                  inactiveColor: Colors.white24,
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                onPressed: _toggleMute,
              ),
              SizedBox(
                width: 60,
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) => _setVolume(value),
                  activeColor: widget.accentColor ?? Colors.blue,
                  inactiveColor: Colors.white24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          if (widget.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.description!,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
} 