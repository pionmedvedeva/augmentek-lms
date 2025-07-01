import '../core/utils/app_logger.dart';
import '../core/config/app_constants.dart';

class AvatarService {
  static const String _baseUrl = 'https://us-central1-augmentek-lms.cloudfunctions.net';
  
  /// Получает URL аватара для пользователя Telegram через proxy
  static Future<String?> getAvatarUrl(int userId) async {
    try {
      AppLogger.info('Requesting avatar for user: $userId');
      
      final uri = Uri.parse('$_baseUrl/getAvatarProxy?userId=$userId');
      
      // Возвращаем URL функции напрямую
      // CachedNetworkImage сам определит доступность и загрузит изображение
      AppLogger.info('Generated avatar URL for user: $userId');
      return uri.toString();
    } catch (e) {
      AppLogger.error('Error generating avatar URL for user $userId: $e');
      return null;
    }
  }
  
  /// Проверяет, является ли URL Telegram SVG аватаром
  static bool isTelegramSvgAvatar(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.contains('t.me/i/userpic') && url.endsWith('.svg');
  }
  
  /// Генерирует красивый цвет на основе имени пользователя для fallback
  static int generateColorFromUserId(int userId) {
    // Список красивых цветов для аватаров
    final colors = [
      0xFF4A90B8, // primaryBlue
      0xFFE8A87C, // accentOrange  
      0xFF6B73FF, // Purple
      0xFF10B981, // Green
      0xFFF59E0B, // Amber
      0xFFEF4444, // Red
      0xFF8B5CF6, // Violet
      0xFF06B6D4, // Cyan
      0xFFF97316, // Orange
      0xFF84CC16, // Lime
    ];
    
    // Используем userId для выбора цвета
    return colors[userId % colors.length];
  }
} 