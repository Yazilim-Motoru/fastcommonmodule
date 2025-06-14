/// Rate limiting check result
///
/// This model represents the result of a rate limiting check,
/// including whether the request is allowed, remaining quota,
/// and retry information.
class FastRateLimitResult {
  /// Whether the request is allowed
  final bool isAllowed;

  /// Reason for blocking (if blocked)
  final FastRateLimitBlockReason? blockReason;

  /// Number of requests remaining in the current window
  final int remainingRequests;

  /// Total request limit for the window
  final int totalLimit;

  /// Time when the window will reset (for fixed window)
  final DateTime? windowResetAt;

  /// Time when the client should retry (if blocked)
  final DateTime? retryAfter;

  /// Current request count in the window
  final int currentRequestCount;

  /// Time remaining in milliseconds until window reset
  final int? windowResetInMs;

  /// Time remaining in milliseconds until retry is allowed
  final int? retryAfterMs;

  /// Additional information about the rate limiting
  final Map<String, dynamic>? metadata;

  /// Creates a new rate limit result with the specified parameters
  const FastRateLimitResult({
    required this.isAllowed,
    this.blockReason,
    required this.remainingRequests,
    required this.totalLimit,
    this.windowResetAt,
    this.retryAfter,
    required this.currentRequestCount,
    this.windowResetInMs,
    this.retryAfterMs,
    this.metadata,
  });

  /// Create an allowed result
  factory FastRateLimitResult.allowed({
    required int remainingRequests,
    required int totalLimit,
    required int currentRequestCount,
    DateTime? windowResetAt,
    int? windowResetInMs,
    Map<String, dynamic>? metadata,
  }) {
    return FastRateLimitResult(
      isAllowed: true,
      remainingRequests: remainingRequests,
      totalLimit: totalLimit,
      currentRequestCount: currentRequestCount,
      windowResetAt: windowResetAt,
      windowResetInMs: windowResetInMs,
      metadata: metadata,
    );
  }

  /// Create a blocked result
  factory FastRateLimitResult.blocked({
    required FastRateLimitBlockReason blockReason,
    required int totalLimit,
    required int currentRequestCount,
    DateTime? retryAfter,
    int? retryAfterMs,
    DateTime? windowResetAt,
    int? windowResetInMs,
    Map<String, dynamic>? metadata,
  }) {
    return FastRateLimitResult(
      isAllowed: false,
      blockReason: blockReason,
      remainingRequests: 0,
      totalLimit: totalLimit,
      currentRequestCount: currentRequestCount,
      retryAfter: retryAfter,
      retryAfterMs: retryAfterMs,
      windowResetAt: windowResetAt,
      windowResetInMs: windowResetInMs,
      metadata: metadata,
    );
  }

  /// Whether the request was blocked
  bool get isBlocked => !isAllowed;

  /// Check if this is a rate limit violation
  bool get isRateLimitExceeded =>
      blockReason == FastRateLimitBlockReason.rateLimitExceeded;

  /// Check if this is a permanent block (blacklist)
  bool get isPermanentlyBlocked =>
      blockReason == FastRateLimitBlockReason.blacklisted;

  /// Check if this is a temporary block
  bool get isTemporarilyBlocked =>
      blockReason == FastRateLimitBlockReason.temporaryBlock;

  /// Get utilization percentage (0-100)
  double get utilizationPercentage {
    if (totalLimit == 0) return 0.0;
    return (currentRequestCount / totalLimit) * 100;
  }

  /// Get formatted retry after time
  String? get retryAfterFormatted {
    if (retryAfter == null) return null;
    final duration = retryAfter!.difference(DateTime.now());

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Convert to HTTP headers map
  Map<String, String> toHttpHeaders() {
    final headers = <String, String>{
      'X-RateLimit-Limit': totalLimit.toString(),
      'X-RateLimit-Remaining': remainingRequests.toString(),
      'X-RateLimit-Used': currentRequestCount.toString(),
    };

    if (windowResetAt != null) {
      headers['X-RateLimit-Reset'] =
          (windowResetAt!.millisecondsSinceEpoch ~/ 1000).toString();
    }

    if (windowResetInMs != null) {
      headers['X-RateLimit-Reset-After'] =
          (windowResetInMs! ~/ 1000).toString();
    }

    if (retryAfter != null) {
      headers['Retry-After'] =
          (retryAfter!.millisecondsSinceEpoch ~/ 1000).toString();
    }

    if (retryAfterMs != null) {
      headers['X-RateLimit-Retry-After-Ms'] = retryAfterMs.toString();
    }

    return headers;
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'isAllowed': isAllowed,
      'blockReason': blockReason?.toString().split('.').last,
      'remainingRequests': remainingRequests,
      'totalLimit': totalLimit,
      'windowResetAt': windowResetAt?.toIso8601String(),
      'retryAfter': retryAfter?.toIso8601String(),
      'currentRequestCount': currentRequestCount,
      'windowResetInMs': windowResetInMs,
      'retryAfterMs': retryAfterMs,
      'utilizationPercentage': utilizationPercentage,
      'metadata': metadata,
    };
  }

  /// Create from JSON representation
  static FastRateLimitResult fromJson(Map<String, dynamic> json) {
    return FastRateLimitResult(
      isAllowed: json['isAllowed'] as bool,
      blockReason: json['blockReason'] != null
          ? FastRateLimitBlockReason.values.firstWhere(
              (e) => e.toString().split('.').last == json['blockReason'],
              orElse: () => FastRateLimitBlockReason.rateLimitExceeded,
            )
          : null,
      remainingRequests: json['remainingRequests'] as int,
      totalLimit: json['totalLimit'] as int,
      windowResetAt: json['windowResetAt'] != null
          ? DateTime.parse(json['windowResetAt'] as String)
          : null,
      retryAfter: json['retryAfter'] != null
          ? DateTime.parse(json['retryAfter'] as String)
          : null,
      currentRequestCount: json['currentRequestCount'] as int,
      windowResetInMs: json['windowResetInMs'] as int?,
      retryAfterMs: json['retryAfterMs'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FastRateLimitResult{isAllowed: $isAllowed, remainingRequests: $remainingRequests, '
        'totalLimit: $totalLimit, blockReason: $blockReason, retryAfter: $retryAfter}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastRateLimitResult &&
        other.isAllowed == isAllowed &&
        other.blockReason == blockReason &&
        other.remainingRequests == remainingRequests &&
        other.totalLimit == totalLimit &&
        other.currentRequestCount == currentRequestCount;
  }

  @override
  int get hashCode {
    return isAllowed.hashCode ^
        blockReason.hashCode ^
        remainingRequests.hashCode ^
        totalLimit.hashCode ^
        currentRequestCount.hashCode;
  }
}

/// Reasons for rate limiting blocks
enum FastRateLimitBlockReason {
  /// Rate limit exceeded
  rateLimitExceeded,

  /// Identifier is blacklisted
  blacklisted,

  /// Temporary block due to violations
  temporaryBlock,

  /// Burst capacity exceeded
  burstExceeded,

  /// Custom block reason
  custom,
}
