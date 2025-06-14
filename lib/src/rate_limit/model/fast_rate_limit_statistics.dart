/// Rate limiting statistics model for monitoring and analysis
///
/// This model tracks rate limiting performance, violations,
/// and usage patterns for security monitoring and optimization.
class FastRateLimitStatistics {
  /// Total number of requests processed
  final int totalRequests;

  /// Number of requests allowed
  final int allowedRequests;

  /// Number of requests blocked
  final int blockedRequests;

  /// Number of rate limit violations
  final int violations;

  /// Number of identifiers currently blocked
  final int currentlyBlocked;

  /// Number of identifiers permanently blocked (blacklisted)
  final int permanentlyBlocked;

  /// Total number of unique identifiers seen
  final int uniqueIdentifiers;

  /// Number of active entries in the system
  final int activeEntries;

  /// When statistics tracking started
  final DateTime startTime;

  /// When statistics were last updated
  final DateTime lastUpdated;

  /// Top blocked identifiers with their violation counts
  final Map<String, int> topBlockedIdentifiers;

  /// Request counts by hour for the last 24 hours
  final Map<int, int> hourlyRequestCounts;

  /// Creates a new rate limit statistics instance with the specified parameters
  const FastRateLimitStatistics({
    this.totalRequests = 0,
    this.allowedRequests = 0,
    this.blockedRequests = 0,
    this.violations = 0,
    this.currentlyBlocked = 0,
    this.permanentlyBlocked = 0,
    this.uniqueIdentifiers = 0,
    this.activeEntries = 0,
    required this.startTime,
    required this.lastUpdated,
    this.topBlockedIdentifiers = const {},
    this.hourlyRequestCounts = const {},
  });

  /// Block ratio (0.0 to 1.0)
  double get blockRatio {
    if (totalRequests == 0) return 0.0;
    return blockedRequests / totalRequests;
  }

  /// Allow ratio (0.0 to 1.0)
  double get allowRatio {
    if (totalRequests == 0) return 1.0;
    return allowedRequests / totalRequests;
  }

  /// Violation ratio (0.0 to 1.0)
  double get violationRatio {
    if (totalRequests == 0) return 0.0;
    return violations / totalRequests;
  }

  /// Block ratio as percentage (0 to 100)
  double get blockRatioPercentage => blockRatio * 100;

  /// Allow ratio as percentage (0 to 100)
  double get allowRatioPercentage => allowRatio * 100;

  /// Violation ratio as percentage (0 to 100)
  double get violationRatioPercentage => violationRatio * 100;

  /// Statistics duration since tracking started
  Duration get duration => lastUpdated.difference(startTime);

  /// Average requests per second
  double get requestsPerSecond {
    final seconds = duration.inSeconds;
    if (seconds == 0) return 0.0;
    return totalRequests / seconds;
  }

  /// Average requests per minute
  double get requestsPerMinute {
    final minutes = duration.inMinutes;
    if (minutes == 0) return 0.0;
    return totalRequests / minutes;
  }

  /// Average requests per hour
  double get requestsPerHour {
    final hours = duration.inHours;
    if (hours == 0) return 0.0;
    return totalRequests / hours;
  }

  /// Get requests for the current hour
  int get currentHourRequests {
    final currentHour = DateTime.now().hour;
    return hourlyRequestCounts[currentHour] ?? 0;
  }

  /// Get peak hour with highest request count
  MapEntry<int, int>? get peakHour {
    if (hourlyRequestCounts.isEmpty) return null;
    return hourlyRequestCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
  }

  /// Create a copy with updated values
  FastRateLimitStatistics copyWith({
    int? totalRequests,
    int? allowedRequests,
    int? blockedRequests,
    int? violations,
    int? currentlyBlocked,
    int? permanentlyBlocked,
    int? uniqueIdentifiers,
    int? activeEntries,
    DateTime? startTime,
    DateTime? lastUpdated,
    Map<String, int>? topBlockedIdentifiers,
    Map<int, int>? hourlyRequestCounts,
  }) {
    return FastRateLimitStatistics(
      totalRequests: totalRequests ?? this.totalRequests,
      allowedRequests: allowedRequests ?? this.allowedRequests,
      blockedRequests: blockedRequests ?? this.blockedRequests,
      violations: violations ?? this.violations,
      currentlyBlocked: currentlyBlocked ?? this.currentlyBlocked,
      permanentlyBlocked: permanentlyBlocked ?? this.permanentlyBlocked,
      uniqueIdentifiers: uniqueIdentifiers ?? this.uniqueIdentifiers,
      activeEntries: activeEntries ?? this.activeEntries,
      startTime: startTime ?? this.startTime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      topBlockedIdentifiers:
          topBlockedIdentifiers ?? this.topBlockedIdentifiers,
      hourlyRequestCounts: hourlyRequestCounts ?? this.hourlyRequestCounts,
    );
  }

