import '../../domain/campaign_enrollment.dart';

abstract interface class CampaignEnrollmentLocalDataSource {
  Future<List<CampaignEnrollment>> loadEnrollments();
  Future<void> saveEnrollment(CampaignEnrollment enrollment);
}
