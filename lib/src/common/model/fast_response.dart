/// A generic response model for service and repository operations.
class FastResponse<T> {
  /// Indicates if the operation was successful.
  final bool success;

  /// Optional error code for failed operations.
  final String? errorCode;

  /// Optional error message for failed operations.
  final String? errorMessage;

  /// The data returned by the operation, if any.
  final T? data;

  /// Optional metadata for additional information (e.g. pagination, debug info).
  final Map<String, dynamic>? meta;

  /// Creates a [FastResponse] instance.
  const FastResponse({
    required this.success,
    this.errorCode,
    this.errorMessage,
    this.data,
    this.meta,
  });

  /// Creates a successful response with [data] and optional [meta].
  factory FastResponse.success(T data, {Map<String, dynamic>? meta}) =>
      FastResponse(success: true, data: data, meta: meta);

  /// Creates a failed response with [errorCode], [errorMessage], and optional [meta].
  factory FastResponse.failure({
    String? errorCode,
    String? errorMessage,
    Map<String, dynamic>? meta,
  }) =>
      FastResponse(
        success: false,
        errorCode: errorCode,
        errorMessage: errorMessage,
        meta: meta,
      );
}
