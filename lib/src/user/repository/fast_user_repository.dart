import '../model/fast_user.dart';
import '../../role/model/fast_role.dart';
import '../../common/model/fast_response.dart';

/// Abstract repository for managing FastUser data objects.
///
/// Implement this class to provide data access logic for your users.
abstract class FastUserRepository {
  /// Retrieves all users.
  Future<FastResponse<List<FastUser>>> getAll();

  /// Retrieves a user by their [id].
  Future<FastResponse<FastUser>> getById(String id);

  /// Adds a new [user].
  Future<FastResponse<void>> add(FastUser user);

  /// Updates an existing [user].
  Future<FastResponse<void>> update(FastUser user);

  /// Deletes a user by their [id].
  Future<FastResponse<void>> delete(String id);

  /// Retrieves the roles for the user with the given [userId].
  Future<FastResponse<List<FastRole>>> getUserRoles(String userId);

  /// Assigns roles to a user.
  Future<FastResponse<void>> setUserRoles(String userId, List<FastRole> roles);
}
