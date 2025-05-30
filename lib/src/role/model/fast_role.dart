/// Enum representing roles in FastCommonModule.
///
/// Use this enum to define static roles. Extend as needed.
enum FastRole {
  /// Administrator role with all permissions.
  admin,

  /// Editor role with content modification permissions.
  editor,

  /// Viewer role with read-only permissions.
  viewer,

  /// Guest role with minimal access.
  guest,
}
