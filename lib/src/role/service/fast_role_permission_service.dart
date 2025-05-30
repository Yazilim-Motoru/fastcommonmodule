import '../model/fast_role.dart';
import '../../permission/model/fast_permission.dart';
import '../../common/model/fast_response.dart';

/// Represents a dynamic permission, which can be used for fine-grained UI or action-level authorization.
class FastDynamicPermission {
  /// Unique key for the permission (e.g. 'page.settings.button.save').
  final String key;

  /// Optional description for the permission.
  final String? description;

  /// Optional default value (e.g. true/false for visibility).
  final bool? defaultValue;

  /// Creates a [FastDynamicPermission] instance.
  const FastDynamicPermission({
    required this.key,
    this.description,
    this.defaultValue,
  });
}

/// Abstract service for managing roles and their permissions with a data source (e.g., database).
///
/// Extend this class and override its methods to implement your own database logic.
abstract class FastRolePermissionService {
  /// Returns all roles in the system.
  Future<FastResponse<List<FastRole>>> getAllRoles();

  /// Returns all static (enum) permissions in the system.
  Future<FastResponse<List<FastPermission>>> getAllPermissions();

  /// Returns all dynamic permissions in the system (for UI, widgets, actions, etc.).
  Future<FastResponse<List<FastDynamicPermission>>> getAllDynamicPermissions();

  /// Returns the static permissions for the given [role].
  Future<FastResponse<List<FastPermission>>> getPermissionsForRole(
      FastRole role);

  /// Returns the dynamic permissions for the given [role].
  Future<FastResponse<List<FastDynamicPermission>>>
      getDynamicPermissionsForRole(FastRole role);

  /// Sets the static permissions for the given [role].
  Future<FastResponse<void>> setPermissionsForRole(
      FastRole role, List<FastPermission> permissions);

  /// Sets the dynamic permissions for the given [role].
  Future<FastResponse<void>> setDynamicPermissionsForRole(
      FastRole role, List<FastDynamicPermission> permissions);

  /// Adds a new role with its permissions.
  Future<FastResponse<void>> addRole(
      FastRole role, List<FastPermission> permissions,
      {List<FastDynamicPermission>? dynamicPermissions});

  /// Removes a role from the system.
  Future<FastResponse<void>> removeRole(FastRole role);

  /// Adds a static permission to a role.
  Future<FastResponse<void>> addPermissionToRole(
      FastRole role, FastPermission permission);

  /// Adds a dynamic permission to a role.
  Future<FastResponse<void>> addDynamicPermissionToRole(
      FastRole role, FastDynamicPermission permission);

  /// Removes a static permission from a role.
  Future<FastResponse<void>> removePermissionFromRole(
      FastRole role, FastPermission permission);

  /// Removes a dynamic permission from a role.
  Future<FastResponse<void>> removeDynamicPermissionFromRole(
      FastRole role, FastDynamicPermission permission);
}
