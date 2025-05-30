import '../model/fast_user.dart';
import '../../common/model/fast_response.dart';

/// Abstract service for user-related business logic.
///
/// Implement this class to provide custom user logic for your application.
abstract class FastUserService {
  /// Retrieves the current authenticated user, if any.
  Future<FastResponse<FastUser>> getCurrentUser();

  /// Checks if a user is authenticated.
  Future<FastResponse<bool>> isAuthenticated();

  /// Logs out the current user.
  Future<FastResponse<void>> logout();
}
