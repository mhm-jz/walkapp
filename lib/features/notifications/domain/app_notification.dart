import 'app_notification_destination.dart';
import 'app_notification_status.dart';
import 'app_notification_type.dart';

final class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.status,
    required this.destination,
    required this.idempotencyKey,
    this.relatedCampaignId,
    this.relatedEnrollmentId,
    this.relatedRewardId,
    this.relatedClaimedRewardId,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final AppNotificationStatus status;
  final AppNotificationDestination destination;
  final String? relatedCampaignId;
  final String? relatedEnrollmentId;
  final String? relatedRewardId;
  final String? relatedClaimedRewardId;
  final String idempotencyKey;

  AppNotification copyWith({AppNotificationStatus? status}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    createdAt: createdAt,
    status: status ?? this.status,
    destination: destination,
    relatedCampaignId: relatedCampaignId,
    relatedEnrollmentId: relatedEnrollmentId,
    relatedRewardId: relatedRewardId,
    relatedClaimedRewardId: relatedClaimedRewardId,
    idempotencyKey: idempotencyKey,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'destination': destination.name,
    'relatedCampaignId': relatedCampaignId,
    'relatedEnrollmentId': relatedEnrollmentId,
    'relatedRewardId': relatedRewardId,
    'relatedClaimedRewardId': relatedClaimedRewardId,
    'idempotencyKey': idempotencyKey,
  };

  static AppNotification? fromMap(Map<dynamic, dynamic> map) {
    final createdAt = DateTime.tryParse(map['createdAt']?.toString() ?? '');
    final type = AppNotificationType.values
        .where((value) => value.name == map['type']?.toString())
        .firstOrNull;
    final destination = AppNotificationDestination.values
        .where((value) => value.name == map['destination']?.toString())
        .firstOrNull;
    final status = AppNotificationStatus.values
        .where((value) => value.name == map['status']?.toString())
        .firstOrNull;
    if (map['id'] == null ||
        map['title'] == null ||
        map['message'] == null ||
        map['idempotencyKey'] == null ||
        createdAt == null ||
        type == null ||
        destination == null ||
        status == null) {
      return null;
    }
    return AppNotification(
      id: map['id'].toString(),
      type: type,
      title: map['title'].toString(),
      message: map['message'].toString(),
      createdAt: createdAt,
      status: status,
      destination: destination,
      relatedCampaignId: map['relatedCampaignId']?.toString(),
      relatedEnrollmentId: map['relatedEnrollmentId']?.toString(),
      relatedRewardId: map['relatedRewardId']?.toString(),
      relatedClaimedRewardId: map['relatedClaimedRewardId']?.toString(),
      idempotencyKey: map['idempotencyKey'].toString(),
    );
  }
}
