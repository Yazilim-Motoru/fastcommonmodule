/// Stub implementation for unsupported platforms
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<bool> directoryExists(String path) async {
    return false;
  }

  static Future<void> createDirectory(String path) async {
    throw UnsupportedError('Platform not supported');
  }

  static Future<List<dynamic>> listFiles(String path) async {
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
