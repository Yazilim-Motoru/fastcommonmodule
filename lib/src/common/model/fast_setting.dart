/// Model representing a dynamic application setting/configuration.
class FastSetting {
  /// Unique setting id or key.
  final String id;

  /// Value of the setting (can be any type, stored as dynamic).
  final dynamic value;

  /// Optional user id (for user-specific settings).
  final String? userId;

  /// Optional role id (for role-specific settings).
  final String? roleId;

  /// Optional tenant id (for tenant-specific settings).
  final String? tenantId;

  /// Optional description or metadata.
  final String? description;

  /// Optional extra metadata.
  final Map<String, dynamic>? meta;

  /// Creates a [FastSetting] instance.
  const FastSetting({
    required this.id,
    required this.value,
    this.userId,
    this.roleId,
    this.tenantId,
    this.description,
    this.meta,
  });

  /// Creates a [FastSetting] from JSON.
  factory FastSetting.fromJson(Map<String, dynamic> json) => FastSetting(
        id: json['id'] as String,
        value: json['value'],
        userId: json['userId'],
        roleId: json['roleId'],
        tenantId: json['tenantId'],
        description: json['description'],
        meta: json['meta'] != null
            ? Map<String, dynamic>.from(json['meta'])
            : null,
      );

  /// Converts this [FastSetting] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        if (userId != null) 'userId': userId,
        if (roleId != null) 'roleId': roleId,
        if (tenantId != null) 'tenantId': tenantId,
        if (description != null) 'description': description,
        if (meta != null) 'meta': meta,
      };
}
