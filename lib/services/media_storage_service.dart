import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/app_logger.dart';
import '../shared/models/media.dart';

/// Сервис для работы с медиафайлами в Firebase Storage
class MediaStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  /// Загружает медиафайл в Firebase Storage
  static Future<MediaItem> uploadMediaFile({
    required Uint8List fileBytes,
    required String fileName,
    required MediaType type,
    required String lessonId,
    String? title,
    String? description,
    Function(double progress)? onProgress,
  }) async {
    try {
      AppLogger.info('Starting media upload: $fileName (${fileBytes.length} bytes)');
      
      // Генерируем уникальное имя файла
      final fileId = _uuid.v4();
      final extension = _getFileExtension(fileName);
      final storageFileName = '${fileId}$extension';
      
      // Определяем путь в Storage
      final storagePath = _getStoragePath(type, lessonId, storageFileName);
      
      // Создаем референс
      final ref = _storage.ref().child(storagePath);
      
      // Определяем Content-Type
      final contentType = _getContentType(type, extension);
      
      // Настройки метаданных
      final metadata = {
        'contentType': contentType,
        'customMetadata': {
          'lessonId': lessonId,
          'originalFileName': fileName,
          'mediaType': type.name,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      };
      
      // Загружаем файл
      final uploadTask = ref.putData(fileBytes, SettableMetadata(
        contentType: contentType,
        customMetadata: metadata['customMetadata'] as Map<String, String>,
      ));
      
      // Отслеживаем прогресс
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Ждем завершения загрузки
      final snapshot = await uploadTask;
      
      // Получаем URL для скачивания
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Создаем MediaItem
      final mediaItem = MediaItem(
        id: fileId,
        type: type,
        url: downloadUrl,
        title: title ?? _getDefaultTitle(type, fileName),
        description: description,
        thumbnailUrl: type == MediaType.image ? downloadUrl : null,
        sizeBytes: fileBytes.length,
        order: 0, // Будет обновлен при сохранении урока
        createdAt: DateTime.now(),
      );
      
      AppLogger.info('Media uploaded successfully: $downloadUrl');
      
      return mediaItem;
      
    } catch (e) {
      AppLogger.error('Error uploading media file: $e');
      throw Exception('Ошибка загрузки файла: $e');
    }
  }

  /// Удаляет медиафайл из Firebase Storage
  static Future<void> deleteMediaFile(String url) async {
    try {
      AppLogger.info('Deleting media file: $url');
      
      // Получаем референс по URL
      final ref = _storage.refFromURL(url);
      
      // Удаляем файл
      await ref.delete();
      
      AppLogger.info('Media file deleted successfully');
      
    } catch (e) {
      AppLogger.error('Error deleting media file: $e');
      // Не бросаем исключение, так как файл может уже быть удален
    }
  }

  /// Удаляет все медиафайлы урока
  static Future<void> deleteAllLessonMedia(String lessonId) async {
    try {
      AppLogger.info('Deleting all media for lesson: $lessonId');
      
      // Удаляем файлы для каждого типа медиа
      for (final type in MediaType.values) {
        if (type == MediaType.youtube) continue; // YouTube не храним в Storage
        
        final folderPath = _getStoragePath(type, lessonId, '');
        await _deleteFolder(folderPath);
      }
      
      AppLogger.info('All lesson media deleted successfully');
      
    } catch (e) {
      AppLogger.error('Error deleting lesson media: $e');
    }
  }

  /// Получает информацию о медиафайле
  static Future<Map<String, dynamic>?> getMediaFileInfo(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      final metadata = await ref.getMetadata();
      
      return {
        'size': metadata.size,
        'contentType': metadata.contentType,
        'created': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
      
    } catch (e) {
      AppLogger.error('Error getting media file info: $e');
      return null;
    }
  }

  /// Генерирует thumbnail для видео (пока заглушка)
  static Future<String?> generateVideoThumbnail(String videoUrl) async {
    try {
      // TODO: Реализовать генерацию thumbnail для видео
      // Можно использовать video_thumbnail пакет или сервер-сайд функцию
      AppLogger.info('Video thumbnail generation requested for: $videoUrl');
      return null;
    } catch (e) {
      AppLogger.error('Error generating video thumbnail: $e');
      return null;
    }
  }

  /// Сжимает изображение для экономии места (пока заглушка)
  static Future<Uint8List> compressImage(Uint8List imageBytes) async {
    try {
      // TODO: Реализовать сжатие изображений
      // Можно использовать image пакет или сервер-сайд функцию
      AppLogger.info('Image compression requested (${imageBytes.length} bytes)');
      return imageBytes; // Пока возвращаем оригинал
    } catch (e) {
      AppLogger.error('Error compressing image: $e');
      return imageBytes;
    }
  }

  // === PRIVATE METHODS ===

  static String _getStoragePath(MediaType type, String lessonId, String fileName) {
    final typeFolder = type.name;
    return 'lessons/$lessonId/media/$typeFolder/$fileName';
  }

  static String _getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot);
  }

  static String _getContentType(MediaType type, String extension) {
    switch (type) {
      case MediaType.image:
        switch (extension.toLowerCase()) {
          case '.jpg':
          case '.jpeg':
            return 'image/jpeg';
          case '.png':
            return 'image/png';
          case '.gif':
            return 'image/gif';
          case '.webp':
            return 'image/webp';
          default:
            return 'image/jpeg';
        }
      
      case MediaType.video:
        switch (extension.toLowerCase()) {
          case '.mp4':
            return 'video/mp4';
          case '.avi':
            return 'video/avi';
          case '.mov':
            return 'video/quicktime';
          case '.webm':
            return 'video/webm';
          default:
            return 'video/mp4';
        }
      
      case MediaType.audio:
        switch (extension.toLowerCase()) {
          case '.mp3':
            return 'audio/mpeg';
          case '.wav':
            return 'audio/wav';
          case '.aac':
            return 'audio/aac';
          case '.ogg':
            return 'audio/ogg';
          default:
            return 'audio/mpeg';
        }
      
      case MediaType.document:
        switch (extension.toLowerCase()) {
          case '.pdf':
            return 'application/pdf';
          case '.doc':
            return 'application/msword';
          case '.docx':
            return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          case '.txt':
            return 'text/plain';
          default:
            return 'application/octet-stream';
        }
      
      case MediaType.youtube:
        return 'text/plain'; // YouTube не загружаем в Storage
    }
  }

  static String _getDefaultTitle(MediaType type, String fileName) {
    final nameWithoutExtension = fileName.contains('.') 
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    
    switch (type) {
      case MediaType.image:
        return 'Изображение: $nameWithoutExtension';
      case MediaType.video:
        return 'Видео: $nameWithoutExtension';
      case MediaType.audio:
        return 'Аудио: $nameWithoutExtension';
      case MediaType.document:
        return 'Документ: $nameWithoutExtension';
      case MediaType.youtube:
        return 'YouTube видео';
    }
  }

  static Future<void> _deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();
      
      // Удаляем все файлы в папке
      for (final item in listResult.items) {
        await item.delete();
      }
      
      // Рекурсивно удаляем подпапки
      for (final prefix in listResult.prefixes) {
        await _deleteFolder(prefix.fullPath);
      }
      
    } catch (e) {
      // Игнорируем ошибки - папка может не существовать
      AppLogger.warning('Could not delete folder $folderPath: $e');
    }
  }
} 