import '../user/model/fast_user.dart';
import '../common/model/fast_response.dart';

/// Abstract service for authentication operations.
///
/// Implement this class to provide custom authentication logic for your application.
abstract class BaseAuthService {
  /// Authenticates the user with the given [username] and [password].
  ///
  /// Returns a [FastResponse] containing the authenticated [FastUser] if successful, otherwise error info.
  Future<FastResponse<FastUser>> login(String username, String password);

  /// Registers a new user with the given [username], [email], [password], and optional [extra] data.
  ///
  /// Returns a [FastResponse] containing the created [FastUser] if successful, otherwise error info.
  Future<FastResponse<FastUser>> register({
    required String username,
    required String email,
    required String password,
    Map<String, dynamic>? extra,
  });

  /// Logs out the current user.
  ///
  /// Returns a [FastResponse] that completes when the logout process is finished.
  Future<FastResponse> logout();

  /// Checks if a user is currently authenticated.
  ///
  /// Returns a [FastResponse] with success/error info only.
  Future<FastResponse> isLoggedIn();
}
