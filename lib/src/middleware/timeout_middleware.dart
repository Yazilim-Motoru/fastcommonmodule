import 'dart:async';
import '../common/model/fast_response.dart';
import '../common/model/fast_exception.dart';
import 'base_middleware.dart';

/// Timeout middleware for request timeout handling
///
/// This middleware enforces timeout limits on requests and provides
/// configurable timeout durations for different types of operations.
class TimeoutMiddleware extends BaseMiddleware {
  /// Default timeout duration
  final Duration defaultTimeout;

  /// Timeout durations for specific HTTP methods
  final Map<String, Duration> methodTimeouts;

  /// Timeout durations for specific endpoints (path patterns)
  final Map<String, Duration> endpointTimeouts;

  /// Creates a new timeout middleware
  TimeoutMiddleware({
    this.defaultTimeout = const Duration(seconds: 30),
    this.methodTimeouts = const {},
    this.endpointTimeouts = const {},
  });

  @override
  int get priority => 100; // Execute early but after logging

  /// Gets the appropriate timeout for a request
  Duration _getTimeoutForRequest(String method, String endpoint) {
    // Check for endpoint-specific timeout first
    for (final entry in endpointTimeouts.entries) {
      if (endpoint.contains(entry.key)) {
        return entry.value;
      }
    }

    // Check for method-specific timeout
    if (methodTimeouts.containsKey(method.toUpperCase())) {
      return methodTimeouts[method.toUpperCase()]!;
    }

    // Use default timeout
    return defaultTimeout;
  }

  /// Wraps a future with timeout logic
  Future<T> _withTimeout<T>(
    Future<T> future,
    Duration timeout,
    String method,
    String endpoint,
  ) async {
    try {
      return await future.timeout(timeout);
    } on TimeoutException {
      throw FastException(
        'Request timed out after ${timeout.inMilliseconds}ms',
        code: 'REQUEST_TIMEOUT',
        details: {
          'timeout_ms': timeout.inMilliseconds,
          'method': method,
          'endpoint': endpoint,
        },
        path: '$method $endpoint',
        className: 'TimeoutMiddleware',
        method: '_withTimeout',
      );
    }
  }

  @override
  Future<FastResponse<T>?> onRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    // Store timeout information in headers for reference
    final timeout = _getTimeoutForRequest(method, endpoint);
    final timeoutHeaders = Map<String, String>.from(headers ?? {});
    timeoutHeaders['X-Request-Timeout'] = timeout.inMilliseconds.toString();

    return null; // Continue with request
  }

  @override
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    // Handle timeout errors specifically
    if (error is FastException && error.code == 'REQUEST_TIMEOUT') {
      return FastResponse<T>.failure(
        errorCode: 'TIMEOUT',
        errorMessage: error.message,
        meta: {
          'method': method,
          'endpoint': endpoint,
          'timestamp': DateTime.now().toIso8601String(),
          'error_type': 'timeout',
          ...?error.details,
        },
      );
    }

    throw error; // Re-throw other errors
  }

  /// Execute a request with timeout
  /// This method would be used by the API client
  Future<FastResponse<T>> executeWithTimeout<T>(
    Future<FastResponse<T>> Function() requestFunction,
    String method,
    String endpoint,
  ) async {
    final timeout = _getTimeoutForRequest(method, endpoint);

    try {
      return await _withTimeout(
        requestFunction(),
        timeout,
        method,
        endpoint,
      );
    } catch (e) {
      if (e is FastException) {
        throw e;
      }
      throw FastException(
        'Request failed: ${e.toString()}',
        code: 'REQUEST_ERROR',
        details: {'original_error': e.toString()},
        path: '$method $endpoint',
        className: 'TimeoutMiddleware',
        method: 'executeWithTimeout',
      );
    }
  }

  /// Helper method to create timeout middleware with common configurations
  static TimeoutMiddleware create({
    Duration? defaultTimeout,
    Duration? getTimeout,
    Duration? postTimeout,
    Duration? putTimeout,
    Duration? deleteTimeout,
    Duration? uploadTimeout,
    Duration? downloadTimeout,
  }) {
    final methodTimeouts = <String, Duration>{};

    if (getTimeout != null) methodTimeouts['GET'] = getTimeout;
    if (postTimeout != null) methodTimeouts['POST'] = postTimeout;
    if (putTimeout != null) methodTimeouts['PUT'] = putTimeout;
    if (deleteTimeout != null) methodTimeouts['DELETE'] = deleteTimeout;

    final endpointTimeouts = <String, Duration>{};

    if (uploadTimeout != null) {
      endpointTimeouts['/upload'] = uploadTimeout;
      endpointTimeouts['/file'] = uploadTimeout;
    }

    if (downloadTimeout != null) {
      endpointTimeouts['/download'] = downloadTimeout;
    }

    return TimeoutMiddleware(
      defaultTimeout: defaultTimeout ?? const Duration(seconds: 30),
      methodTimeouts: methodTimeouts,
      endpointTimeouts: endpointTimeouts,
    );
  }
}
