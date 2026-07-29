import 'campaign_enrollment_status.dart';

final class CampaignEnrollment {
  const CampaignEnrollment({
    required this.id,
    required this.campaignId,
    required this.joinedAt,
    required this.status,
    required this.goalAtEnrollment,
    required this.eligibleStepsByDate,
    required this.totalEligibleSteps,
    required this.lastObservedConfirmedSteps,
    required this.lastObservedDate,
    this.completedAt,
    this.leftAt,
    this.completionAcknowledged = false,
  });

  final String id;
  final String campaignId;
  final DateTime joinedAt;
  final CampaignEnrollmentStatus status;
  final int? goalAtEnrollment;
  final Map<String, int> eligibleStepsByDate;
  final int totalEligibleSteps;
  final DateTime? completedAt;
  final DateTime? leftAt;
  final int lastObservedConfirmedSteps;
  final String lastObservedDate;
  final bool completionAcknowledged;

  CampaignEnrollment copyWith({
    CampaignEnrollmentStatus? status,
    Map<String, int>? eligibleStepsByDate,
    int? totalEligibleSteps,
    DateTime? completedAt,
    DateTime? leftAt,
    int? lastObservedConfirmedSteps,
    String? lastObservedDate,
    bool? completionAcknowledged,
  }) {
    return CampaignEnrollment(
      id: id,
      campaignId: campaignId,
      joinedAt: joinedAt,
      status: status ?? this.status,
      goalAtEnrollment: goalAtEnrollment,
      eligibleStepsByDate:
          eligibleStepsByDate ?? Map<String, int>.of(this.eligibleStepsByDate),
      totalEligibleSteps: totalEligibleSteps ?? this.totalEligibleSteps,
      completedAt: completedAt ?? this.completedAt,
      leftAt: leftAt ?? this.leftAt,
      lastObservedConfirmedSteps:
          lastObservedConfirmedSteps ?? this.lastObservedConfirmedSteps,
      lastObservedDate: lastObservedDate ?? this.lastObservedDate,
      completionAcknowledged:
          completionAcknowledged ?? this.completionAcknowledged,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'campaignId': campaignId,
    'joinedAt': joinedAt.toIso8601String(),
    'status': status.name,
    'goalAtEnrollment': goalAtEnrollment,
    'eligibleStepsByDate': eligibleStepsByDate,
    'totalEligibleSteps': totalEligibleSteps,
    'completedAt': completedAt?.toIso8601String(),
    'leftAt': leftAt?.toIso8601String(),
    'lastObservedConfirmedSteps': lastObservedConfirmedSteps,
    'lastObservedDate': lastObservedDate,
    'completionAcknowledged': completionAcknowledged,
  };

  static CampaignEnrollment? fromMap(Map<dynamic, dynamic> map) {
    final id = map['id']?.toString();
    final campaignId = map['campaignId']?.toString();
    final joinedAt = DateTime.tryParse(map['joinedAt']?.toString() ?? '');
    final lastObservedDate = map['lastObservedDate']?.toString();
    final status = CampaignEnrollmentStatus.values
        .where((value) => value.name == map['status']?.toString())
        .firstOrNull;
    if (id == null ||
        campaignId == null ||
        joinedAt == null ||
        lastObservedDate == null ||
        status == null) {
      return null;
    }
    final rawByDate = map['eligibleStepsByDate'];
    final byDate = <String, int>{};
    if (rawByDate is Map) {
      for (final entry in rawByDate.entries) {
        final value = _asInt(entry.value);
        if (value >= 0) byDate[entry.key.toString()] = value;
      }
    }
    return CampaignEnrollment(
      id: id,
      campaignId: campaignId,
      joinedAt: joinedAt,
      status: status,
      goalAtEnrollment: map['goalAtEnrollment'] == null
          ? null
          : _asInt(map['goalAtEnrollment']),
      eligibleStepsByDate: byDate,
      totalEligibleSteps: _asInt(map['totalEligibleSteps']),
      completedAt: DateTime.tryParse(map['completedAt']?.toString() ?? ''),
      leftAt: DateTime.tryParse(map['leftAt']?.toString() ?? ''),
      lastObservedConfirmedSteps: _asInt(map['lastObservedConfirmedSteps']),
      lastObservedDate: lastObservedDate,
      completionAcknowledged: map['completionAcknowledged'] == true,
    );
  }

  static int _asInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
