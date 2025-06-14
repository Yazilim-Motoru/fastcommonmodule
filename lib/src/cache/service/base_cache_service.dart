import '../model/fast_cache_statistics.dart';

/// Base interface for cache services
///
/// This abstract class defines the contract for cache implementations,
/// allowing for different caching strategies and storage backends.
abstract class BaseCacheService {
  /// Initialize the cache service
  Future<void> initialize();

  /// Dispose the cache service and cleanup resources
  Future<void> dispose();

  /// Get item from cache
  Future<T?> get<T>(String key);

  /// Put item into cache
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  });

  /// Remove item from cache
  Future<bool> remove(String key);

  /// Clear all cache
  Future<void> clear();

  /// Check if key exists in cache
  Future<bool> containsKey(String key);

  /// Get all cache keys
  Future<List<String>> getKeys();

  /// Get cache size (number of items)
  Future<int> size();

  /// Cleanup expired items
  Future<int> cleanupExpired();

  /// Get cache statistics
  FastCacheStatistics getStatistics();

  /// Reset cache statistics
  void resetStatistics();
}
