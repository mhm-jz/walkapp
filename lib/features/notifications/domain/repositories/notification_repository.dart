import '../app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> getRecentNotifications();
  Future<bool> createIfAbsent(AppNotification notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
  Future<int> deleteReadNotifications();
}
