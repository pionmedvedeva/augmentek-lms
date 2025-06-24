import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../di/di.dart';

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class NetworkError extends AppError {
  NetworkError({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? Env.networkErrorMessage,
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ServerError extends AppError {
  ServerError({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? Env.serverErrorMessage,
          code: code ?? 'SERVER_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ValidationError extends AppError {
  ValidationError({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class AuthenticationError extends AppError {
  AuthenticationError({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Authentication failed',
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class AuthorizationError extends AppError {
  AuthorizationError({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'You do not have permission to perform this action',
          code: code ?? 'AUTHZ_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class NotFoundError extends AppError {
  NotFoundError({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Resource not found',
          code: code ?? 'NOT_FOUND',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final logger = ProviderContainer().read(loggerProvider);
    logger.e('Error occurred: $error', stackTrace: stackTrace);

    String message;
    if (error is AppError) {
      message = error.message;
    } else {
      message = Env.unknownErrorMessage;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static Future<T> handleAsyncError<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } catch (e, stack) {
      handleError(context, e, stack);
      rethrow;
    }
  }
} 