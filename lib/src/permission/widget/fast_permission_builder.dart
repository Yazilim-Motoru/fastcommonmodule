import 'package:flutter/widgets.dart';
import '../model/fast_permission.dart';

/// FastPermissionBuilder shows [builder] only if the user has the required permission(s).
///
/// Usage:
/// ```dart
/// FastPermissionBuilder(
///   permissions: [FastPermission.edit, FastPermission.delete],
///   userPermissions: currentUser.permissions, // List<FastPermission>
///   builder: (context) => ElevatedButton(...),
/// )
/// ```
class FastPermissionBuilder extends StatelessWidget {
  /// The required permissions (any or all, see [requireAll]).
  final List<FastPermission> permissions;

  /// The current user's permissions.
  final List<FastPermission> userPermissions;

  /// If true, all permissions are required. If false, any one is enough.
  final bool requireAll;

  /// The widget to show if permission check passes.
  final WidgetBuilder builder;

  /// The widget to show if permission check fails (optional).
  final WidgetBuilder? noAccessBuilder;

  /// Creates a [FastPermissionBuilder] widget.
  const FastPermissionBuilder({
    Key? key,
    required this.permissions,
    required this.userPermissions,
    required this.builder,
    this.noAccessBuilder,
    this.requireAll = false,
  }) : super(key: key);

  bool _hasPermission() {
    if (permissions.isEmpty) return true;
    if (userPermissions.isEmpty) return false;
    if (requireAll) {
      return permissions.every((p) => userPermissions.contains(p));
    } else {
      return permissions.any((p) => userPermissions.contains(p));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasPermission()) {
      return builder(context);
    } else if (noAccessBuilder != null) {
      return noAccessBuilder!(context);
    } else {
      return const SizedBox.shrink();
    }
  }
}
