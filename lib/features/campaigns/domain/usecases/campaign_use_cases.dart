import '../campaign.dart';
import '../campaign_enrollment.dart';
import '../repositories/campaign_enrollment_repository.dart';
import '../repositories/campaign_repository.dart';

final class CampaignUseCases {
  const CampaignUseCases(this._campaigns, this._enrollments);
  final CampaignRepository _campaigns;
  final CampaignEnrollmentRepository _enrollments;
  Future<List<Campaign>> getCampaigns() => _campaigns.getCampaigns();
  Future<List<CampaignEnrollment>> loadEnrollments() =>
      _enrollments.loadEnrollments();
  Future<void> saveEnrollment(CampaignEnrollment value) =>
      _enrollments.saveEnrollment(value);
}
