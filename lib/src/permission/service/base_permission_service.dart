import '../model/fast_permission.dart';
import '../../common/model/fast_response.dart';

/// Abstract base class for permission services.
///
/// Implement this class to provide custom permission logic for your application.
abstract class BasePermissionService {
  /// Checks if the user has the specified permission.
  ///
  /// [permission]: The permission enum to check.
  /// Returns a [Future] that completes with a FastResponse containing `true` if the user has the permission, otherwise `false`.
  Future<FastResponse<bool>> hasPermission(FastPermission permission);

  /// Requests the specified permission from the user.
  ///
  /// [permission]: The permission enum to request.
  /// Returns a [Future] that completes with a FastResponse when the request is finished.
  Future<FastResponse<void>> requestPermission(FastPermission permission);
}
