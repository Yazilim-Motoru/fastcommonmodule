/// Cache item model for storing cached data with metadata
///
/// This model represents a cached item with expiration time,
/// creation timestamp, and access tracking for cache management.
class FastCacheItem<T> {
  /// Unique identifier for the cache item
  final String key;

  /// The cached data
  final T data;

  /// When the cache item was created
  final DateTime createdAt;

  /// When the cache item will expire (null for no expiration)
  final DateTime? expiresAt;

  /// Number of times this cache item has been accessed
  final int accessCount;

  /// When the cache item was last accessed
  final DateTime lastAccessedAt;

  /// Additional metadata for the cache item
  final Map<String, dynamic>? metadata;

  /// Creates a new cache item with the specified parameters
  const FastCacheItem({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 0,
    required this.lastAccessedAt,
    this.metadata,
  });

  /// Check if the cache item is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if the cache item is valid (not expired)
  bool get isValid => !isExpired;

  /// Time to live in milliseconds (null if no expiration)
  int? get ttlMs {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inMilliseconds;
  }

  /// Create a copy with updated access information
  FastCacheItem<T> copyWithAccess() {
    return FastCacheItem<T>(
      key: key,
      data: data,
      createdAt: createdAt,
      expiresAt: expiresAt,
      accessCount: accessCount + 1,
      lastAccessedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Create a copy with new data
  FastCacheItem<T> copyWith({
    String? key,
    T? data,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? accessCount,
    DateTime? lastAccessedAt,
    Map<String, dynamic>? metadata,
  }) {
    return FastCacheItem<T>(
      key: key ?? this.key,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON representation
  static FastCacheItem<T> fromJson<T>(Map<String, dynamic> json, T data) {
    return FastCacheItem<T>(
      key: json['key'] as String,
      data: data,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      accessCount: json['accessCount'] as int? ?? 0,
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FastCacheItem{key: $key, createdAt: $createdAt, expiresAt: $expiresAt, '
        'accessCount: $accessCount, isExpired: $isExpired}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastCacheItem<T> &&
        other.key == key &&
        other.data == data &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        data.hashCode ^
        createdAt.hashCode ^
        expiresAt.hashCode;
  }
}
