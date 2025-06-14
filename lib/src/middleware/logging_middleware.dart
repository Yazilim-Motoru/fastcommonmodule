import '../common/model/fast_response.dart';
import 'base_middleware.dart';

/// Logging middleware for request/response logging
///
/// This middleware logs all requests, responses, and errors for debugging
/// and monitoring purposes.
class LoggingMiddleware extends BaseMiddleware {
  /// Function to log messages
  final void Function(String message, String level)? logger;

  /// Whether to log request details
  final bool logRequests;

  /// Whether to log response details
  final bool logResponses;

  /// Whether to log response data (can be verbose)
  final bool logResponseData;

  /// Whether to log request data (can contain sensitive information)
  final bool logRequestData;

  /// Creates a new logging middleware
  LoggingMiddleware({
    this.logger,
    this.logRequests = true,
    this.logResponses = true,
    this.logResponseData = false,
    this.logRequestData = false,
  });

  @override
  int get priority => 0; // Execute first

  @override
  Future<FastResponse<T>?> onRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    if (logRequests) {
      final message = StringBuffer();
      message.write('→ $method $endpoint');

      if (logRequestData && data != null) {
        message.write('\n  Data: $data');
      }

      if (headers != null && headers.isNotEmpty) {
        final filteredHeaders = Map<String, String>.from(headers);
        // Remove sensitive headers for logging
        filteredHeaders.removeWhere((key, value) =>
            key.toLowerCase().contains('authorization') ||
            key.toLowerCase().contains('token') ||
            key.toLowerCase().contains('password'));
        if (filteredHeaders.isNotEmpty) {
          message.write('\n  Headers: $filteredHeaders');
        }
      }

      _log(message.toString(), 'INFO');
    }

    return null; // Continue processing
  }

  @override
  Future<FastResponse<T>> onResponse<T>(
    FastResponse<T> response,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    if (logResponses) {
      final message = StringBuffer();
      message.write('← $method $endpoint');
      message.write(' [${response.success ? 'SUCCESS' : 'FAILURE'}]');

      if (!response.success) {
        message.write(
            '\n  Error: ${response.errorCode} - ${response.errorMessage}');
      }

      if (logResponseData) {
        if (response.success && response.data != null) {
          message.write('\n  Data: ${response.data}');
        }
        if (response.meta != null) {
          message.write('\n  Meta: ${response.meta}');
        }
      }

      _log(message.toString(), response.success ? 'INFO' : 'ERROR');
    }

    return response;
  }

  @override
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    _log('✗ $method $endpoint - ERROR: $error', 'ERROR');
    throw error; // Re-throw to let other middleware handle it
  }

  @override
  Future<void> onFinally(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    bool wasSuccessful,
  ) async {
    // Could log timing information here if needed
  }

  void _log(String message, String level) {
    if (logger != null) {
      logger!(message, level);
    } else {
      final timestamp = DateTime.now().toIso8601String();
      // ignore: avoid_print
      print('[$timestamp] [$level] $message');
    }
  }
}
