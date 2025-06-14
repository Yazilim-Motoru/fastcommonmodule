/// Rate limiting configuration model
///
/// This model defines rate limiting rules, policies, and thresholds
/// for protecting APIs and services from abuse and brute-force attacks.
class FastRateLimitConfig {
  /// Maximum number of requests allowed in the time window
  final int maxRequests;

  /// Time window duration in milliseconds
  final int windowMs;

  /// Burst capacity for handling sudden traffic spikes
  final int burstCapacity;

  /// Block duration in milliseconds when limit is exceeded
  final int blockDurationMs;

  /// Rate limiting algorithm to use
  final FastRateLimitAlgorithm algorithm;

  /// Enable automatic cleanup of expired entries
  final bool enableAutoCleanup;

  /// Cleanup interval in milliseconds
  final int cleanupIntervalMs;

  /// Enable rate limit statistics tracking
  final bool enableStatistics;

  /// Custom identifier extraction function name
  final String? identifierKey;

  /// Whitelist of identifiers that bypass rate limiting
  final List<String> whitelist;

  /// Blacklist of identifiers that are permanently blocked
  final List<String> blacklist;

  /// Enable progressive penalties for repeated violations
  final bool enableProgressivePenalties;

  /// Multiplier for progressive penalty duration
  final double penaltyMultiplier;

  /// Creates a new rate limit configuration with the specified parameters
  const FastRateLimitConfig({
    this.maxRequests = 100,
    this.windowMs = 60 * 1000, // 1 minute
    this.burstCapacity = 10,
    this.blockDurationMs = 15 * 60 * 1000, // 15 minutes
    this.algorithm = FastRateLimitAlgorithm.slidingWindow,
    this.enableAutoCleanup = true,
    this.cleanupIntervalMs = 5 * 60 * 1000, // 5 minutes
    this.enableStatistics = true,
    this.identifierKey,
    this.whitelist = const [],
    this.blacklist = const [],
    this.enableProgressivePenalties = true,
    this.penaltyMultiplier = 2.0,
  });

  /// Create a copy with updated values
  FastRateLimitConfig copyWith({
    int? maxRequests,
    int? windowMs,
    int? burstCapacity,
    int? blockDurationMs,
    FastRateLimitAlgorithm? algorithm,
    bool? enableAutoCleanup,
    int? cleanupIntervalMs,
    bool? enableStatistics,
    String? identifierKey,
    List<String>? whitelist,
    List<String>? blacklist,
    bool? enableProgressivePenalties,
    double? penaltyMultiplier,
  }) {
    return FastRateLimitConfig(
      maxRequests: maxRequests ?? this.maxRequests,
      windowMs: windowMs ?? this.windowMs,
      burstCapacity: burstCapacity ?? this.burstCapacity,
      blockDurationMs: blockDurationMs ?? this.blockDurationMs,
      algorithm: algorithm ?? this.algorithm,
      enableAutoCleanup: enableAutoCleanup ?? this.enableAutoCleanup,
      cleanupIntervalMs: cleanupIntervalMs ?? this.cleanupIntervalMs,
      enableStatistics: enableStatistics ?? this.enableStatistics,
      identifierKey: identifierKey ?? this.identifierKey,
      whitelist: whitelist ?? this.whitelist,
      blacklist: blacklist ?? this.blacklist,
      enableProgressivePenalties:
          enableProgressivePenalties ?? this.enableProgressivePenalties,
      penaltyMultiplier: penaltyMultiplier ?? this.penaltyMultiplier,
    );
  }

  /// Get requests per second rate
  double get requestsPerSecond => maxRequests / (windowMs / 1000);

  /// Get requests per minute rate
  double get requestsPerMinute => maxRequests / (windowMs / 60000);

  /// Check if identifier is whitelisted
  bool isWhitelisted(String identifier) => whitelist.contains(identifier);

  /// Check if identifier is blacklisted
  bool isBlacklisted(String identifier) => blacklist.contains(identifier);

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'maxRequests': maxRequests,
      'windowMs': windowMs,
      'burstCapacity': burstCapacity,
      'blockDurationMs': blockDurationMs,
      'algorithm': algorithm.toString().split('.').last,
      'enableAutoCleanup': enableAutoCleanup,
      'cleanupIntervalMs': cleanupIntervalMs,
      'enableStatistics': enableStatistics,
      'identifierKey': identifierKey,
      'whitelist': whitelist,
      'blacklist': blacklist,
      'enableProgressivePenalties': enableProgressivePenalties,
      'penaltyMultiplier': penaltyMultiplier,
    };
  }

  /// Create from JSON representation
  static FastRateLimitConfig fromJson(Map<String, dynamic> json) {
    return FastRateLimitConfig(
      maxRequests: json['maxRequests'] as int? ?? 100,
      windowMs: json['windowMs'] as int? ?? 60 * 1000,
      burstCapacity: json['burstCapacity'] as int? ?? 10,
      blockDurationMs: json['blockDurationMs'] as int? ?? 15 * 60 * 1000,
      algorithm: FastRateLimitAlgorithm.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['algorithm'] as String? ?? 'slidingWindow'),
        orElse: () => FastRateLimitAlgorithm.slidingWindow,
      ),
      enableAutoCleanup: json['enableAutoCleanup'] as bool? ?? true,
      cleanupIntervalMs: json['cleanupIntervalMs'] as int? ?? 5 * 60 * 1000,
      enableStatistics: json['enableStatistics'] as bool? ?? true,
      identifierKey: json['identifierKey'] as String?,
      whitelist:
          (json['whitelist'] as List<dynamic>?)?.cast<String>() ?? const [],
      blacklist:
          (json['blacklist'] as List<dynamic>?)?.cast<String>() ?? const [],
      enableProgressivePenalties:
          json['enableProgressivePenalties'] as bool? ?? true,
      penaltyMultiplier: (json['penaltyMultiplier'] as num?)?.toDouble() ?? 2.0,
    );
  }

  @override
  String toString() {
    return 'FastRateLimitConfig{maxRequests: $maxRequests, windowMs: $windowMs, '
        'algorithm: $algorithm, blockDurationMs: $blockDurationMs}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastRateLimitConfig &&
        other.maxRequests == maxRequests &&
        other.windowMs == windowMs &&
        other.burstCapacity == burstCapacity &&
        other.blockDurationMs == blockDurationMs &&
        other.algorithm == algorithm;
  }

  @override
  int get hashCode {
    return maxRequests.hashCode ^
        windowMs.hashCode ^
        burstCapacity.hashCode ^
        blockDurationMs.hashCode ^
        algorithm.hashCode;
  }
}

/// Rate limiting algorithms
enum FastRateLimitAlgorithm {
  /// Fixed window algorithm - resets counter at fixed intervals
  fixedWindow,

  /// Sliding window algorithm - maintains rolling time window
  slidingWindow,

  /// Token bucket algorithm - refills tokens at constant rate
  tokenBucket,

  /// Leaky bucket algorithm - processes requests at constant rate
  leakyBucket,
}
