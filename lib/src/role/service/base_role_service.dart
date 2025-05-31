import '../model/fast_role.dart';
import '../../common/model/fast_response.dart';

/// Abstract base class for role services.
///
/// Implement this class to provide custom role logic for your application.
abstract class BaseRoleService {
  /// Retrieves the list of roles for the user with the given [userId].
  ///
  /// Returns a [Future] that completes with a FastResponse containing a list of FastRole enums.
  Future<FastResponse<List<FastRole>>> getUserRoles(String userId);

  /// Checks if the user with the given [userId] has the specified [role].
  ///
  /// Returns a [Future] that completes with a FastResponse containing `true` if the user has the role, otherwise `false`.
  Future<FastResponse<bool>> hasRole(String userId, FastRole role);
}
