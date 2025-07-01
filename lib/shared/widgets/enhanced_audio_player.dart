import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/app_logger.dart';

/// Продвинутый HTML5 аудио плеер для Telegram WebApp
/// Поддерживает .mp3, .wav, .m4a, .ogg форматы
class EnhancedAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String? title;
  final String? description;
  final bool autoPlay;
  final bool showControls;
  final Color? accentColor;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayEnd;
  final Function(Duration position, Duration duration)? onProgress;

  const EnhancedAudioPlayer({
    super.key,
    required this.audioUrl,
    this.title,
    this.description,
    this.autoPlay = false,
    this.showControls = true,
    this.accentColor,
    this.onPlayStart,
    this.onPlayEnd,
    this.onProgress,
  });

  @override
  State<EnhancedAudioPlayer> createState() => _EnhancedAudioPlayerState();
}

class _EnhancedAudioPlayerState extends State<EnhancedAudioPlayer> {
  late String _elementId;
  html.AudioElement? _audioElement;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _elementId = 'audio-player-${const Uuid().v4()}';
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    try {
      AppLogger.info('🔊 Initializing audio player for: ${widget.audioUrl}');
      
      _audioElement = html.AudioElement()
        ..src = widget.audioUrl
        ..controls = false // Мы создаем свои контролы
        ..preload = 'metadata'
        ..id = _elementId;

      // Регистрируем элемент в DOM
      ui_web.platformViewRegistry.registerViewFactory(
        _elementId,
        (int viewId) => _audioElement!,
      );

      _setupAudioListeners();
      
      if (widget.autoPlay) {
        _play();
      }
      
    } catch (e) {
      AppLogger.error('❌ Error initializing audio player: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Ошибка инициализации: $e';
      });
    }
  }

  void _setupAudioListeners() {
    if (_audioElement == null) return;

    // Событие загрузки метаданных
    _audioElement!.onLoadedMetadata.listen((_) {
      if (mounted) {
        setState(() {
          _totalDuration = Duration(seconds: _audioElement!.duration!.toInt());
          _isLoading = false;
          _hasError = false;
        });
        AppLogger.info('🔊 Audio metadata loaded: ${_totalDuration.inSeconds}s');
      }
    });

    // Событие начала воспроизведения
    _audioElement!.onPlay.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
        widget.onPlayStart?.call();
        AppLogger.info('🔊 Audio playback started');
      }
    });

    // Событие паузы
    _audioElement!.onPause.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        AppLogger.info('🔊 Audio playback paused');
      }
    });

    // Событие завершения
    _audioElement!.onEnded.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        widget.onPlayEnd?.call();
        AppLogger.info('🔊 Audio playback ended');
      }
    });

    // Обновление времени воспроизведения
    _audioElement!.onTimeUpdate.listen((_) {
      if (mounted && _audioElement!.currentTime != null) {
        final position = Duration(seconds: _audioElement!.currentTime!.toInt());
        setState(() {
          _currentPosition = position;
        });
        widget.onProgress?.call(position, _totalDuration);
      }
    });

    // Событие ошибки
    _audioElement!.onError.listen((event) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Ошибка загрузки аудио';
          _isLoading = false;
          _isPlaying = false;
        });
        AppLogger.error('❌ Audio playback error: $event');
      }
    });

    // Событие начала загрузки
    _audioElement!.onLoadedData.listen((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    });
  }

  void _play() {
    if (_audioElement != null && !_hasError) {
      try {
        _audioElement!.play();
      } catch (e) {
        AppLogger.error('❌ Error playing audio: $e');
        setState(() {
          _hasError = true;
          _errorMessage = 'Ошибка воспроизведения: $e';
        });
      }
    }
  }

  void _pause() {
    if (_audioElement != null) {
      _audioElement!.pause();
    }
  }

  void _stop() {
    if (_audioElement != null) {
      _audioElement!.pause();
      _audioElement!.currentTime = 0;
      setState(() {
        _currentPosition = Duration.zero;
      });
    }
  }

  void _seek(double position) {
    if (_audioElement != null && _totalDuration.inSeconds > 0) {
      final seconds = (position * _totalDuration.inSeconds).toInt();
      _audioElement!.currentTime = seconds.toDouble();
    }
  }

  void _setVolume(double volume) {
    if (_audioElement != null) {
      _audioElement!.volume = volume;
      setState(() {
        _volume = volume;
        _isMuted = volume == 0;
      });
    }
  }

  void _toggleMute() {
    if (_audioElement != null) {
      if (_isMuted) {
        _setVolume(_volume == 0 ? 1.0 : _volume);
      } else {
        _setVolume(0.0);
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioElement?.pause();
    _audioElement?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.primaryColor;

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и описание
            if (widget.title != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.audiotrack,
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (widget.description != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Состояние ошибки
            if (_hasError) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage ?? 'Ошибка воспроизведения',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Плеер
            if (!_hasError) ...[
              // Прогресс-бар
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _totalDuration.inSeconds > 0
                              ? (_currentPosition.inSeconds / _totalDuration.inSeconds).clamp(0.0, 1.0)
                              : 0.0,
                          onChanged: _seek,
                          activeColor: accentColor,
                          inactiveColor: Colors.grey[300],
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Контролы
              if (widget.showControls) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Кнопка стоп
                    IconButton(
                      onPressed: _isLoading ? null : _stop,
                      icon: const Icon(Icons.stop),
                      color: Colors.grey[600],
                    ),

                    const SizedBox(width: 16),

                    // Кнопка воспроизведения/паузы
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : (_isPlaying ? _pause : _play),
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                        iconSize: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Кнопка громкости
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                      ),
                      color: Colors.grey[600],
                    ),

                    // Слайдер громкости
                    SizedBox(
                      width: 60,
                      child: Slider(
                        value: _isMuted ? 0.0 : _volume,
                        onChanged: _setVolume,
                        activeColor: accentColor,
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Скрытый HTML5 Audio элемент (не отображается)
            if (!_hasError) ...[
              SizedBox(
                width: 0,
                height: 0,
                child: HtmlElementView(viewType: _elementId),
              ),
            ],
          ],
        ),
      ),
    );
  }
}