/// FastAuditLog represents a single audit log entry for user/system actions.
class FastAuditLog {
  /// Unique log entry id.
  final String id;

  /// User id who performed the action (nullable for system actions).
  final String? userId;

  /// Action type (e.g. 'login', 'update_user', 'delete_role', etc.).
  final String action;

  /// Optional target entity id (e.g. user id, role id, etc.).
  final String? targetId;

  /// Optional target entity type (e.g. 'user', 'role', 'permission').
  final String? targetType;

  /// Timestamp of the action (UTC ISO8601 string).
  final DateTime timestamp;

  /// Optional metadata (e.g. IP, device, extra info).
  final Map<String, dynamic>? meta;

  const FastAuditLog({
    required this.id,
    this.userId,
    required this.action,
    this.targetId,
    this.targetType,
    required this.timestamp,
    this.meta,
  });

  factory FastAuditLog.fromJson(Map<String, dynamic> json) => FastAuditLog(
        id: json['id'] as String,
        userId: json['userId'] as String?,
        action: json['action'] as String,
        targetId: json['targetId'] as String?,
        targetType: json['targetType'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        meta: json['meta'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (userId != null) 'userId': userId,
        'action': action,
        if (targetId != null) 'targetId': targetId,
        if (targetType != null) 'targetType': targetType,
        'timestamp': timestamp.toIso8601String(),
        if (meta != null) 'meta': meta,
      };
}
