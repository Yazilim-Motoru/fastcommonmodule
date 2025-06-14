import '../common/model/fast_response.dart';

/// Base middleware interface for intercepting requests and responses
///
/// This abstract class defines the contract for middleware implementations
/// that can intercept, modify, and handle requests and responses in the pipeline.
abstract class BaseMiddleware {
  /// Priority of the middleware (lower numbers execute first)
  int get priority => 0;

  /// Called before a request is processed
  Future<FastResponse<T>?> onRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    return null; // Return null to continue, return response to short-circuit
  }

  /// Called after a successful response
  Future<FastResponse<T>> onResponse<T>(
    FastResponse<T> response,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    return response;
  }

  /// Called when an error occurs
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    throw error; // Rethrow by default
  }

  /// Called finally, regardless of success or error
  Future<void> onFinally(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    bool wasSuccessful,
  ) async {}
}
