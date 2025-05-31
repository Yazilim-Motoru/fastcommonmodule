import '../enums/fast_file_type.dart';
import '../../permission/model/fast_permission.dart';

/// Model representing file/media metadata.
class FastFileMeta {
  /// Unique file id.
  final String id;

  /// File name.
  final String name;

  /// File type (image, video, etc).
  final FastFileType type;

  /// File size in bytes.
  final int size;

  /// MIME type (e.g. image/png).
  final String mimeType;

  /// URL or storage path.
  final String url;

  /// Uploader user id.
  final String? uploadedBy;

  /// Upload timestamp.
  final DateTime uploadedAt;

  /// Optional access permissions (FastPermission-based).
  final List<FastPermission>? access;

  /// Optional extra metadata.
  final Map<String, dynamic>? meta;

  /// Creates a [FastFileMeta] instance.
  const FastFileMeta({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.mimeType,
    required this.url,
    this.uploadedBy,
    required this.uploadedAt,
    this.access,
    this.meta,
  });

  /// Creates a [FastFileMeta] from JSON.
  factory FastFileMeta.fromJson(Map<String, dynamic> json) => FastFileMeta(
        id: json['id'] as String,
        name: json['name'] as String,
        type: FastFileType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
        size: json['size'] as int,
        mimeType: json['mimeType'] as String,
        url: json['url'] as String,
        uploadedBy: json['uploadedBy'],
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        access: json['access'] != null
            ? (json['access'] as List)
                .map((e) => FastPermission.values.firstWhere((p) => p.toString().split('.').last == e))
                .toList()
            : null,
        meta: json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
      );

  /// Converts this [FastFileMeta] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.toString().split('.').last,
        'size': size,
        'mimeType': mimeType,
        'url': url,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt.toIso8601String(),
        if (access != null) 'access': access!.map((e) => e.toString().split('.').last).toList(),
        if (meta != null) 'meta': meta,
      };
}
