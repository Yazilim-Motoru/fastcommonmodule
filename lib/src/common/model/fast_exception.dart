/// Custom exception for FastCommonModule operations.
class FastException implements Exception {
  /// Error message.
  final String message;

  /// Optional error code.
  final String? code;

  /// Optional error details.
  final dynamic details;

  /// Optional path where the error occurred.
  final String? path;

  /// Optional class name where the error occurred.
  final String? className;

  /// Optional method name where the error occurred.
  final String? method;

  /// Creates a [FastException] instance.
  const FastException(
    this.message, {
    this.code,
    this.details,
    this.path,
    this.className,
    this.method,
  });

  @override
  String toString() =>
      'FastException(message: $message, code: $code, details: $details, path: $path, className: $className, method: $method)';
}
