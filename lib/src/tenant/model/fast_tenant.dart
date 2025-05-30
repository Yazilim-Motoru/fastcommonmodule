import '../../common/model/fast_model.dart';

/// FastTenant represents a tenant (organization/customer) in a multi-tenant system.
class FastTenant extends FastModel {
  /// Tenant display name.
  final String name;

  /// Optional description or metadata.
  final String? description;

  /// Optional extra data for extensibility.
  final Map<String, dynamic>? extra;

  /// Creates a [FastTenant] instance.
  const FastTenant({
    required String id,
    required this.name,
    this.description,
    this.extra,
  }) : super(id: id);

  /// Creates a [FastTenant] from a JSON map.
  factory FastTenant.fromJson(Map<String, dynamic> json) => FastTenant(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        extra: json['extra'] as Map<String, dynamic>?,
      );

  /// Converts the tenant to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        if (extra != null) 'extra': extra,
      };

  /// Returns a dummy [FastTenant] instance for testing.
  static FastTenant dummy() => FastTenant(
        id: FastModel.randomString(12),
        name: 'Dummy Tenant',
        description: 'A dummy tenant for testing.',
        extra: const {'key': 'value'},
      );
}
