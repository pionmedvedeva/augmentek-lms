import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

class StorageService {
  FirebaseStorage? _storage;

  /// Получает экземпляр Firebase Storage с проверкой инициализации
  FirebaseStorage get _storageInstance {
    if (_storage != null) return _storage!;
    
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase не инициализирован');
    }
    
    _storage = FirebaseStorage.instance;
    return _storage!;
  }

  /// Загружает изображение курса и возвращает URL
  Future<String> uploadCourseImage({
    required String courseId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // Создаем уникальное имя файла
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final uniqueFileName = '${courseId}_${timestamp}$extension';
      
      // Путь в Storage
      final ref = _storageInstance.ref().child('course-images/$uniqueFileName');
      
      // Определяем MIME тип
      String contentType = 'image/jpeg';
      if (extension.toLowerCase() == '.png') {
        contentType = 'image/png';
      } else if (extension.toLowerCase() == '.webp') {
        contentType = 'image/webp';
      }
      
      print('Storage Service: Starting upload of $uniqueFileName');
      
      // Загружаем файл
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'courseId': courseId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Ждем завершения загрузки
      final snapshot = await uploadTask;
      
      // Получаем URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Storage Service: Upload successful, URL: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      print('Storage Service Error: $e');
      rethrow;
    }
  }

  /// Удаляет изображение курса по URL
  Future<void> deleteCourseImage(String imageUrl) async {
    try {
      final ref = _storageInstance.refFromURL(imageUrl);
      await ref.delete();
      print('Storage Service: Image deleted successfully');
    } catch (e) {
      // Не выбрасываем ошибку если файл не найден
      print('Storage Service: Failed to delete image: $e');
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
}); 