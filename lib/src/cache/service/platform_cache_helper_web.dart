/// Web implementation using localStorage/sessionStorage
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    return 'web_cache'; // Virtual path for web
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
    return true; // Always exists on web (virtual)
  }

  static Future<void> createDirectory(String path) async {
    // No-op on web
  }

  static Future<List<String>> getCacheFilePaths(String path) async {
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
