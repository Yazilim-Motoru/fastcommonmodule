/// Device information model representing hardware and OS details
class FastDeviceInfo {
  /// Operating system name (e.g., ios, android, windows, macos, linux, web)
  final String os;

  /// Operating system version
  final String osVersion;

  /// Number of processors / cores
  final int processorCount;

  /// Device locale/language setting
  final String language;

  /// Whether the app is running on the web
  final bool isWeb;

  /// Device user agent (web) or hostname (native)
  final String deviceId;

  const FastDeviceInfo({
    required this.os,
    required this.osVersion,
    required this.processorCount,
    required this.language,
    required this.isWeb,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'os': os,
      'osVersion': osVersion,
      'processorCount': processorCount,
      'language': language,
      'isWeb': isWeb,
      'deviceId': deviceId,
    };
  }
}
