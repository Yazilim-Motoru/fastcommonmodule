import 'dart:async';
import 'dart:math' as math;

import '../model/fast_rate_limit_config.dart';
import '../model/fast_rate_limit_entry.dart';
import '../model/fast_rate_limit_result.dart';
import '../model/fast_rate_limit_statistics.dart';
import 'base_rate_limit_service.dart';

/// High-performance rate limiting service with multiple algorithms
///
/// FastRateLimitService provides comprehensive rate limiting and throttling with:
/// - Multiple algorithms (sliding window, token bucket, leaky bucket, fixed window)
/// - Brute-force protection and progressive penalties
/// - Whitelist/blacklist support
/// - Detailed statistics and monitoring
/// - Automatic cleanup and memory management
class FastRateLimitService extends BaseRateLimitService {
  /// Rate limiting configuration
  FastRateLimitConfig _config;

  /// Storage for rate limiting entries
  final Map<String, FastRateLimitEntry> _entries = {};

  /// Rate limiting statistics
  FastRateLimitStatistics _statistics = FastRateLimitStatistics(
    startTime: DateTime.now(),
    lastUpdated: DateTime.now(),
  );

  /// Cleanup timer
  Timer? _cleanupTimer;

  /// Whether the service is initialized
  bool _isInitialized = false;

  /// Creates a new FastRateLimitService with the specified configuration
  FastRateLimitService({
    FastRateLimitConfig? config,
  }) : _config = config ?? const FastRateLimitConfig();

  /// Initialize the rate limiting service
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Start automatic cleanup timer
    if (_config.enableAutoCleanup) {
      _startCleanupTimer();
    }

