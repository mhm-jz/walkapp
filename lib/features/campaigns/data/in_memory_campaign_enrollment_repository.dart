import '../domain/campaign_enrollment.dart';
import '../domain/repositories/campaign_enrollment_repository.dart';

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
