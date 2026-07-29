import 'package:hive_ce/hive_ce.dart';

import '../domain/campaign_enrollment.dart';
import 'campaign_enrollment_repository.dart';

final class HiveCampaignEnrollmentRepository
    implements CampaignEnrollmentRepository {
  HiveCampaignEnrollmentRepository._(this._box);

  static const boxName = 'campaign_enrollment_box';
  static const _enrollmentsKey = 'enrollments';

  final Box<dynamic> _box;

  static Future<HiveCampaignEnrollmentRepository> open() async {
    return HiveCampaignEnrollmentRepository._(
      await Hive.openBox<dynamic>(boxName),
    );
  }

  @override
  Future<List<CampaignEnrollment>> loadEnrollments() async {
    final raw = _box.get(_enrollmentsKey);
    if (raw is! List) return const <CampaignEnrollment>[];
    return raw
        .whereType<Map>()
        .map(CampaignEnrollment.fromMap)
        .whereType<CampaignEnrollment>()
        .toList(growable: false);
  }

  @override
  Future<void> saveEnrollment(CampaignEnrollment enrollment) async {
    final enrollments = (await loadEnrollments()).toList();
    final index = enrollments.indexWhere((item) => item.id == enrollment.id);
    if (index < 0) {
      enrollments.add(enrollment);
    } else {
      enrollments[index] = enrollment;
    }
    await _box.put(
      _enrollmentsKey,
      enrollments.map((item) => item.toMap()).toList(growable: false),
    );
    await _box.flush();
  }
}
