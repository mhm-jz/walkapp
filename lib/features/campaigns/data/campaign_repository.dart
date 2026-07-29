import '../domain/campaign.dart';

abstract interface class CampaignRepository {
  Future<List<Campaign>> getCampaigns();
}
