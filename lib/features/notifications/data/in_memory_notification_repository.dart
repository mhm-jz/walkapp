import '../domain/app_notification.dart';
import '../domain/app_notification_status.dart';
import '../domain/repositories/notification_repository.dart';

final class InMemoryNotificationRepository implements NotificationRepository {
  final List<AppNotification> _items = <AppNotification>[];

  @override
  Future<bool> createIfAbsent(AppNotification notification) async {
    if (_items.any(
      (item) => item.idempotencyKey == notification.idempotencyKey,
    )) {
      return false;
    }
    _items.add(notification);
    return true;
  }

  @override
  Future<int> deleteReadNotifications() async {
    final before = _items.length;
    _items.removeWhere((item) => item.status == AppNotificationStatus.read);
    return before - _items.length;
  }

  @override
  Future<List<AppNotification>> getRecentNotifications() async =>
      List<AppNotification>.unmodifiable(_items.reversed);

  @override
  Future<int> getUnreadCount() async => _items
      .where((item) => item.status == AppNotificationStatus.unread)
      .length;

  @override
  Future<void> markAllAsRead() async {
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(
        status: AppNotificationStatus.read,
      );
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        status: AppNotificationStatus.read,
      );
    }
  }
}
