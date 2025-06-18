import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/env.dart';
import '../di/di.dart';

class StorageUtils {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getLocalFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  static Future<void> writeToFile(String fileName, String content) async {
    try {
      final file = await getLocalFile(fileName);
      await file.writeAsString(content);
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error writing to file', e, stack);
      rethrow;
    }
  }

  static Future<String> readFromFile(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      return await file.readAsString();
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error reading from file', e, stack);
      rethrow;
    }
  }

  static Future<void> deleteFile(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error deleting file', e, stack);
      rethrow;
    }
  }

  static Future<bool> fileExists(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      return await file.exists();
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error checking file existence', e, stack);
      rethrow;
    }
  }

  static Future<List<String>> listFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().toList();
      return files
          .where((entity) => entity is File)
          .map((file) => path.basename(file.path))
          .toList();
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error listing files', e, stack);
      rethrow;
    }
  }

  static Future<int> getFileSize(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error getting file size', e, stack);
      rethrow;
    }
  }

  static Future<DateTime> getFileLastModified(String fileName) async {
    try {
      final file = await getLocalFile(fileName);
      if (await file.exists()) {
        return await file.lastModified();
      }
      throw Exception('File does not exist');
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error getting file last modified', e, stack);
      rethrow;
    }
  }

  static Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().toList();
      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error clearing cache', e, stack);
      rethrow;
    }
  }

  static Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().toList();
      int totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error getting cache size', e, stack);
      rethrow;
    }
  }

  static Future<void> ensureCacheSize() async {
    try {
      final cacheSize = await getCacheSize();
      if (cacheSize > Env.maxCacheSize) {
        await clearCache();
      }
    } catch (e, stack) {
      final logger = ProviderContainer().read(loggerProvider);
      logger.e('Error ensuring cache size', e, stack);
      rethrow;
    }
  }
} 