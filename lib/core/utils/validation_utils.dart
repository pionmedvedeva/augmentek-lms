import '../config/env.dart';
import 'string_utils.dart';

class ValidationUtils {
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!StringUtils.isEmail(value)) {
      return Env.invalidEmailMessage;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!StringUtils.isPasswordStrong(value)) {
      return Env.invalidPasswordMessage;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (value != password) {
      return Env.passwordMismatchMessage;
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!StringUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!StringUtils.isUrl(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!StringUtils.isCreditCard(value)) {
      return 'Please enter a valid credit card number';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (value.length < minLength) {
      return 'Must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (value.length > maxLength) {
      return 'Must be at most $maxLength characters';
    }
    return null;
  }

  static String? validateRange(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < min || number > max) {
      return 'Must be between $min and $max';
    }
    return null;
  }

  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validateAlphabetic(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Please enter only letters';
    }
    return null;
  }

  static String? validateAlphanumeric(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Please enter only letters and numbers';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    try {
      final parts = value.split(':');
      if (parts.length != 2) return 'Please enter a valid time';
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return 'Please enter a valid time';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid time';
    }
  }

  static String? validateDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return Env.requiredFieldMessage;
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date and time';
    }
  }
} 