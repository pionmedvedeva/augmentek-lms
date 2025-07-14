import 'dart:math';

class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map(capitalize).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  static String formatPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return phoneNumber;
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return email;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  static String maskPhoneNumber(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return phoneNumber;
    return '(${digits.substring(0, 3)}) ***-${digits.substring(6)}';
  }

  static String maskCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return cardNumber;
    return '**** **** **** ${digits.substring(12)}';
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static String generateRandomPassword({
    int length = 12,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
  }) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    var chars = lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecialChars) chars += special;

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static bool isEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  static bool isPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phoneNumber);
  }

  static bool isUrl(String url) {
    return RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    ).hasMatch(url);
  }

  static bool isCreditCard(String cardNumber) {
    return RegExp(r'^\d{16}$').hasMatch(cardNumber);
  }

  static bool isPasswordStrong(String password) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(password);
  }
}

/// Склонение числительных с существительными в русском языке
class RussianPlurals {
  /// Склонение для пользователей
  static String users(int count) {
    return _pluralize(count, 'пользователь', 'пользователя', 'пользователей');
  }

  /// Склонение для студентов
  static String students(int count) {
    return _pluralize(count, 'студент', 'студента', 'студентов');
  }

  /// Склонение для курсов
  static String courses(int count) {
    return _pluralize(count, 'курс', 'курса', 'курсов');
  }

  /// Склонение для уроков
  static String lessons(int count) {
    return _pluralize(count, 'урок', 'урока', 'уроков');
  }

  /// Склонение для разделов
  static String sections(int count) {
    return _pluralize(count, 'раздел', 'раздела', 'разделов');
  }

  /// Форматирование числа с правильным склонением для пользователей
  static String formatUsers(int count) {
    return '$count ${users(count)}';
  }

  /// Форматирование числа с правильным склонением для студентов
  static String formatStudents(int count) {
    return '$count ${students(count)}';
  }

  /// Форматирование числа с правильным склонением для курсов
  static String formatCourses(int count) {
    return '$count ${courses(count)}';
  }

  /// Форматирование числа с правильным склонением для уроков
  static String formatLessons(int count) {
    return '$count ${lessons(count)}';
  }

  /// Форматирование числа с правильным склонением для разделов
  static String formatSections(int count) {
    return '$count ${sections(count)}';
  }

  /// Базовая функция склонения
  /// [one] - для 1 (1 пользователь)
  /// [few] - для 2-4 (2 пользователя)
  /// [many] - для 0, 5+ (5 пользователей)
  static String _pluralize(int count, String one, String few, String many) {
    final absCount = count.abs();
    
    // Исключения для чисел 11-14
    if (absCount % 100 >= 11 && absCount % 100 <= 14) {
      return many;
    }
    
    final lastDigit = absCount % 10;
    
    if (lastDigit == 1) {
      return one;
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return few;
    } else {
      return many;
    }
  }
} 