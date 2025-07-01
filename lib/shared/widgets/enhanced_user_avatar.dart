import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/app_logger.dart';
import '../../services/avatar_service.dart';
import '../../shared/models/user.dart';

class EnhancedUserAvatar extends StatefulWidget {
  final AppUser user;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const EnhancedUserAvatar({
    super.key,
    required this.user,
    this.radius = 24,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  State<EnhancedUserAvatar> createState() => _EnhancedUserAvatarState();
}

class _EnhancedUserAvatarState extends State<EnhancedUserAvatar> {
  String? _realAvatarUrl;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRealAvatar();
  }

  @override
  void didUpdateWidget(EnhancedUserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.id != widget.user.id) {
      _loadRealAvatar();
    }
  }

  Future<void> _loadRealAvatar() async {
    // Для всех Telegram пользователей используем только Bot API proxy
    // Это избегает CORS ошибок и гарантирует получение реальных аватаров
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final avatarUrl = await AvatarService.getAvatarUrl(widget.user.id);
      
      if (mounted) {
        setState(() {
          _realAvatarUrl = avatarUrl;
          _isLoading = false;
          _hasError = avatarUrl == null;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load avatar for user ${widget.user.id}: $e');
      
      if (mounted) {
        setState(() {
          _realAvatarUrl = null;
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackColor = widget.backgroundColor ?? 
      Color(AvatarService.generateColorFromUserId(widget.user.id));
    
    final fallbackTextStyle = widget.textStyle ?? TextStyle(
      color: Colors.white,
      fontSize: widget.radius * 0.75,
      fontWeight: FontWeight.bold,
    );

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: fallbackColor,
      child: ClipOval(
        child: _buildAvatarContent(fallbackColor, fallbackTextStyle),
      ),
    );
  }

  Widget _buildAvatarContent(Color fallbackColor, TextStyle fallbackTextStyle) {
    // Показываем загрузку
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    // Если есть реальный URL аватара, показываем его
    if (_realAvatarUrl != null && _realAvatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _realAvatarUrl!,
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) {
          AppLogger.warning('Real avatar loading failed for ${widget.user.firstName}: $error');
          return _buildInitialsAvatar(fallbackColor, fallbackTextStyle);
        },
      );
    }

    // Fallback на инициалы
    return _buildInitialsAvatar(fallbackColor, fallbackTextStyle);
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: widget.radius * 0.6,
          height: widget.radius * 0.6,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(Color backgroundColor, TextStyle textStyle) {
    final initial = _getInitial(widget.user.firstName);
    
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: textStyle.copyWith(
            color: _getContrastColor(backgroundColor),
          ),
        ),
      ),
    );
  }

  /// Получает первую букву имени или 'U' если имя пустое
  String _getInitial(String name) {
    if (name.isEmpty) return 'U';
    
    final firstChar = name.trim()[0].toUpperCase();
    
    if (RegExp(r'[A-Za-zА-Яа-я]').hasMatch(firstChar)) {
      return firstChar;
    }
    
    return 'U';
  }

  /// Определяет контрастный цвет текста для фона
  Color _getContrastColor(Color backgroundColor) {
    final brightness = (backgroundColor.red * 299 + 
                      backgroundColor.green * 587 + 
                      backgroundColor.blue * 114) / 1000;
    
    return brightness > 128 ? const Color(0xFF1F2937) : Colors.white;
  }
} 