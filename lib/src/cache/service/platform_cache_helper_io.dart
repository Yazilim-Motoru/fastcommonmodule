import 'dart:io';
import 'package:path/path.dart' as path;

/// IO implementation for native platforms
class PlatformCacheHelper {
  static Future<String> getDefaultCacheDir() async {
    return path.join(Directory.current.path, '.cache', 'fast_cache');
  }

  static Future<bool> directoryExists(String dirPath) async {
    return Directory(dirPath).exists();
  }

  static Future<void> createDirectory(String dirPath) async {
    await Directory(dirPath).create(recursive: true);
  }

  static Future<List<FileSystemEntity>> listFiles(String dirPath) async {
    final dir = Directory(dirPath);
    return dir.list().toList();
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