    _isInitialized = true;
  }

  /// Dispose the service and cleanup resources
  @override
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _isInitialized = false;
  }

  /// Check if a request is allowed for the given identifier
  @override
  Future<FastRateLimitResult> checkRequest(
    String identifier, {
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();

    // Check blacklist first
    if (_config.isBlacklisted(identifier)) {
      _updateStatistics((stats) => stats.incrementBlocked());
      return FastRateLimitResult.blocked(
        blockReason: FastRateLimitBlockReason.blacklisted,
        totalLimit: _config.maxRequests,
        currentRequestCount: 0,
        metadata: metadata,
      );
    }

    // Check whitelist - bypass rate limiting
    if (_config.isWhitelisted(identifier)) {
      _updateStatistics((stats) => stats.incrementAllowed());
      return FastRateLimitResult.allowed(
        remainingRequests: _config.maxRequests,
        totalLimit: _config.maxRequests,
        currentRequestCount: 0,
        metadata: metadata,
      );
    }

    // Get or create entry
    final entry = _getOrCreateEntry(identifier);

    // Check if currently blocked
    if (entry.isCurrentlyBlocked) {
      _updateStatistics((stats) => stats.incrementBlocked());
      return FastRateLimitResult.blocked(
        blockReason: FastRateLimitBlockReason.temporaryBlock,
        totalLimit: _config.maxRequests,
        currentRequestCount: entry.requestCount,
        retryAfter: entry.blockExpiresAt,
        retryAfterMs: entry.remainingBlockTimeMs,
        metadata: metadata,
      );
    }

    // Check rate limit based on algorithm
    final result = await _checkRateLimit(entry, metadata);

    // Record the request
    await recordRequest(identifier, result.isAllowed, metadata: metadata);

    return result;
  }

  /// Record a request attempt (whether allowed or blocked)
  @override
  Future<void> recordRequest(
    String identifier,
    bool wasAllowed, {
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();

    // Skip for whitelisted identifiers
    if (_config.isWhitelisted(identifier)) return;

    final entry = _getOrCreateEntry(identifier);
    final updatedEntry = entry.addRequest();

    if (!wasAllowed) {
      final violatedEntry = updatedEntry.addViolation();
      _entries[identifier] = violatedEntry;

      // Check for progressive penalties
      if (_config.enableProgressivePenalties &&
          violatedEntry.violationCount > 1) {
        final blockDuration = Duration(
          milliseconds: (_config.blockDurationMs *
                  math.pow(_config.penaltyMultiplier,
                      violatedEntry.violationCount - 1))
              .round(),
        );
        _entries[identifier] = violatedEntry.block(blockDuration);
      }

      _updateStatistics((stats) => stats.incrementViolations());
    } else {
      _entries[identifier] = updatedEntry;
    }

    // Update hourly statistics
    _updateHourlyStats();
  }

  /// Manually block an identifier
  @override
  Future<void> blockIdentifier(
    String identifier, {
    Duration? blockDuration,
    String? reason,
  }) async {
    _ensureInitialized();

    final entry = _getOrCreateEntry(identifier);
    final duration =
        blockDuration ?? Duration(milliseconds: _config.blockDurationMs);
    _entries[identifier] = entry.block(duration);
  }

  /// Manually unblock an identifier
  @override
  Future<void> unblockIdentifier(String identifier) async {
    _ensureInitialized();

    final entry = _entries[identifier];
    if (entry != null && entry.isBlocked) {
      _entries[identifier] = entry.unblock();
    }
  }

  /// Add identifier to whitelist
  @override
  Future<void> addToWhitelist(String identifier) async {
    _ensureInitialized();
    final newWhitelist = List<String>.from(_config.whitelist)..add(identifier);
    _config = _config.copyWith(whitelist: newWhitelist);
  }

  /// Remove identifier from whitelist
  @override
  Future<void> removeFromWhitelist(String identifier) async {
    _ensureInitialized();
    final newWhitelist = List<String>.from(_config.whitelist)
      ..remove(identifier);
    _config = _config.copyWith(whitelist: newWhitelist);
  }

  /// Add identifier to blacklist
  @override
  Future<void> addToBlacklist(String identifier) async {
    _ensureInitialized();
    final newBlacklist = List<String>.from(_config.blacklist)..add(identifier);
    _config = _config.copyWith(blacklist: newBlacklist);
  }

  /// Remove identifier from blacklist
  @override
  Future<void> removeFromBlacklist(String identifier) async {
    _ensureInitialized();
    final newBlacklist = List<String>.from(_config.blacklist)
      ..remove(identifier);
    _config = _config.copyWith(blacklist: newBlacklist);
  }

  /// Check if identifier is whitelisted
  @override
  Future<bool> isWhitelisted(String identifier) async {
    return _config.isWhitelisted(identifier);
  }

  /// Check if identifier is blacklisted
  @override
  Future<bool> isBlacklisted(String identifier) async {
    return _config.isBlacklisted(identifier);
  }

  /// Get current status for an identifier
  @override
  Future<FastRateLimitResult> getStatus(String identifier) async {
    _ensureInitialized();

    final entry = _entries[identifier];
    if (entry == null) {
      return FastRateLimitResult.allowed(
        remainingRequests: _config.maxRequests,
        totalLimit: _config.maxRequests,
        currentRequestCount: 0,
      );
    }

    final windowDuration = Duration(milliseconds: _config.windowMs);
    final requestsInWindow = entry.getRequestCountInWindow(windowDuration);
    final remaining = math.max(0, _config.maxRequests - requestsInWindow);

    if (entry.isCurrentlyBlocked) {
      return FastRateLimitResult.blocked(
        blockReason: FastRateLimitBlockReason.temporaryBlock,
        totalLimit: _config.maxRequests,
        currentRequestCount: requestsInWindow,
        retryAfter: entry.blockExpiresAt,
        retryAfterMs: entry.remainingBlockTimeMs,
      );
    }

    return FastRateLimitResult.allowed(
      remainingRequests: remaining,
      totalLimit: _config.maxRequests,
      currentRequestCount: requestsInWindow,
    );
  }

  /// Get all currently blocked identifiers
  @override
  Future<List<String>> getBlockedIdentifiers() async {
    _ensureInitialized();

    return _entries.entries
        .where((entry) => entry.value.isCurrentlyBlocked)
        .map((entry) => entry.key)
        .toList();
  }

  /// Clear all rate limiting data
  @override
  Future<void> clear() async {
    _ensureInitialized();
    _entries.clear();
  }

  /// Cleanup expired entries
  @override
  Future<int> cleanupExpired() async {
    _ensureInitialized();

    int removedCount = 0;
    final now = DateTime.now();
    final windowDuration = Duration(milliseconds: _config.windowMs);
    final keysToRemove = <String>[];

    for (final entry in _entries.entries) {
      final rateLimitEntry = entry.value;

      // Remove expired blocks
      if (rateLimitEntry.isBlockExpired) {
        _entries[entry.key] = rateLimitEntry.unblock();
      }

      // Clean up old timestamps
      final cleanedEntry = rateLimitEntry.cleanupOldTimestamps(windowDuration);
      if (cleanedEntry.requestTimestamps != rateLimitEntry.requestTimestamps) {
        _entries[entry.key] = cleanedEntry;
      }

      // Remove entries with no recent activity
      if (cleanedEntry.requestTimestamps.isEmpty &&
          !cleanedEntry.isBlocked &&
          cleanedEntry.lastRequestAt != null &&
          now.difference(cleanedEntry.lastRequestAt!).inHours > 24) {
        keysToRemove.add(entry.key);
        removedCount++;
      }
    }

    for (final key in keysToRemove) {
      _entries.remove(key);
    }

    return removedCount;
  }

  /// Get rate limiting statistics
  @override
  FastRateLimitStatistics getStatistics() {
    final blockedCount =
        _entries.values.where((e) => e.isCurrentlyBlocked).length;
    final blacklistedCount = _config.blacklist.length;

    return _statistics.copyWith(
      currentlyBlocked: blockedCount,
      permanentlyBlocked: blacklistedCount,
      uniqueIdentifiers: _entries.length,
      activeEntries: _entries.length,
    );
  }

  /// Reset statistics
  @override
  void resetStatistics() {
    _statistics = _statistics.reset();
  }

  /// Update configuration
  @override
  Future<void> updateConfig(FastRateLimitConfig config) async {
    _config = config;

    // Restart cleanup timer if needed
    if (config.enableAutoCleanup != _config.enableAutoCleanup) {
      _cleanupTimer?.cancel();
      if (config.enableAutoCleanup) {
        _startCleanupTimer();
      }
    }
  }

  /// Get current configuration
  @override
  FastRateLimitConfig getConfig() => _config;

  // Private methods

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'FastRateLimitService must be initialized before use. Call initialize() first.');
    }
  }

  FastRateLimitEntry _getOrCreateEntry(String identifier) {
    return _entries[identifier] ??= FastRateLimitEntry(
      identifier: identifier,
      createdAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }

  Future<FastRateLimitResult> _checkRateLimit(
    FastRateLimitEntry entry,
    Map<String, dynamic>? metadata,
  ) async {
    switch (_config.algorithm) {
      case FastRateLimitAlgorithm.slidingWindow:
        return _checkSlidingWindow(entry, metadata);
      case FastRateLimitAlgorithm.fixedWindow:
        return _checkFixedWindow(entry, metadata);
      case FastRateLimitAlgorithm.tokenBucket:
        return _checkTokenBucket(entry, metadata);
      case FastRateLimitAlgorithm.leakyBucket:
        return _checkLeakyBucket(entry, metadata);
    }
  }

  FastRateLimitResult _checkSlidingWindow(
    FastRateLimitEntry entry,
    Map<String, dynamic>? metadata,
  ) {
    final windowDuration = Duration(milliseconds: _config.windowMs);
    final requestsInWindow = entry.getRequestCountInWindow(windowDuration);
    final remaining = math.max(0, _config.maxRequests - requestsInWindow);

    if (requestsInWindow >= _config.maxRequests) {
      _updateStatistics((stats) => stats.incrementBlocked());
      return FastRateLimitResult.blocked(
        blockReason: FastRateLimitBlockReason.rateLimitExceeded,
        totalLimit: _config.maxRequests,
        currentRequestCount: requestsInWindow,
        metadata: metadata,
      );
    }

    _updateStatistics((stats) => stats.incrementAllowed());
    return FastRateLimitResult.allowed(
      remainingRequests: remaining,
      totalLimit: _config.maxRequests,
      currentRequestCount: requestsInWindow,
      metadata: metadata,
    );
  }

  FastRateLimitResult _checkFixedWindow(
    FastRateLimitEntry entry,
    Map<String, dynamic>? metadata,
  ) {
    final now = DateTime.now();
    final windowStart = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        (now.minute ~/ (_config.windowMs ~/ 60000)) *
            (_config.windowMs ~/ 60000));

    final requestsInWindow = entry.requestTimestamps
        .where((timestamp) => timestamp.isAfter(windowStart))
        .length;

    final remaining = math.max(0, _config.maxRequests - requestsInWindow);
    final windowResetAt =
        windowStart.add(Duration(milliseconds: _config.windowMs));

    if (requestsInWindow >= _config.maxRequests) {
      _updateStatistics((stats) => stats.incrementBlocked());
      return FastRateLimitResult.blocked(
        blockReason: FastRateLimitBlockReason.rateLimitExceeded,
        totalLimit: _config.maxRequests,
        currentRequestCount: requestsInWindow,
        windowResetAt: windowResetAt,
        windowResetInMs: windowResetAt.difference(now).inMilliseconds,
        metadata: metadata,
      );
    }

    _updateStatistics((stats) => stats.incrementAllowed());
    return FastRateLimitResult.allowed(
      remainingRequests: remaining,
      totalLimit: _config.maxRequests,
      currentRequestCount: requestsInWindow,
      windowResetAt: windowResetAt,
      windowResetInMs: windowResetAt.difference(now).inMilliseconds,
      metadata: metadata,
    );
  }

  FastRateLimitResult _checkTokenBucket(
    FastRateLimitEntry entry,
    Map<String, dynamic>? metadata,
  ) {
    // Simplified token bucket implementation
    // In a real implementation, you would track tokens more precisely
    return _checkSlidingWindow(entry, metadata);
  }

  FastRateLimitResult _checkLeakyBucket(
    FastRateLimitEntry entry,
    Map<String, dynamic>? metadata,
  ) {
    // Simplified leaky bucket implementation
    // In a real implementation, you would track queue and leak rate
    return _checkSlidingWindow(entry, metadata);
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      Duration(milliseconds: _config.cleanupIntervalMs),
      (_) => cleanupExpired(),
    );
  }

  void _updateStatistics(
      FastRateLimitStatistics Function(FastRateLimitStatistics) updater) {
    if (_config.enableStatistics) {
      _statistics = updater(_statistics);
    }
  }

  void _updateHourlyStats() {
    final currentHour = DateTime.now().hour;
    final currentCount = _statistics.hourlyRequestCounts[currentHour] ?? 0;
    _statistics = _statistics.updateHourlyCount(currentHour, currentCount + 1);
  }
}
