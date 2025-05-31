import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/fast_response.dart';

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

  FastApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.getAuthToken,
  });

  /// Generic GET request.
  Future<FastResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _buildHeaders(headers);
    final res = await http.get(uri, headers: mergedHeaders);
    return _handleResponse<T>(res, fromJson);
  }

  /// Generic POST request.
  Future<FastResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _buildHeaders(headers);
    final res = await http.post(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse<T>(res, fromJson);
  }

  /// Generic PUT request.
  Future<FastResponse<T>> put<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _buildHeaders(headers);
    final res = await http.put(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse<T>(res, fromJson);
  }

  /// Generic DELETE request.
  Future<FastResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _buildHeaders(headers);
    final res = await http.delete(uri, headers: mergedHeaders);
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
