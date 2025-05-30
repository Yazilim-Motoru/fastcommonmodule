import '../model/fast_user.dart';
import '../../permission/model/fast_permission.dart';
import '../../role/service/fast_role_permission_service.dart';
import '../../common/model/fast_response.dart';

/// Service to aggregate all permissions (static and dynamic) for a user.
abstract class FastUserPermissionService {
  /// Returns all static (enum) permissions for the given user.
  Future<FastResponse<List<FastPermission>>> getUserPermissions(FastUser user);

  /// Returns all dynamic permissions for the given user.
  Future<FastResponse<List<FastDynamicPermission>>> getUserDynamicPermissions(
      FastUser user);

  /// Checks if the user has the given static permission.
  Future<FastResponse<bool>> hasPermission(
      FastUser user, FastPermission permission);

  /// Checks if the user has the given dynamic permission key.
  Future<FastResponse<bool>> hasDynamicPermission(
      FastUser user, String dynamicPermissionKey);
}
