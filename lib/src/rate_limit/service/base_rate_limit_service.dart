import '../model/fast_rate_limit_config.dart';
import '../model/fast_rate_limit_result.dart';
import '../model/fast_rate_limit_statistics.dart';

/// Base interface for rate limiting services
///
/// This abstract class defines the contract for rate limiting implementations,
/// allowing for different algorithms and storage backends.
abstract class BaseRateLimitService {
  /// Initialize the rate limiting service
  Future<void> initialize();

  /// Dispose the service and cleanup resources
  Future<void> dispose();

  /// Check if a request is allowed for the given identifier
  Future<FastRateLimitResult> checkRequest(
    String identifier, {
    Map<String, dynamic>? metadata,
  });

  /// Record a request attempt (whether allowed or blocked)
  Future<void> recordRequest(
    String identifier,
    bool wasAllowed, {
    Map<String, dynamic>? metadata,
  });

  /// Manually block an identifier
  Future<void> blockIdentifier(
    String identifier, {
    Duration? blockDuration,
    String? reason,
  });

  /// Manually unblock an identifier
  Future<void> unblockIdentifier(String identifier);

  /// Add identifier to whitelist
  Future<void> addToWhitelist(String identifier);

  /// Remove identifier from whitelist
  Future<void> removeFromWhitelist(String identifier);

  /// Add identifier to blacklist
  Future<void> addToBlacklist(String identifier);

  /// Remove identifier from blacklist
  Future<void> removeFromBlacklist(String identifier);

  /// Check if identifier is whitelisted
  Future<bool> isWhitelisted(String identifier);

  /// Check if identifier is blacklisted
  Future<bool> isBlacklisted(String identifier);

  /// Get current status for an identifier
  Future<FastRateLimitResult> getStatus(String identifier);

  /// Get all currently blocked identifiers
  Future<List<String>> getBlockedIdentifiers();

  /// Clear all rate limiting data
  Future<void> clear();

  /// Cleanup expired entries
  Future<int> cleanupExpired();

  /// Get rate limiting statistics
  FastRateLimitStatistics getStatistics();

  /// Reset statistics
  void resetStatistics();

  /// Update configuration
  Future<void> updateConfig(FastRateLimitConfig config);

  /// Get current configuration
  FastRateLimitConfig getConfig();
}
