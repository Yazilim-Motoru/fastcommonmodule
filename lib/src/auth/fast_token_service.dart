/// FastTokenService provides JWT/token management for authentication and authorization.
///
/// Implement this interface to generate, validate, and refresh tokens.
abstract class FastTokenService {
  /// Generates a new JWT or token for the given user id and optional claims.
  Future<String> generateToken({
    required String userId,
    Map<String, dynamic>? claims,
    DateTime? expiresAt,
  });

  /// Validates the given token and returns the decoded payload if valid.
  /// Throws [FastException] if invalid or expired.
  Future<Map<String, dynamic>> validateToken(String token);

  /// Refreshes the given token and returns a new one.
  /// Throws [FastException] if the token is not refreshable.
  Future<String> refreshToken(String token);
}
