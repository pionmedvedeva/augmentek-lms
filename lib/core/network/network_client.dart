import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/env.dart';
import '../di/di.dart';
import '../error/error_handler.dart';

final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(
    ref.watch(loggerProvider),
  );
});

class NetworkClient {
  final Logger _logger;
  final _client = http.Client();
  final _baseUrl = Env.apiBaseUrl;
  final _apiVersion = Env.apiVersion;

  NetworkClient(this._logger);

  Future<Map<String, String>> _getHeaders() async {
    // TODO: Add authentication token
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Version': _apiVersion,
    };
  }

  String _buildUrl(String path) {
    return '$_baseUrl/$_apiVersion/$path';
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(path)).replace(
        queryParameters: queryParameters,
      );
      _logger.d('GET $uri');

      final response = await _client.get(
        uri,
        headers: await _getHeaders(),
      ).timeout(Env.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e, stack) {
      _logger.e('GET request failed', e, stack);
      if (e is TimeoutException) {
        throw NetworkError(
          message: 'Request timed out',
          code: 'TIMEOUT',
          originalError: e,
          stackTrace: stack,
        );
      }
      throw NetworkError(originalError: e, stackTrace: stack);
    }
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(path)).replace(
        queryParameters: queryParameters,
      );
      _logger.d('POST $uri');

      final response = await _client.post(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Env.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e, stack) {
      _logger.e('POST request failed', e, stack);
      if (e is TimeoutException) {
        throw NetworkError(
          message: 'Request timed out',
          code: 'TIMEOUT',
          originalError: e,
          stackTrace: stack,
        );
      }
      throw NetworkError(originalError: e, stackTrace: stack);
    }
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(path)).replace(
        queryParameters: queryParameters,
      );
      _logger.d('PUT $uri');

      final response = await _client.put(
        uri,
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Env.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e, stack) {
      _logger.e('PUT request failed', e, stack);
      if (e is TimeoutException) {
        throw NetworkError(
          message: 'Request timed out',
          code: 'TIMEOUT',
          originalError: e,
          stackTrace: stack,
        );
      }
      throw NetworkError(originalError: e, stackTrace: stack);
    }
  }

  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(path)).replace(
        queryParameters: queryParameters,
      );
      _logger.d('DELETE $uri');

      final response = await _client.delete(
        uri,
        headers: await _getHeaders(),
      ).timeout(Env.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e, stack) {
      _logger.e('DELETE request failed', e, stack);
      if (e is TimeoutException) {
        throw NetworkError(
          message: 'Request timed out',
          code: 'TIMEOUT',
          originalError: e,
          stackTrace: stack,
        );
      }
      throw NetworkError(originalError: e, stackTrace: stack);
    }
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic> json)? fromJson,
  ) {
    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson != null) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return fromJson(json);
      }
      return response.body as T;
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationError(
          message: 'Invalid request',
          originalError: response.body,
        );
      case 401:
        throw AuthenticationError(
          originalError: response.body,
        );
      case 403:
        throw AuthorizationError(
          originalError: response.body,
        );
      case 404:
        throw NotFoundError(
          originalError: response.body,
        );
      case 500:
        throw ServerError(
          originalError: response.body,
        );
      default:
        throw ServerError(
          message: 'Unexpected error occurred',
          originalError: response.body,
        );
    }
  }

  void dispose() {
    _client.close();
  }
} 