/// Cache statistics model for tracking cache performance and usage
///
/// This model provides insights into cache hit/miss ratios, storage usage,
/// and performance metrics for both memory and disk cache layers.
class FastCacheStatistics {
  /// Total number of cache get operations
  final int totalGets;

  /// Number of successful cache hits
  final int hits;

  /// Number of cache misses
  final int misses;

  /// Total number of cache put operations
  final int puts;

  /// Total number of cache delete operations
  final int deletes;

  /// Total number of cache clear operations
  final int clears;

  /// Total number of expired items removed
  final int evictions;

  /// Current number of items in memory cache
  final int memoryItems;

  /// Current memory cache size in bytes
  final int memorySize;

  /// Current number of items in disk cache
  final int diskItems;

  /// Current disk cache size in bytes
  final int diskSize;

  /// When statistics tracking started
  final DateTime startTime;

  /// When statistics were last updated
  final DateTime lastUpdated;

  /// Creates a new cache statistics instance with the specified parameters
  const FastCacheStatistics({
    this.totalGets = 0,
    this.hits = 0,
    this.misses = 0,
    this.puts = 0,
    this.deletes = 0,
    this.clears = 0,
    this.evictions = 0,
    this.memoryItems = 0,
    this.memorySize = 0,
    this.diskItems = 0,
    this.diskSize = 0,
    required this.startTime,
    required this.lastUpdated,
  });

  /// Cache hit ratio (0.0 to 1.0)
  double get hitRatio {
    if (totalGets == 0) return 0.0;
    return hits / totalGets;
  }

  /// Cache miss ratio (0.0 to 1.0)
  double get missRatio {
    if (totalGets == 0) return 0.0;
    return misses / totalGets;
  }

  /// Hit ratio as percentage (0 to 100)
  double get hitRatioPercentage => hitRatio * 100;

  /// Miss ratio as percentage (0 to 100)
  double get missRatioPercentage => missRatio * 100;

  /// Total number of items across memory and disk cache
  int get totalItems => memoryItems + diskItems;

  /// Total cache size in bytes across memory and disk
  int get totalSize => memorySize + diskSize;

  /// Statistics duration since tracking started
  Duration get duration => lastUpdated.difference(startTime);

  /// Average operations per second
  double get operationsPerSecond {
    final totalOps = totalGets + puts + deletes + clears;
    final seconds = duration.inSeconds;
    if (seconds == 0) return 0.0;
    return totalOps / seconds;
  }

  /// Create a copy with updated values
  FastCacheStatistics copyWith({
    int? totalGets,
    int? hits,
    int? misses,
    int? puts,
    int? deletes,
    int? clears,
    int? evictions,
    int? memoryItems,
    int? memorySize,
    int? diskItems,
    int? diskSize,
    DateTime? startTime,
    DateTime? lastUpdated,
  }) {
    return FastCacheStatistics(
      totalGets: totalGets ?? this.totalGets,
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      puts: puts ?? this.puts,
      deletes: deletes ?? this.deletes,
      clears: clears ?? this.clears,
      evictions: evictions ?? this.evictions,
      memoryItems: memoryItems ?? this.memoryItems,
      memorySize: memorySize ?? this.memorySize,
      diskItems: diskItems ?? this.diskItems,
      diskSize: diskSize ?? this.diskSize,
      startTime: startTime ?? this.startTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Increment get operation (hit or miss)
  FastCacheStatistics incrementGet({required bool isHit}) {
    return copyWith(
      totalGets: totalGets + 1,
      hits: isHit ? hits + 1 : hits,
      misses: isHit ? misses : misses + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment put operation
  FastCacheStatistics incrementPut() {
    return copyWith(
      puts: puts + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment delete operation
  FastCacheStatistics incrementDelete() {
    return copyWith(
      deletes: deletes + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment clear operation
  FastCacheStatistics incrementClear() {
    return copyWith(
      clears: clears + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment eviction count
  FastCacheStatistics incrementEvictions(int count) {
    return copyWith(
      evictions: evictions + count,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update cache size statistics
  FastCacheStatistics updateSizes({
    int? memoryItems,
    int? memorySize,
    int? diskItems,
    int? diskSize,
  }) {
    return copyWith(
      memoryItems: memoryItems ?? this.memoryItems,
      memorySize: memorySize ?? this.memorySize,
      diskItems: diskItems ?? this.diskItems,
      diskSize: diskSize ?? this.diskSize,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reset all statistics
  FastCacheStatistics reset() {
    final now = DateTime.now();
    return FastCacheStatistics(
      startTime: now,
      lastUpdated: now,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'totalGets': totalGets,
      'hits': hits,
      'misses': misses,
      'puts': puts,
      'deletes': deletes,
      'clears': clears,
      'evictions': evictions,
      'memoryItems': memoryItems,
      'memorySize': memorySize,
      'diskItems': diskItems,
      'diskSize': diskSize,
      'startTime': startTime.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'hitRatio': hitRatio,
      'missRatio': missRatio,
      'totalItems': totalItems,
      'totalSize': totalSize,
    };
  }

  /// Create from JSON representation
  static FastCacheStatistics fromJson(Map<String, dynamic> json) {
    return FastCacheStatistics(
      totalGets: json['totalGets'] as int? ?? 0,
      hits: json['hits'] as int? ?? 0,
      misses: json['misses'] as int? ?? 0,
      puts: json['puts'] as int? ?? 0,
      deletes: json['deletes'] as int? ?? 0,
      clears: json['clears'] as int? ?? 0,
      evictions: json['evictions'] as int? ?? 0,
      memoryItems: json['memoryItems'] as int? ?? 0,
      memorySize: json['memorySize'] as int? ?? 0,
      diskItems: json['diskItems'] as int? ?? 0,
      diskSize: json['diskSize'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  String toString() {
    return 'FastCacheStatistics{\n'
        '  totalGets: $totalGets, hits: $hits, misses: $misses\n'
        '  hitRatio: ${hitRatioPercentage.toStringAsFixed(1)}%\n'
        '  memoryItems: $memoryItems, diskItems: $diskItems\n'
        '  memorySize: ${(memorySize / 1024 / 1024).toStringAsFixed(1)}MB\n'
        '  diskSize: ${(diskSize / 1024 / 1024).toStringAsFixed(1)}MB\n'
        '  duration: ${duration.inMinutes}min\n'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastCacheStatistics &&
        other.totalGets == totalGets &&
        other.hits == hits &&
        other.misses == misses &&
        other.puts == puts &&
        other.deletes == deletes &&
        other.clears == clears &&
        other.evictions == evictions &&
        other.startTime == startTime;
  }

  @override
  int get hashCode {
    return totalGets.hashCode ^
        hits.hashCode ^
        misses.hashCode ^
        puts.hashCode ^
        deletes.hashCode ^
        clears.hashCode ^
        evictions.hashCode ^
        startTime.hashCode;
  }
}
