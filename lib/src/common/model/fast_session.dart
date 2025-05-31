/// Model representing a user session/activity.
class FastSession {
  /// Unique session id.
  final String id;

  /// User id for this session.
  final String userId;

  /// Session creation/login time.
  final DateTime createdAt;

  /// Last activity or access time.
  final DateTime lastActiveAt;

  /// Optional device or client info.
  final String? deviceInfo;

  /// Optional IP address.
  final String? ip;

  /// Whether the session is currently active.
  final bool isActive;

  /// Optional extra metadata.
  final Map<String, dynamic>? meta;

  /// Creates a [FastSession] instance.
  const FastSession({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastActiveAt,
    this.deviceInfo,
    this.ip,
    this.isActive = true,
    this.meta,
  });

  /// Creates a [FastSession] from JSON.
  factory FastSession.fromJson(Map<String, dynamic> json) => FastSession(
        id: json['id'] as String,
        userId: json['userId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
        deviceInfo: json['deviceInfo'],
        ip: json['ip'],
        isActive: json['isActive'] ?? true,
        meta: json['meta'] != null
            ? Map<String, dynamic>.from(json['meta'])
            : null,
      );

  /// Converts this [FastSession] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (ip != null) 'ip': ip,
        'isActive': isActive,
        if (meta != null) 'meta': meta,
      };
}
