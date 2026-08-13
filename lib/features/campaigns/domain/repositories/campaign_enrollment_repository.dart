import '../campaign_enrollment.dart';

abstract interface class CampaignEnrollmentRepository {
  Future<List<CampaignEnrollment>> loadEnrollments();

  Future<void> saveEnrollment(CampaignEnrollment enrollment);
}
