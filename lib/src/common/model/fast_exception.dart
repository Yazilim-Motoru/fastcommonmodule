/// FastException is a custom exception class for FastCommonModule.
///
/// Use this for all domain-specific errors and to provide consistent error handling.
class FastException implements Exception {
  /// Error code for programmatic handling (optional).
  final String? code;

  /// Human-readable error message.
  final String message;

  /// Optional details or stack trace.
  final dynamic details;

  /// Optional file path where the exception occurred.
  final String? path;

  /// Optional class name where the exception occurred.
  final String? className;

  /// Optional method name where the exception occurred.
  final String? method;

  /// Creates a [FastException] with a message and optional details.
  FastException(
    this.message, {
    this.code,
    this.details,
    this.path,
    this.className,
    this.method,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    if (code != null)
      buffer.write('FastException([32m$code[0m): ');
    else
      buffer.write('FastException: ');
    buffer.write(message);
    if (className != null) buffer.write(' | class: $className');
    if (method != null) buffer.write(' | method: $method');
    if (path != null) buffer.write(' | path: $path');
    if (details != null) buffer.write(' | details: $details');
    return buffer.toString();
  }
}
