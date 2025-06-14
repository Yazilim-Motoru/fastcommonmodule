/// Rate limiting entry for tracking request counts and timestamps
///
/// This model tracks individual identifier's request history,
/// violations, and block status for rate limiting enforcement.
class FastRateLimitEntry {
  /// Unique identifier (IP, user ID, API key, etc.)
  final String identifier;

  /// Total number of requests made
  final int requestCount;

  /// Timestamps of requests in the current window
  final List<DateTime> requestTimestamps;

  /// Number of rate limit violations
  final int violationCount;

  /// Whether the identifier is currently blocked
  final bool isBlocked;

  /// When the block will expire (null if not blocked)
  final DateTime? blockExpiresAt;

  /// When this entry was first created
  final DateTime createdAt;

  /// When this entry was last updated
  final DateTime lastUpdatedAt;

  /// When the last request was made
  final DateTime? lastRequestAt;

  /// Additional metadata for the entry
  final Map<String, dynamic>? metadata;

  /// Creates a new rate limit entry with the specified parameters
  const FastRateLimitEntry({
    required this.identifier,
    this.requestCount = 0,
    this.requestTimestamps = const [],
    this.violationCount = 0,
    this.isBlocked = false,
    this.blockExpiresAt,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.lastRequestAt,
    this.metadata,
  });

  /// Check if the entry is currently blocked and not expired
  bool get isCurrentlyBlocked {
    if (!isBlocked || blockExpiresAt == null) return false;
    return DateTime.now().isBefore(blockExpiresAt!);
  }

  /// Check if the block has expired
  bool get isBlockExpired {
    if (!isBlocked || blockExpiresAt == null) return false;
    return DateTime.now().isAfter(blockExpiresAt!);
  }

  /// Get remaining block time in milliseconds
  int get remainingBlockTimeMs {
    if (!isCurrentlyBlocked) return 0;
    return blockExpiresAt!.difference(DateTime.now()).inMilliseconds;
  }

  /// Get remaining block time as duration
  Duration get remainingBlockTime {
    if (!isCurrentlyBlocked) return Duration.zero;
    return blockExpiresAt!.difference(DateTime.now());
  }

  /// Get request count in the specified time window
  int getRequestCountInWindow(Duration window) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    return requestTimestamps
        .where((timestamp) => timestamp.isAfter(windowStart))
        .length;
  }

  /// Create a copy with updated values
  FastRateLimitEntry copyWith({
    String? identifier,
    int? requestCount,
    List<DateTime>? requestTimestamps,
    int? violationCount,
    bool? isBlocked,
    DateTime? blockExpiresAt,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    DateTime? lastRequestAt,
    Map<String, dynamic>? metadata,
  }) {
    return FastRateLimitEntry(
      identifier: identifier ?? this.identifier,
      requestCount: requestCount ?? this.requestCount,
      requestTimestamps: requestTimestamps ?? this.requestTimestamps,
      violationCount: violationCount ?? this.violationCount,
      isBlocked: isBlocked ?? this.isBlocked,
      blockExpiresAt: blockExpiresAt ?? this.blockExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastRequestAt: lastRequestAt ?? this.lastRequestAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Add a new request timestamp
  FastRateLimitEntry addRequest([DateTime? timestamp]) {
    final now = timestamp ?? DateTime.now();
    final newTimestamps = List<DateTime>.from(requestTimestamps)..add(now);

    return copyWith(
      requestCount: requestCount + 1,
      requestTimestamps: newTimestamps,
      lastRequestAt: now,
      lastUpdatedAt: now,
    );
  }

  /// Record a violation
  FastRateLimitEntry addViolation() {
    return copyWith(
      violationCount: violationCount + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Block the identifier
  FastRateLimitEntry block(Duration blockDuration) {
    final now = DateTime.now();
    return copyWith(
      isBlocked: true,
      blockExpiresAt: now.add(blockDuration),
      lastUpdatedAt: now,
    );
  }

  /// Unblock the identifier
  FastRateLimitEntry unblock() {
    return copyWith(
      isBlocked: false,
      blockExpiresAt: null,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Clean up old timestamps outside the window
  FastRateLimitEntry cleanupOldTimestamps(Duration window) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    final filteredTimestamps = requestTimestamps
        .where((timestamp) => timestamp.isAfter(windowStart))
        .toList();

    return copyWith(
      requestTimestamps: filteredTimestamps,
      lastUpdatedAt: now,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'requestCount': requestCount,
      'requestTimestamps':
          requestTimestamps.map((t) => t.toIso8601String()).toList(),
      'violationCount': violationCount,
      'isBlocked': isBlocked,
      'blockExpiresAt': blockExpiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'lastRequestAt': lastRequestAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON representation
  static FastRateLimitEntry fromJson(Map<String, dynamic> json) {
    return FastRateLimitEntry(
      identifier: json['identifier'] as String,
      requestCount: json['requestCount'] as int? ?? 0,
      requestTimestamps: (json['requestTimestamps'] as List<dynamic>?)
              ?.map((t) => DateTime.parse(t as String))
              .toList() ??
          const [],
      violationCount: json['violationCount'] as int? ?? 0,
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockExpiresAt: json['blockExpiresAt'] != null
          ? DateTime.parse(json['blockExpiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      lastRequestAt: json['lastRequestAt'] != null
          ? DateTime.parse(json['lastRequestAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FastRateLimitEntry{identifier: $identifier, requestCount: $requestCount, '
        'violationCount: $violationCount, isBlocked: $isBlocked, '
        'blockExpiresAt: $blockExpiresAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastRateLimitEntry &&
        other.identifier == identifier &&
        other.requestCount == requestCount &&
        other.violationCount == violationCount &&
        other.isBlocked == isBlocked &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return identifier.hashCode ^
        requestCount.hashCode ^
        violationCount.hashCode ^
        isBlocked.hashCode ^
        createdAt.hashCode;
  }
}
