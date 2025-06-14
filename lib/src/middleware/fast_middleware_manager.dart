import '../common/model/fast_response.dart';
import 'base_middleware.dart';

/// Middleware manager for handling middleware chain execution
///
/// This class manages a collection of middleware and executes them
/// in the correct order based on their priority.
class FastMiddlewareManager {
  final List<BaseMiddleware> _middlewares = [];

  /// Adds a middleware to the manager
  void addMiddleware(BaseMiddleware middleware) {
    _middlewares.add(middleware);
    _middlewares.sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Removes a middleware from the manager
  void removeMiddleware(BaseMiddleware middleware) {
    _middlewares.remove(middleware);
  }

  /// Removes all middlewares of a specific type
  void removeMiddlewareOfType<T extends BaseMiddleware>() {
    _middlewares.removeWhere((middleware) => middleware is T);
  }

  /// Gets all registered middlewares
  List<BaseMiddleware> get middlewares => List.unmodifiable(_middlewares);

  /// Clears all middlewares
  void clear() {
    _middlewares.clear();
  }

  /// Executes the middleware chain for a request
  Future<FastResponse<T>?> executeRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    for (final middleware in _middlewares) {
      try {
        final result = await middleware.onRequest<T>(
          method,
          endpoint,
          data,
          headers,
        );
        if (result != null) {
          // Middleware wants to short-circuit the request
          return result;
        }
      } catch (e) {
        // If middleware throws an error, handle it with error middleware
        return await executeError<T>(
          e is Exception ? e : Exception(e.toString()),
          method,
          endpoint,
          data,
        );
      }
    }
    return null; // Continue with the actual request
  }

  /// Executes the middleware chain for a successful response
  Future<FastResponse<T>> executeResponse<T>(
    FastResponse<T> response,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    var currentResponse = response;

    for (final middleware in _middlewares) {
      try {
        currentResponse = await middleware.onResponse<T>(
          currentResponse,
          method,
          endpoint,
          data,
        );
      } catch (e) {
        // If middleware throws an error, handle it with error middleware
        return await executeError<T>(
          e is Exception ? e : Exception(e.toString()),
          method,
          endpoint,
          data,
        );
      }
    }

    return currentResponse;
  }

  /// Executes the middleware chain for an error
  Future<FastResponse<T>> executeError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    Exception currentError = error;

    // Execute error middleware in reverse order (last to first)
    for (final middleware in _middlewares.reversed) {
      try {
        final response = await middleware.onError<T>(
          currentError,
          method,
          endpoint,
          data,
        );
        return response;
      } catch (e) {
        // Update current error for next middleware
        currentError = e is Exception ? e : Exception(e.toString());
      }
    }

    // If no middleware handled the error, throw it
    throw currentError;
  }

  /// Executes the finally block for all middlewares
  Future<void> executeFinally(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    bool wasSuccessful,
  ) async {
    for (final middleware in _middlewares) {
      try {
        await middleware.onFinally(
          method,
          endpoint,
          data,
          wasSuccessful,
        );
      } catch (e) {
        // Ignore errors in finally blocks to avoid masking original errors
        // In a production environment, you might want to log these errors
        // to a logging service instead of using print
        if (e.toString().isNotEmpty) {
          // Error occurred in finally block
        }
      }
    }
  }
}
