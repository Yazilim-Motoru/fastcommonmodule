import '../enums/fast_notification_type.dart';

/// Model representing a notification/message in the system.
class FastNotification {
  /// Unique notification id.
  final String id;

  /// Notification type (info, warning, error, email, sms, etc).
  final FastNotificationType type;

  /// Notification title/subject.
  final String title;

  /// Notification message/body.
  final String message;

  /// Target user id (can be null for broadcast).
  final String? targetUserId;

  /// Whether the notification is read.
  final bool isRead;

  /// Optional metadata (e.g. action, url, etc).
  final Map<String, dynamic>? meta;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Creates a [FastNotification] instance.
  const FastNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.targetUserId,
    this.isRead = false,
    this.meta,
    required this.createdAt,
  });

  /// Creates a [FastNotification] from JSON.
  factory FastNotification.fromJson(Map<String, dynamic> json) =>
      FastNotification(
        id: json['id'] as String,
        type: FastNotificationType.values
            .firstWhere((e) => e.toString().split('.').last == json['type']),
        title: json['title'] as String,
        message: json['message'] as String,
        targetUserId: json['targetUserId'],
        isRead: json['isRead'] ?? false,
        meta: json['meta'] != null
            ? Map<String, dynamic>.from(json['meta'])
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts this [FastNotification] to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'title': title,
        'message': message,
        'targetUserId': targetUserId,
        'isRead': isRead,
        if (meta != null) 'meta': meta,
        'createdAt': createdAt.toIso8601String(),
      };
}
