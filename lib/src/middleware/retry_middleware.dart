import '../common/model/fast_response.dart';
import 'base_middleware.dart';

/// Retry middleware for automatic request retries
///
/// This middleware automatically retries failed requests based on
/// configurable conditions and strategies.
class RetryMiddleware extends BaseMiddleware {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Delay between retries
  final Duration retryDelay;

  /// Whether to use exponential backoff
  final bool useExponentialBackoff;

  /// Function to determine if a request should be retried
  final bool Function(Exception error, int attemptCount)? shouldRetry;

  /// Function to calculate retry delay
  final Duration Function(int attemptCount, Duration baseDelay)?
      delayCalculator;

  /// Creates a new retry middleware
  RetryMiddleware({
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 1000),
    this.useExponentialBackoff = true,
    this.shouldRetry,
    this.delayCalculator,
  });

  @override
  int get priority => 500; // Execute in middle of chain

  @override
  Future<FastResponse<T>?> onRequest<T>(
    String method,
    String endpoint,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  ) async {
    // Store retry context in headers for the actual request
    final retryHeaders = Map<String, String>.from(headers ?? {});
    retryHeaders['X-Retry-Count'] = '0';
    retryHeaders['X-Max-Retries'] = maxRetries.toString();

    return null; // Continue with request
  }

  @override
  Future<FastResponse<T>> onError<T>(
    Exception error,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    // This would be called during the actual retry logic
    // For now, just pass through the error
    throw error;
  }

  /// Determines if a request should be retried based on the error
  bool _shouldRetryRequest(Exception error, int attemptCount) {
    if (shouldRetry != null) {
      return shouldRetry!(error, attemptCount);
    }

    // Default retry logic
    if (attemptCount >= maxRetries) {
      return false;
    }

    // Retry on network errors, timeouts, and server errors
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('timeout') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('network') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('500') ||
        errorMessage.contains('502') ||
        errorMessage.contains('503') ||
        errorMessage.contains('504');
  }

  /// Calculates the delay before the next retry attempt
  Duration _calculateDelay(int attemptCount) {
    if (delayCalculator != null) {
      return delayCalculator!(attemptCount, retryDelay);
    }

    if (useExponentialBackoff) {
      // Exponential backoff: delay * 2^attemptCount
      final multiplier = 1 << attemptCount; // 2^attemptCount
      return Duration(
        milliseconds: retryDelay.inMilliseconds * multiplier,
      );
    }

    return retryDelay;
  }

  /// Execute a request with retry logic
  /// This method would be used by the API client
  Future<FastResponse<T>> executeWithRetry<T>(
    Future<FastResponse<T>> Function() requestFunction,
    String method,
    String endpoint,
    Map<String, dynamic>? data,
  ) async {
    int attemptCount = 0;
    Exception? lastError;

    while (attemptCount <= maxRetries) {
      try {
        final response = await requestFunction();
        if (response.success) {
          return response;
        }

        // If response is not successful, treat as error for retry logic
        lastError = Exception('Request failed: ${response.errorMessage}');

        if (!_shouldRetryRequest(lastError, attemptCount)) {
          return response; // Return the failed response
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());

        if (!_shouldRetryRequest(lastError, attemptCount)) {
          throw lastError;
        }
      }

      attemptCount++;

      if (attemptCount <= maxRetries) {
        final delay = _calculateDelay(attemptCount - 1);
        await Future.delayed(delay);
      }
    }

    // If we get here, all retries have been exhausted
    throw lastError ?? Exception('All retry attempts failed');
  }
}
