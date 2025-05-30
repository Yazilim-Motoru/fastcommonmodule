import '../model/fast_role.dart';
import '../../permission/model/fast_permission.dart';

/// A utility class to manage roles and their permissions dynamically.
class RolePermissionMapper {
  // Internal map to store permissions for each role.
  static final Map<FastRole, List<FastPermission>> _rolePermissions = {
    FastRole.admin: [
      FastPermission.view,
      FastPermission.read,
      FastPermission.edit,
      FastPermission.delete,
    ],
    FastRole.editor: [
      FastPermission.view,
      FastPermission.read,
      FastPermission.edit,
    ],
    FastRole.viewer: [
      FastPermission.view,
      FastPermission.read,
    ],
    FastRole.guest: [
      FastPermission.view,
    ],
  };

  /// Returns the list of permissions for the given [role].
  static List<FastPermission> getPermissions(FastRole role) {
    return List.unmodifiable(_rolePermissions[role] ?? []);
  }

  /// Sets the permissions for the given [role].
  static void setPermissions(FastRole role, List<FastPermission> permissions) {
    _rolePermissions[role] = List.from(permissions);
  }

  /// Adds a new role with its permissions.
  static void addRole(FastRole role, List<FastPermission> permissions) {
    _rolePermissions[role] = List.from(permissions);
  }

  /// Removes a role from the system.
  static void removeRole(FastRole role) {
    _rolePermissions.remove(role);
  }

  /// Adds a permission to a role.
  static void addPermissionToRole(FastRole role, FastPermission permission) {
    final perms = _rolePermissions[role] ?? [];
    if (!perms.contains(permission)) {
      perms.add(permission);
      _rolePermissions[role] = perms;
    }
  }

  /// Removes a permission from a role.
  static void removePermissionFromRole(
      FastRole role, FastPermission permission) {
    final perms = _rolePermissions[role];
    if (perms != null && perms.contains(permission)) {
      perms.remove(permission);
      _rolePermissions[role] = perms;
    }
  }

  /// Returns all roles and their permissions.
  static Map<FastRole, List<FastPermission>> getAllRolePermissions() {
    return Map.unmodifiable(_rolePermissions);
  }
}
