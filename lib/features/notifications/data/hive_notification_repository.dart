import 'package:hive_ce/hive_ce.dart';

import '../domain/app_notification.dart';
import '../domain/app_notification_status.dart';
import 'notification_repository.dart';

final class HiveNotificationRepository implements NotificationRepository {
  HiveNotificationRepository._(this._box);

  static const boxName = 'app_notifications_box';
  static const _maximumItems = 100;
  final Box<dynamic> _box;

  static Future<HiveNotificationRepository> open() async =>
      HiveNotificationRepository._(await Hive.openBox<dynamic>(boxName));

  @override
  Future<List<AppNotification>> getRecentNotifications() async {
    final items =
        _box.values
            .whereType<Map>()
            .map(AppNotification.fromMap)
            .whereType<AppNotification>()
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<AppNotification>.unmodifiable(items);
  }

  @override
  Future<bool> createIfAbsent(AppNotification notification) async {
    if (_box.values.whereType<Map>().any(
      (value) =>
          value['idempotencyKey']?.toString() == notification.idempotencyKey,
    )) {
      return false;
    }
    await _box.put(notification.id, notification.toMap());
    await _prune();
    return true;
  }

  @override
  Future<void> markAsRead(String id) async {
    final raw = _box.get(id);
    if (raw is! Map) return;
    final notification = AppNotification.fromMap(raw);
    if (notification == null ||
        notification.status == AppNotificationStatus.read) {
      return;
    }
    await _box.put(
      id,
      notification.copyWith(status: AppNotificationStatus.read).toMap(),
    );
  }

  @override
  Future<void> markAllAsRead() async {
    final updates = <dynamic, dynamic>{};
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      final item = AppNotification.fromMap(raw);
      if (item != null && item.status == AppNotificationStatus.unread) {
        updates[key] = item
            .copyWith(status: AppNotificationStatus.read)
            .toMap();
      }
    }
    if (updates.isNotEmpty) await _box.putAll(updates);
  }

  @override
  Future<int> getUnreadCount() async => (await getRecentNotifications())
      .where((item) => item.status == AppNotificationStatus.unread)
      .length;

  @override
  Future<int> deleteReadNotifications() async {
    final keys = <dynamic>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map &&
          AppNotification.fromMap(raw)?.status == AppNotificationStatus.read) {
        keys.add(key);
      }
    }
    await _box.deleteAll(keys);
    return keys.length;
  }

  Future<void> _prune() async {
    final items = await getRecentNotifications();
    if (items.length <= _maximumItems) return;
    final oldestFirst = items.reversed.toList();
    final remove = <String>[];
    var excess = items.length - _maximumItems;
    for (final item in oldestFirst) {
      if (excess == 0) break;
      if (item.status == AppNotificationStatus.read) {
        remove.add(item.id);
        excess--;
      }
    }
    for (final item in oldestFirst) {
      if (excess == 0) break;
      if (!remove.contains(item.id)) {
        remove.add(item.id);
        excess--;
      }
    }
    await _box.deleteAll(remove);
  }
}
