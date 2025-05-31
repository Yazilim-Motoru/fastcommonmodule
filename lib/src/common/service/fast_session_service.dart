import '../model/fast_session.dart';
import '../model/fast_response.dart';

/// Abstract service for user session/activity management.
abstract class FastSessionService {
  /// List all active sessions for a user.
  Future<FastResponse<List<FastSession>>> listUserSessions(String userId);

  /// Get a session by id.
  Future<FastResponse<FastSession>> getSession(String sessionId);

  /// End/terminate a session by id.
  Future<FastResponse<bool>> terminateSession(String sessionId);

  /// End all sessions for a user (except current).
  Future<FastResponse<bool>> terminateAllOtherSessions(
      String userId, String exceptSessionId);

  /// Update last activity time for a session.
  Future<FastResponse<bool>> updateLastActive(
      String sessionId, DateTime lastActiveAt);
}
