/// Web implementation using localStorage/sessionStorage
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    return 'web_cache'; // Virtual path for web
  }

  static Future<bool> directoryExists(String path) async {
    return true; // Always exists on web (virtual)
  }

  static Future<void> createDirectory(String path) async {
    // No-op on web
  }

  static Future<List<dynamic>> listFiles(String path) async {
    // For web, we could use localStorage keys, but for now return empty
    return [];
  }

  static Future<String?> readFile(String path) async {
    // For web, we could use localStorage, but disk cache is disabled
    return null;
  }

  static Future<void> writeFile(String path, String content) async {
    // For web, we could use localStorage, but disk cache is disabled
  }

  static Future<void> deleteFile(String path) async {
    // For web, we could use localStorage, but disk cache is disabled
  }
}
