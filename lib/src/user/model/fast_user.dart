import '../../common/model/fast_model.dart';
import '../../role/model/fast_role.dart';

/// Model representing a user in FastCommonModule.
class FastUser extends FastModel {
  /// Username or display name (required).
  final String username;

  /// E-mail address (required).
  final String email;

  /// List of roles assigned to the user (required).
  final List<FastRole> roles;

  /// Optional phone number.
  final String? phone;

  /// Optional profile image URL.
  final String? profileImageUrl;

  /// Optional extra data for extensibility.
  final Map<String, dynamic>? extra;

  /// Creates a [FastUser] instance.
  const FastUser({
    required String id,
    required this.username,
    required this.email,
    required this.roles,
    this.phone,
    this.profileImageUrl,
    this.extra,
  }) : super(id: id);

  /// Creates a [FastUser] from a JSON map.
  static FastUser fromJson(Map<String, dynamic> json) => FastUser(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        roles: (json['roles'] as List<dynamic>)
            .map((e) => FastRole.values
                .firstWhere((r) => r.toString().split('.').last == e))
            .toList(),
        phone: json['phone'] as String?,
        profileImageUrl: json['profileImageUrl'] as String?,
        extra: json['extra'] as Map<String, dynamic>?,
      );

  /// Converts the user to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'roles': roles.map((e) => e.toString().split('.').last).toList(),
        if (phone != null) 'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (extra != null) 'extra': extra,
      };

  /// Returns a dummy [FastUser] instance for testing.
  static FastUser dummy() => FastUser(
        id: FastModel.randomString(12),
        username: 'dummyuser',
        email: 'dummy@example.com',
        roles: [FastRole.viewer],
        phone: '+9000000000',
        profileImageUrl: null,
        extra: const {'key': 'value'},
      );
}
