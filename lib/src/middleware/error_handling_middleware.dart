import '../common/model/fast_response.dart';
import '../common/model/fast_exception.dart';
import 'base_middleware.dart';

/// Error handling middleware for global error management
///
/// This middleware provides centralized error handling, logging,
/// and response formatting for all service operations.
class ErrorHandlingMiddleware extends BaseMiddleware {
  /// Function to log errors
  final void Function(FastException error, String context)? onErrorLogged;

  /// Function to transform errors before response
  final FastException Function(Exception error, String context)?
      errorTransformer;

  /// Whether to include stack traces in error responses
  final bool includeStackTrace;

  /// Whether to log all errors
  final bool logErrors;

  /// Creates a new error handling middleware with the specified configuration
  ErrorHandlingMiddleware({
    this.onErrorLogged,
    this.errorTransformer,
    this.includeStackTrace = false,
    this.logErrors = true,
  });

  @override
  int get priority => 1000; // Execute last for error handling

  @override
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    final context = '$method $endpoint';

    // Transform the error if transformer is provided
    FastException fastError;
    if (error is FastException) {
      fastError = error;
    } else {
      fastError = errorTransformer?.call(error, context) ??
          _defaultErrorTransformer(error, context);
    }

    // Log the error if logging is enabled
    if (logErrors) {
      onErrorLogged?.call(fastError, context);
      _defaultErrorLogger(fastError, context);
    }

    // Create error response
    return FastResponse<T>.failure(
      errorCode: fastError.code,
      errorMessage: fastError.message,
      meta: {
        'method': method,
        'endpoint': endpoint,
        'timestamp': DateTime.now().toIso8601String(),
        if (fastError.details != null) 'details': fastError.details,
        if (fastError.path != null) 'path': fastError.path,
        if (fastError.className != null) 'className': fastError.className,
        if (fastError.method != null) 'methodName': fastError.method,
      },
    );
  }

  /// Default error transformer
  FastException _defaultErrorTransformer(Exception error, String context) {
    if (error is ArgumentError) {
      return FastException(
        'Invalid argument: ${error.toString()}',
        code: 'INVALID_ARGUMENT',
        details: {'error': error.toString()},
        path: context,
        className: 'ErrorHandlingMiddleware',
        method: '_defaultErrorTransformer',
      );
    }

    if (error is StateError) {
      return FastException(
        'Invalid state: ${error.toString()}',
        code: 'INVALID_STATE',
        path: context,
        className: 'ErrorHandlingMiddleware',
        method: '_defaultErrorTransformer',
      );
    }

    if (error is FormatException) {
      return FastException(
        'Format error: ${error.message}',
        code: 'FORMAT_ERROR',
        details: {'source': error.source, 'offset': error.offset},
        path: context,
        className: 'ErrorHandlingMiddleware',
        method: '_defaultErrorTransformer',
      );
    }

    // Generic error fallback
    return FastException(
      'An unexpected error occurred: ${error.toString()}',
      code: 'INTERNAL_ERROR',
      path: context,
      className: 'ErrorHandlingMiddleware',
      method: '_defaultErrorTransformer',
    );
  }

  /// Default error logger
  void _defaultErrorLogger(FastException error, String context) {
    // In production, you should replace this with proper logging
    // ignore: avoid_print
    print('ERROR [$context]: ${error.code} - ${error.message}');
    if (error.details != null) {
      // ignore: avoid_print
      print('Details: ${error.details}');
    }
  }
}
