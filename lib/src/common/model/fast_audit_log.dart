import 'fast_model.dart';

/// FastAuditLog represents an audit log entry for user/system actions.
class FastAuditLog extends FastModel {
  /// User ID who performed the action.
  final String userId;

  /// Action performed (e.g. login, update, delete).
  final String action;

  /// Optional target entity ID.
  final String? targetId;

  /// Optional target entity type.
  final String? targetType;

  /// Timestamp of the action.
  final DateTime timestamp;

  /// Optional metadata (e.g. IP, device, etc).
  final Map<String, dynamic>? meta;

  /// Creates a [FastAuditLog] instance.
  const FastAuditLog({
    required String id,
    required this.userId,
    required this.action,
    this.targetId,
    this.targetType,
    required this.timestamp,
    this.meta,
  }) : super(id: id);

  /// Creates a [FastAuditLog] from JSON.
  factory FastAuditLog.fromJson(Map<String, dynamic> json) => FastAuditLog(
        id: json['id'] as String,
        userId: json['userId'] as String,
        action: json['action'] as String,
        targetId: json['targetId'],
        targetType: json['targetType'],
        timestamp: DateTime.parse(json['timestamp'] as String),
        meta: json['meta'] != null
            ? Map<String, dynamic>.from(json['meta'])
            : null,
      );

  /// Converts the audit log to a JSON map.
  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'action': action,
        if (targetId != null) 'targetId': targetId,
        if (targetType != null) 'targetType': targetType,
        'timestamp': timestamp.toIso8601String(),
        if (meta != null) 'meta': meta,
      };
}
