import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/fast_response.dart';
import '../../middleware/fast_middleware_manager.dart';
import '../../middleware/base_middleware.dart';

/// FastApiClient is a generic, reusable API client for RESTful endpoints.
///
/// Usage:
/// ```dart
/// final client = FastApiClient(baseUrl: 'https://api.example.com');
/// final response = await client.get('/users');
/// ```
class FastApiClient {
  /// The base URL for all API requests.
  final String baseUrl;

  /// Optional default headers for all requests.
  final Map<String, String> defaultHeaders;

  /// Optional function to provide auth token/header dynamically.
  final Future<String?> Function()? getAuthToken;

  /// Middleware manager for handling request/response interception
  final FastMiddlewareManager _middlewareManager = FastMiddlewareManager();

  /// Creates a [FastApiClient] instance.
  FastApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.getAuthToken,
  });

  /// Adds a middleware to the client
  void addMiddleware(BaseMiddleware middleware) {
    _middlewareManager.addMiddleware(middleware);
  }

  /// Removes a middleware from the client
  void removeMiddleware(BaseMiddleware middleware) {
    _middlewareManager.removeMiddleware(middleware);
  }

  /// Removes all middlewares of a specific type
  void removeMiddlewareOfType<T extends BaseMiddleware>() {
    _middlewareManager.removeMiddlewareOfType<T>();
  }

  /// Gets all registered middlewares
  List<BaseMiddleware> get middlewares => _middlewareManager.middlewares;

  /// Clears all middlewares
  void clearMiddlewares() {
    _middlewareManager.clear();
  }

  /// Generic GET request.
  Future<FastResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _executeRequest<T>(
      'GET',
      path,
      headers: headers,
      fromJson: fromJson,
    );
  }

  /// Generic POST request.
  Future<FastResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _executeRequest<T>(
      'POST',
      path,
      body: body,
      headers: headers,
      fromJson: fromJson,
    );
  }

  /// Generic PUT request.
  Future<FastResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _executeRequest<T>(
      'PUT',
      path,
      body: body,
      headers: headers,
      fromJson: fromJson,
    );
  }

  /// Generic DELETE request.
  Future<FastResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    return _executeRequest<T>(
      'DELETE',
      path,
      headers: headers,
      fromJson: fromJson,
    );
  }

  /// Execute a request with middleware integration
  Future<FastResponse<T>> _executeRequest<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final data = body != null ? {'body': body} : null;
    bool wasSuccessful = false;

    try {
      // Execute request middleware
      final shortCircuitResponse = await _middlewareManager.executeRequest<T>(
        method,
        path,
        data,
        headers,
      );

      if (shortCircuitResponse != null) {
        wasSuccessful = shortCircuitResponse.success;
        await _middlewareManager.executeFinally(
            method, path, data, wasSuccessful);
        return shortCircuitResponse;
      }

      // Execute the actual HTTP request
      final response = await _performHttpRequest<T>(
        method,
        path,
        body: body,
        headers: headers,
        fromJson: fromJson,
      );

      wasSuccessful = response.success;

      // Execute response middleware
      final processedResponse = await _middlewareManager.executeResponse<T>(
        response,
        method,
        path,
        data,
      );

      await _middlewareManager.executeFinally(
          method, path, data, wasSuccessful);
      return processedResponse;
    } catch (e) {
      wasSuccessful = false;

      try {
        // Execute error middleware
        final errorResponse = await _middlewareManager.executeError<T>(
          e is Exception ? e : Exception(e.toString()),
          method,
          path,
          data,
        );

        await _middlewareManager.executeFinally(
            method, path, data, wasSuccessful);
        return errorResponse;
      } catch (middlewareError) {
        await _middlewareManager.executeFinally(
            method, path, data, wasSuccessful);
        rethrow;
      }
    }
  }

  /// Perform the actual HTTP request
  Future<FastResponse<T>> _performHttpRequest<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _buildHeaders(headers);

    http.Response res;

    switch (method.toUpperCase()) {
      case 'GET':
        res = await http.get(uri, headers: mergedHeaders);
        break;
      case 'POST':
        res = await http.post(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PUT':
        res = await http.put(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: mergedHeaders);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    return _handleResponse<T>(res, fromJson);
  }

  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? headers) async {
    final merged = {...defaultHeaders, if (headers != null) ...headers};
    if (getAuthToken != null) {
      final token = await getAuthToken!();
      if (token != null && token.isNotEmpty) {
        merged['Authorization'] = 'Bearer $token';
      }
    }
    merged['Content-Type'] = 'application/json';
    return merged;
  }

  FastResponse<T> _handleResponse<T>(
      http.Response res, T Function(dynamic)? fromJson) {
    try {
      final data = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (fromJson != null && data != null) {
          return FastResponse<T>.success(fromJson(data));
        } else {
          return FastResponse<T>.success(data as T);
        }
      } else {
        return FastResponse<T>.failure(
          errorMessage: data is Map && data['message'] != null
              ? data['message']
              : 'API error',
          errorCode: data is Map && data['code'] != null
              ? data['code'].toString()
              : null,
          meta: data is Map<String, dynamic> ? data : null,
        );
      }
    } catch (e) {
      return FastResponse<T>.failure(errorMessage: 'Invalid response: $e');
    }
  }
}
