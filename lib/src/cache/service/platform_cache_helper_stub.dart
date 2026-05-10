/// Stub implementation for unsupported platforms
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    throw UnsupportedError('Platform not supported');
  }

  static String joinPath(String p1, String p2) {
    if (p1.endsWith('/')) return '$p1$p2';
    return '$p1/$p2';
  }

  static String basenameWithoutExtension(String path) {
    final name = path.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(0, dotIndex) : name;
  }

  static Future<bool> directoryExists(String path) async {
    return false;
  }

  static Future<void> createDirectory(String path) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<List<String>> getCacheFilePaths(String path) async {
    return [];
  }

  static Future<String?> readFile(String path) async {
    return null;
  }

  static Future<void> writeFile(String path, String content) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<void> deleteFile(String path) async {
    throw UnsupportedError('Platform not supported');
  }
}
