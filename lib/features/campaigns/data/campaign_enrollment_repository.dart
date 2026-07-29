import '../domain/campaign_enrollment.dart';

abstract interface class CampaignEnrollmentRepository {
  Future<List<CampaignEnrollment>> loadEnrollments();

  Future<void> saveEnrollment(CampaignEnrollment enrollment);
}

final class InMemoryCampaignEnrollmentRepository
    implements CampaignEnrollmentRepository {
  final List<CampaignEnrollment> _enrollments = <CampaignEnrollment>[];

  @override
  Future<List<CampaignEnrollment>> loadEnrollments() async =>
      List<CampaignEnrollment>.unmodifiable(_enrollments);

  @override
  Future<void> saveEnrollment(CampaignEnrollment enrollment) async {
    final index = _enrollments.indexWhere((item) => item.id == enrollment.id);
    if (index < 0) {
      _enrollments.add(enrollment);
    } else {
      _enrollments[index] = enrollment;
    }
  }
}
