/// Cache configuration model for FastCacheService
///
/// This model defines cache behavior, limits, and cleanup policies
/// for both memory and disk cache layers.
class FastCacheConfig {
  /// Maximum number of items in memory cache (0 = unlimited)
  final int maxMemoryItems;

  /// Maximum memory usage in bytes (0 = unlimited)
  final int maxMemorySize;

  /// Maximum number of items in disk cache (0 = unlimited)
  final int maxDiskItems;

  /// Maximum disk usage in bytes (0 = unlimited)
  final int maxDiskSize;

  /// Default time to live in milliseconds (0 = no expiration)
  final int defaultTtlMs;

  /// Cleanup interval in milliseconds
  final int cleanupIntervalMs;

  /// Enable memory cache
  final bool enableMemoryCache;

  /// Enable disk cache
  final bool enableDiskCache;

  /// Enable automatic cleanup of expired items
  final bool enableAutoCleanup;

  /// Enable cache statistics tracking
  final bool enableStatistics;

  /// Cache eviction policy when limit is reached
  final FastCacheEvictionPolicy evictionPolicy;

  /// Creates a new cache configuration with the specified parameters
  const FastCacheConfig({
    this.maxMemoryItems = 1000,
    this.maxMemorySize = 50 * 1024 * 1024, // 50MB
    this.maxDiskItems = 5000,
    this.maxDiskSize = 100 * 1024 * 1024, // 100MB
    this.defaultTtlMs = 30 * 60 * 1000, // 30 minutes
    this.cleanupIntervalMs = 5 * 60 * 1000, // 5 minutes
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.enableAutoCleanup = true,
    this.enableStatistics = true,
    this.evictionPolicy = FastCacheEvictionPolicy.lru,
  });

  /// Create a copy with updated values
  FastCacheConfig copyWith({
    int? maxMemoryItems,
    int? maxMemorySize,
    int? maxDiskItems,
    int? maxDiskSize,
    int? defaultTtlMs,
    int? cleanupIntervalMs,
    bool? enableMemoryCache,
    bool? enableDiskCache,
    bool? enableAutoCleanup,
    bool? enableStatistics,
    FastCacheEvictionPolicy? evictionPolicy,
  }) {
    return FastCacheConfig(
      maxMemoryItems: maxMemoryItems ?? this.maxMemoryItems,
      maxMemorySize: maxMemorySize ?? this.maxMemorySize,
      maxDiskItems: maxDiskItems ?? this.maxDiskItems,
      maxDiskSize: maxDiskSize ?? this.maxDiskSize,
      defaultTtlMs: defaultTtlMs ?? this.defaultTtlMs,
      cleanupIntervalMs: cleanupIntervalMs ?? this.cleanupIntervalMs,
      enableMemoryCache: enableMemoryCache ?? this.enableMemoryCache,
      enableDiskCache: enableDiskCache ?? this.enableDiskCache,
      enableAutoCleanup: enableAutoCleanup ?? this.enableAutoCleanup,
      enableStatistics: enableStatistics ?? this.enableStatistics,
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'maxMemoryItems': maxMemoryItems,
      'maxMemorySize': maxMemorySize,
      'maxDiskItems': maxDiskItems,
      'maxDiskSize': maxDiskSize,
      'defaultTtlMs': defaultTtlMs,
      'cleanupIntervalMs': cleanupIntervalMs,
      'enableMemoryCache': enableMemoryCache,
      'enableDiskCache': enableDiskCache,
      'enableAutoCleanup': enableAutoCleanup,
      'enableStatistics': enableStatistics,
      'evictionPolicy': evictionPolicy.toString().split('.').last,
    };
  }

  /// Create from JSON representation
  static FastCacheConfig fromJson(Map<String, dynamic> json) {
    return FastCacheConfig(
      maxMemoryItems: json['maxMemoryItems'] as int? ?? 1000,
      maxMemorySize: json['maxMemorySize'] as int? ?? 50 * 1024 * 1024,
      maxDiskItems: json['maxDiskItems'] as int? ?? 5000,
      maxDiskSize: json['maxDiskSize'] as int? ?? 100 * 1024 * 1024,
      defaultTtlMs: json['defaultTtlMs'] as int? ?? 30 * 60 * 1000,
      cleanupIntervalMs: json['cleanupIntervalMs'] as int? ?? 5 * 60 * 1000,
      enableMemoryCache: json['enableMemoryCache'] as bool? ?? true,
      enableDiskCache: json['enableDiskCache'] as bool? ?? true,
      enableAutoCleanup: json['enableAutoCleanup'] as bool? ?? true,
      enableStatistics: json['enableStatistics'] as bool? ?? true,
      evictionPolicy: FastCacheEvictionPolicy.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['evictionPolicy'] as String? ?? 'lru'),
        orElse: () => FastCacheEvictionPolicy.lru,
      ),
    );
  }

  @override
  String toString() {
    return 'FastCacheConfig{maxMemoryItems: $maxMemoryItems, '
        'maxMemorySize: $maxMemorySize, enableMemoryCache: $enableMemoryCache, '
        'enableDiskCache: $enableDiskCache, evictionPolicy: $evictionPolicy}';
  }
}

/// Cache eviction policies for when cache limits are reached
enum FastCacheEvictionPolicy {
  /// Least Recently Used - evict items that haven't been accessed recently
  lru,

  /// Least Frequently Used - evict items with lowest access count
  lfu,

  /// First In First Out - evict oldest items first
  fifo,

  /// Random eviction
  random,

  /// Time To Live - evict items closest to expiration
  ttl,
}
