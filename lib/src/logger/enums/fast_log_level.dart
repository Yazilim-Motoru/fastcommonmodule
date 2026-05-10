/// Defines the severity levels for FastLogger
enum FastLogLevel {
  /// Detailed debug information
  debug,

  /// General application flow and information
  info,

  /// Warning about unexpected but handled situations
  warning,

  /// Error that affects an operation but not the whole application
  error,

  /// "What a Terrible Failure" - Critical system crash or unrecoverable error
  wtf,
}

extension FastLogLevelExtension on FastLogLevel {
  /// Returns the relative severity of the level (higher is more severe)
  int get severity {
    switch (this) {
      case FastLogLevel.debug:
        return 0;
      case FastLogLevel.info:
        return 1;
      case FastLogLevel.warning:
        return 2;
      case FastLogLevel.error:
        return 3;
      case FastLogLevel.wtf:
        return 4;
    }
  }
}
