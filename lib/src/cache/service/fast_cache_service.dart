import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../model/fast_cache_item.dart';
import '../model/fast_cache_config.dart';
import '../model/fast_cache_statistics.dart';
import 'base_cache_service.dart';

/// High-performance caching service with memory and disk storage layers
///
/// FastCacheService provides a comprehensive caching solution with:
/// - Memory cache for ultra-fast access
/// - Disk cache for persistent storage
/// - Automatic expiration and cleanup
/// - Cache statistics and monitoring
/// - Multiple eviction policies
/// - Generic type support
class FastCacheService extends BaseCacheService {
  /// Cache configuration
  final FastCacheConfig config;

  /// Memory cache storage
  final Map<String, FastCacheItem<dynamic>> _memoryCache = {};

  /// Disk cache directory path
  String? _diskCacheDir;

  /// Cache statistics
  FastCacheStatistics _statistics = FastCacheStatistics(
    startTime: DateTime.now(),
    lastUpdated: DateTime.now(),
  );

  /// Cleanup timer
  Timer? _cleanupTimer;

  /// Whether the cache service is initialized
  bool _isInitialized = false;

  /// Creates a new FastCacheService with the specified configuration
  FastCacheService({
    FastCacheConfig? config,
  }) : config = config ?? const FastCacheConfig();

  /// Initialize the cache service
  @override
  Future<void> initialize({String? diskCacheDir}) async {
    if (_isInitialized) return;

    // Setup disk cache directory (only on non-web platforms)
    if (config.enableDiskCache && !kIsWeb) {
      _diskCacheDir = diskCacheDir ?? await _getDefaultCacheDir();
      final dir = Directory(_diskCacheDir!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // Start automatic cleanup timer
    if (config.enableAutoCleanup) {
      _startCleanupTimer();
    }

    _isInitialized = true;
  }

  /// Dispose the cache service and cleanup resources
  @override
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _isInitialized = false;
  }

  /// Get item from cache
  @override
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    // Try memory cache first
    if (config.enableMemoryCache) {
      final memoryItem = _memoryCache[key];
      if (memoryItem != null) {
        if (memoryItem.isValid) {
          // Update access information
          _memoryCache[key] = memoryItem.copyWithAccess();
          _updateStatistics((stats) => stats.incrementGet(isHit: true));
          return memoryItem.data as T?;
        } else {
          // Remove expired item
          _memoryCache.remove(key);
        }
      }
    }

    // Try disk cache
    if (config.enableDiskCache && _diskCacheDir != null && !kIsWeb) {
      final diskItem = await _getDiskCacheItem<T>(key);
      if (diskItem != null) {
        if (diskItem.isValid) {
          // Move to memory cache if enabled
          if (config.enableMemoryCache) {
            await _putMemoryCache(key, diskItem);
          }
          _updateStatistics((stats) => stats.incrementGet(isHit: true));
          return diskItem.data;
        } else {
          // Remove expired disk item
          await _removeDiskCacheItem(key);
        }
      }
    }

    _updateStatistics((stats) => stats.incrementGet(isHit: false));
    return null;
  }

  /// Put item into cache
  @override
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();

    final now = DateTime.now();
    final effectiveTtl = ttl ?? Duration(milliseconds: config.defaultTtlMs);
    final expiresAt =
        effectiveTtl.inMilliseconds > 0 ? now.add(effectiveTtl) : null;

    final cacheItem = FastCacheItem<T>(
      key: key,
      data: data,
      createdAt: now,
      expiresAt: expiresAt,
      lastAccessedAt: now,
      metadata: metadata,
    );

    // Put in memory cache
    if (config.enableMemoryCache) {
      await _putMemoryCache(key, cacheItem);
    }

    // Put in disk cache
    if (config.enableDiskCache && _diskCacheDir != null) {
      await _putDiskCache(key, cacheItem);
    }

