/// App information model representing the application's build details
class FastAppInfo {
  /// Name of the application
  final String appName;

  /// Package/Bundle ID of the application
  final String packageName;

  /// Version string (e.g., 1.0.0)
  final String version;

  /// Build number (e.g., 42)
  final String buildNumber;

  const FastAppInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
    };
  }
}
