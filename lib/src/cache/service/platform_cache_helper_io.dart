import 'dart:io';

/// IO implementation for native platforms
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    return joinPath(Directory.current.path, joinPath('.cache', 'fast_cache'));
  }

  static String joinPath(String p1, String p2) {
    if (p1.endsWith(Platform.pathSeparator)) return '$p1$p2';
    return '$p1${Platform.pathSeparator}$p2';
  }

  static String basenameWithoutExtension(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(0, dotIndex) : name;
  }

  static Future<bool> directoryExists(String dirPath) async {
    return Directory(dirPath).exists();
  }

  static Future<void> createDirectory(String dirPath) async {
    await Directory(dirPath).create(recursive: true);
  }

  static Future<List<String>> getCacheFilePaths(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];
    final entities = dir.listSync();
    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.cache'))
        .map((file) => file.path)
        .toList();
  }

  static Future<String?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // File read error
    }
    return null;
  }

  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
