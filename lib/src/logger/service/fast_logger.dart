import 'dart:async';
import '../enums/fast_log_level.dart';
import '../model/fast_log_message.dart';

/// A zero-dependency, advanced logging utility.
/// Provides colored console output, log levels, and global callbacks for external crashlytics/monitoring tools.
class FastLogger {
  /// Prevent instantiation since this is a static utility.
  FastLogger._();

  /// ANSI Color Codes for console output
  static const String _reset = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _cyan = '\x1B[36m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  /// Minimum severity level to output to console.
  /// Set this to FastLogLevel.warning in production to hide debug/info logs.
  static FastLogLevel minLevel = FastLogLevel.debug;

  /// Enable or disable console printing (useful for tests or strict production environments).
  static bool enableConsoleOutput = true;

  /// Global callback for log messages.
  /// Useful for integrating Firebase Crashlytics, Sentry, or custom remote logging.
  static void Function(FastLogMessage logMessage)? onLog;
  static void d(String message, {String? tag}) {
    _log(FastLogLevel.debug, message, tag: tag);
  }

  /// Log an informational message.
  static void i(String message, {String? tag}) {
    _log(FastLogLevel.info, message, tag: tag);
  }

  /// Log a warning message for expected but mishandled situations.
  static void w(String message,
      {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(FastLogLevel.warning, message,
        error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log an error message.
  static void e(String message,
      {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(FastLogLevel.error, message,
        error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log a critical "What a Terrible Failure" message.
  static void wtf(String message,
      {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(FastLogLevel.wtf, message,
        error: error, stackTrace: stackTrace, tag: tag);
  }

  static void _log(
    FastLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final logMessage = FastLogMessage(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
      tag: tag,
    );

    // Trigger external callback
    try {
      onLog?.call(logMessage);
    } catch (_) {
      // Ignore errors in the callback to prevent recursive log crashes
    }

    if (!enableConsoleOutput) return;

    if (level.severity < minLevel.severity) return;

    final color = _getColor(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final timeStr = _formatTime(logMessage.timestamp);

    // Print Header
    final levelStr = level.toString().split('.').last.toUpperCase();
    _printSafely('$color[$timeStr] [$levelStr] $tagStr$message$_reset');

    // Print Error if exists
    if (error != null) {
      _printSafely('$color  => Error: $error$_reset');
    }

    // Print StackTrace if exists
    if (stackTrace != null) {
      _printSafely('$_gray${stackTrace.toString().trim()}$_reset');
    }
  }

  static String _getColor(FastLogLevel level) {
    switch (level) {
      case FastLogLevel.debug:
        return _gray;
      case FastLogLevel.info:
        return _cyan;
      case FastLogLevel.warning:
        return _yellow;
      case FastLogLevel.error:
        return _red;
      case FastLogLevel.wtf:
        return _magenta;
    }
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  static void _printSafely(String output) {
    // We use Zone to ensure the print goes to the correct output stream,
    // which is required for Flutter test environments.
    Zone.current.print(output);
  }
}
