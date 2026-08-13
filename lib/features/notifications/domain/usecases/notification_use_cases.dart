import '../app_notification.dart';
import '../repositories/notification_repository.dart';

final class NotificationUseCases {
  const NotificationUseCases(this._repository);
  final NotificationRepository _repository;
  Future<List<AppNotification>> getRecentNotifications() =>
      _repository.getRecentNotifications();
  Future<bool> createIfAbsent(AppNotification value) =>
      _repository.createIfAbsent(value);
  Future<void> markAsRead(String id) => _repository.markAsRead(id);
  Future<void> markAllAsRead() => _repository.markAllAsRead();
  Future<int> deleteReadNotifications() =>
      _repository.deleteReadNotifications();
}