    _updateStatistics((stats) => stats.incrementPut());
  }

  /// Remove item from cache
  @override
  Future<bool> remove(String key) async {
    _ensureInitialized();

    bool removed = false;

    // Remove from memory cache
    if (config.enableMemoryCache && _memoryCache.containsKey(key)) {
      _memoryCache.remove(key);
      removed = true;
    }

    // Remove from disk cache
    if (config.enableDiskCache && _diskCacheDir != null) {
      final diskRemoved = await _removeDiskCacheItem(key);
      removed = removed || diskRemoved;
    }

    if (removed) {
      _updateStatistics((stats) => stats.incrementDelete());
    }

    return removed;
  }

  /// Clear all cache
  @override
  Future<void> clear() async {
    _ensureInitialized();

    // Clear memory cache
    if (config.enableMemoryCache) {
      _memoryCache.clear();
    }

    // Clear disk cache
    if (config.enableDiskCache && _diskCacheDir != null) {
      final dir = Directory(_diskCacheDir!);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            try {
              await entity.delete();
            } catch (e) {
              // Ignore deletion errors
            }
          }
        }
      }
    }

    _updateStatistics((stats) => stats.incrementClear());
  }

  /// Check if key exists in cache
  @override
  Future<bool> containsKey(String key) async {
    _ensureInitialized();

    // Check memory cache
    if (config.enableMemoryCache && _memoryCache.containsKey(key)) {
      final item = _memoryCache[key]!;
      if (item.isValid) {
        return true;
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check disk cache
    if (config.enableDiskCache && _diskCacheDir != null) {
      final diskItem = await _getDiskCacheItem(key);
      if (diskItem != null) {
        if (diskItem.isValid) {
          return true;
        } else {
          await _removeDiskCacheItem(key);
        }
      }
    }

    return false;
  }

  /// Get all cache keys
  @override
  Future<List<String>> getKeys() async {
    _ensureInitialized();

    final keys = <String>{};

    // Add memory cache keys
    if (config.enableMemoryCache) {
      keys.addAll(_memoryCache.keys);
    }

    // Add disk cache keys
    if (config.enableDiskCache && _diskCacheDir != null) {
      final dir = Directory(_diskCacheDir!);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            final fileName = path.basenameWithoutExtension(entity.path);
            final key = Uri.decodeComponent(fileName);
            keys.add(key);
          }
        }
      }
    }

    return keys.toList();
  }

  /// Get cache size (number of items)
  @override
  Future<int> size() async {
    _ensureInitialized();
    return (await getKeys()).length;
  }

  /// Cleanup expired items
  @override
  Future<int> cleanupExpired() async {
    _ensureInitialized();

    int removedCount = 0;

    // Cleanup memory cache
    if (config.enableMemoryCache) {
      final expiredKeys = _memoryCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        _memoryCache.remove(key);
        removedCount++;
      }
    }

    // Cleanup disk cache
    if (config.enableDiskCache && _diskCacheDir != null) {
      final dir = Directory(_diskCacheDir!);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.cache')) {
            try {
              final content = await entity.readAsString();
              final json = jsonDecode(content) as Map<String, dynamic>;
              final expiresAtStr = json['expiresAt'] as String?;

              if (expiresAtStr != null) {
                final expiresAt = DateTime.parse(expiresAtStr);
                if (DateTime.now().isAfter(expiresAt)) {
                  await entity.delete();
                  removedCount++;
                }
              }
            } catch (e) {
              // If we can't read the file, consider it corrupted and remove it
              await entity.delete();
              removedCount++;
            }
          }
        }
      }
    }

    if (removedCount > 0) {
      _updateStatistics((stats) => stats.incrementEvictions(removedCount));
    }

    return removedCount;
  }

  /// Get cache statistics
  @override
  FastCacheStatistics getStatistics() {
    return _statistics.updateSizes(
      memoryItems: _memoryCache.length,
      memorySize: _calculateMemorySize(),
      diskItems: 0, // Will be updated asynchronously
      diskSize: 0, // Will be updated asynchronously
    );
  }

  /// Reset cache statistics
  @override
  void resetStatistics() {
    _statistics = _statistics.reset();
  }

  // Private methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'FastCacheService must be initialized before use. Call initialize() first.');
    }
  }

  Future<String> _getDefaultCacheDir() async {
    // This is a simplified implementation
    // In a real app, you might use path_provider package
    return path.join(Directory.current.path, '.cache', 'fast_cache');
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      Duration(milliseconds: config.cleanupIntervalMs),
      (_) => cleanupExpired(),
    );
  }

  Future<void> _putMemoryCache<T>(String key, FastCacheItem<T> item) async {
    // Check memory limits and evict if necessary
    if (config.maxMemoryItems > 0 &&
        _memoryCache.length >= config.maxMemoryItems) {
      await _evictMemoryItems(1);
    }

    _memoryCache[key] = item;
  }

  Future<void> _putDiskCache<T>(String key, FastCacheItem<T> item) async {
    final file =
        File(path.join(_diskCacheDir!, '${Uri.encodeComponent(key)}.cache'));

    final data = {
      'key': item.key,
      'data': item.data,
      'createdAt': item.createdAt.toIso8601String(),
      'expiresAt': item.expiresAt?.toIso8601String(),
      'accessCount': item.accessCount,
      'lastAccessedAt': item.lastAccessedAt.toIso8601String(),
      'metadata': item.metadata,
    };

    await file.writeAsString(jsonEncode(data));
  }

  Future<FastCacheItem<T>?> _getDiskCacheItem<T>(String key) async {
    final file =
        File(path.join(_diskCacheDir!, '${Uri.encodeComponent(key)}.cache'));

    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      return FastCacheItem<T>(
        key: json['key'] as String,
        data: json['data'] as T,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        accessCount: json['accessCount'] as int? ?? 0,
        lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      // If we can't read the file, remove it
      await file.delete();
      return null;
    }
  }

  Future<bool> _removeDiskCacheItem(String key) async {
    final file =
        File(path.join(_diskCacheDir!, '${Uri.encodeComponent(key)}.cache'));

    if (await file.exists()) {
      try {
        await file.delete();
        return true;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  Future<void> _evictMemoryItems(int count) async {
    if (_memoryCache.isEmpty) return;

    List<MapEntry<String, FastCacheItem<dynamic>>> entries;

    switch (config.evictionPolicy) {
      case FastCacheEvictionPolicy.lru:
        entries = _memoryCache.entries.toList()
          ..sort((a, b) =>
              a.value.lastAccessedAt.compareTo(b.value.lastAccessedAt));
        break;
      case FastCacheEvictionPolicy.lfu:
        entries = _memoryCache.entries.toList()
          ..sort((a, b) => a.value.accessCount.compareTo(b.value.accessCount));
        break;
      case FastCacheEvictionPolicy.fifo:
        entries = _memoryCache.entries.toList()
          ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
        break;
      case FastCacheEvictionPolicy.ttl:
        entries = _memoryCache.entries.toList()
          ..sort((a, b) {
            final aExpires =
                a.value.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bExpires =
                b.value.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aExpires.compareTo(bExpires);
          });
        break;
      case FastCacheEvictionPolicy.random:
        entries = _memoryCache.entries.toList()..shuffle(Random());
        break;
    }

    final toRemove = entries.take(count);
    for (final entry in toRemove) {
      _memoryCache.remove(entry.key);
    }

    _updateStatistics((stats) => stats.incrementEvictions(count));
  }

  int _calculateMemorySize() {
    // Simplified memory size calculation
    // In a real implementation, you might want more accurate size calculation
    return _memoryCache.length * 1024; // Rough estimate: 1KB per item
  }

  void _updateStatistics(
      FastCacheStatistics Function(FastCacheStatistics) updater) {
    if (config.enableStatistics) {
      _statistics = updater(_statistics);
    }
  }
}
