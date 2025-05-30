import '../model/fast_user.dart';

/// Mapper class for user-related transformations.
class FastUserMapper {
  /// Converts a JSON map to a [FastUser] instance.
  static FastUser fromJson(Map<String, dynamic> json) =>
      FastUser.fromJson(json);

  /// Converts a [FastUser] instance to a JSON map.
  static Map<String, dynamic> toJson(FastUser user) => user.toJson();
}