  /// Increment allowed request count
  FastRateLimitStatistics incrementAllowed() {
    return copyWith(
      totalRequests: totalRequests + 1,
      allowedRequests: allowedRequests + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment blocked request count
  FastRateLimitStatistics incrementBlocked() {
    return copyWith(
      totalRequests: totalRequests + 1,
      blockedRequests: blockedRequests + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Increment violation count
  FastRateLimitStatistics incrementViolations() {
    return copyWith(
      violations: violations + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update hourly request count
  FastRateLimitStatistics updateHourlyCount(int hour, int count) {
    final newHourlyCounts = Map<int, int>.from(hourlyRequestCounts);
    newHourlyCounts[hour] = count;

    return copyWith(
      hourlyRequestCounts: newHourlyCounts,
      lastUpdated: DateTime.now(),
    );
  }

  /// Add blocked identifier to top list
  FastRateLimitStatistics addBlockedIdentifier(
      String identifier, int violationCount) {
    final newTopBlocked = Map<String, int>.from(topBlockedIdentifiers);
    newTopBlocked[identifier] = violationCount;

    // Keep only top 10
    if (newTopBlocked.length > 10) {
      final sortedEntries = newTopBlocked.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      newTopBlocked.clear();
      newTopBlocked.addEntries(sortedEntries.take(10));
    }

    return copyWith(
      topBlockedIdentifiers: newTopBlocked,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reset all statistics
  FastRateLimitStatistics reset() {
    final now = DateTime.now();
    return FastRateLimitStatistics(
      startTime: now,
      lastUpdated: now,
    );
  }

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'allowedRequests': allowedRequests,
      'blockedRequests': blockedRequests,
      'violations': violations,
      'currentlyBlocked': currentlyBlocked,
      'permanentlyBlocked': permanentlyBlocked,
      'uniqueIdentifiers': uniqueIdentifiers,
      'activeEntries': activeEntries,
      'startTime': startTime.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'topBlockedIdentifiers': topBlockedIdentifiers,
      'hourlyRequestCounts': hourlyRequestCounts,
      'blockRatio': blockRatio,
      'allowRatio': allowRatio,
      'violationRatio': violationRatio,
      'requestsPerSecond': requestsPerSecond,
      'requestsPerMinute': requestsPerMinute,
      'requestsPerHour': requestsPerHour,
    };
  }

  /// Create from JSON representation
  static FastRateLimitStatistics fromJson(Map<String, dynamic> json) {
    return FastRateLimitStatistics(
      totalRequests: json['totalRequests'] as int? ?? 0,
      allowedRequests: json['allowedRequests'] as int? ?? 0,
      blockedRequests: json['blockedRequests'] as int? ?? 0,
      violations: json['violations'] as int? ?? 0,
      currentlyBlocked: json['currentlyBlocked'] as int? ?? 0,
      permanentlyBlocked: json['permanentlyBlocked'] as int? ?? 0,
      uniqueIdentifiers: json['uniqueIdentifiers'] as int? ?? 0,
      activeEntries: json['activeEntries'] as int? ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      topBlockedIdentifiers:
          (json['topBlockedIdentifiers'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as int)) ??
              const {},
      hourlyRequestCounts:
          (json['hourlyRequestCounts'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
              const {},
    );
  }

  @override
  String toString() {
    return 'FastRateLimitStatistics{\n'
        '  totalRequests: $totalRequests, allowed: $allowedRequests, blocked: $blockedRequests\n'
        '  blockRatio: ${blockRatioPercentage.toStringAsFixed(1)}%, violations: $violations\n'
        '  currentlyBlocked: $currentlyBlocked, uniqueIdentifiers: $uniqueIdentifiers\n'
        '  requestsPerSecond: ${requestsPerSecond.toStringAsFixed(2)}\n'
        '  duration: ${duration.inMinutes}min\n'
        '}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FastRateLimitStatistics &&
        other.totalRequests == totalRequests &&
        other.allowedRequests == allowedRequests &&
        other.blockedRequests == blockedRequests &&
        other.violations == violations &&
        other.startTime == startTime;
  }

  @override
  int get hashCode {
    return totalRequests.hashCode ^
        allowedRequests.hashCode ^
        blockedRequests.hashCode ^
        violations.hashCode ^
        startTime.hashCode;
  }
}
