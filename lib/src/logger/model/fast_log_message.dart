import '../enums/fast_log_level.dart';

/// Represents a single log entry created by FastLogger
class FastLogMessage {
  /// The severity level of the log
  final FastLogLevel level;

  /// The main message content
  final String message;

  /// The time when the log was generated
  final DateTime timestamp;

  /// Optional error object associated with the log
  final Object? error;

  /// Optional stack trace associated with the log
  final StackTrace? stackTrace;

  /// The tag or category of the log (e.g., 'API', 'Auth', 'UI')
  final String? tag;

  const FastLogMessage({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.tag,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.toString().split('.').last,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (tag != null) 'tag': tag,
    };
  }

  @override
  String toString() {
    final tagStr = tag != null ? '[$tag] ' : '';
    final levelStr = level.toString().split('.').last.toUpperCase();
    return '[$timestamp] [$levelStr] $tagStr$message';
  }
}
