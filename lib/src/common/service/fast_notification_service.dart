import '../enums/fast_notification_type.dart';
import '../model/fast_notification.dart';
import '../model/fast_response.dart';

/// Abstract notification service for system/email/SMS notifications.
abstract class FastNotificationService {
  /// Send a notification (system, email, sms, etc).
  Future<FastResponse<bool>> send(FastNotification notification);

  /// Get notifications for a user (optionally filter by read status/type).
  Future<FastResponse<List<FastNotification>>> getUserNotifications(
    String userId, {
    bool? isRead,
    FastNotificationType? type,
    int pageIndex = 0,
    int pageSize = 20,
  });

  /// Mark a notification as read.
  Future<FastResponse<bool>> markAsRead(String notificationId);

  /// Mark all notifications as read for a user.
  Future<FastResponse<bool>> markAllAsRead(String userId);

  /// Delete a notification.
  Future<FastResponse<bool>> delete(String notificationId);
}
