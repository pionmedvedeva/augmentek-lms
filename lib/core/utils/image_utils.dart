/// Утилиты для работы с изображениями
class ImageUtils {
  // URL нашей Firebase Function для проксирования изображений
  static const String _proxyBaseUrl = 'https://europe-west1-augmentek-lms.cloudfunctions.net/imageProxy';
  
  /// Конвертирует Firebase Storage URL в proxy URL для обхода CORS
  static String getProxyImageUrl(String firebaseStorageUrl) {
    try {
      // Парсим Firebase Storage URL
      final uri = Uri.parse(firebaseStorageUrl);
      
      // Извлекаем путь к файлу из URL
      // Пример: /v0/b/bucket/o/path%2Fto%2Ffile.jpg -> path/to/file.jpg
      String? encodedPath = uri.pathSegments.last;
      if (encodedPath.startsWith('course-images')) {
        // URL уже содержит путь к файлу
        encodedPath = Uri.decodeComponent(encodedPath);
      } else {
        // Извлекаем из параметра 'o'
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 4 && pathSegments[2] == 'o') {
          encodedPath = pathSegments[3];
          encodedPath = Uri.decodeComponent(encodedPath);
        } else {
          // Fallback - используем исходный URL
          return firebaseStorageUrl;
        }
      }
      
      // Создаем proxy URL
      final proxyUrl = '$_proxyBaseUrl?path=${Uri.encodeComponent(encodedPath)}';
      
      return proxyUrl;
    } catch (e) {
      // В случае ошибки возвращаем исходный URL
      return firebaseStorageUrl;
    }
  }
  
  /// Проверяет является ли URL изображением Firebase Storage
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }
  
  /// Получает URL для отображения - proxy для Firebase Storage, иначе исходный
  static String getDisplayUrl(String imageUrl) {
    if (isFirebaseStorageUrl(imageUrl)) {
      return getProxyImageUrl(imageUrl);
    }
    return imageUrl;
  }
} 