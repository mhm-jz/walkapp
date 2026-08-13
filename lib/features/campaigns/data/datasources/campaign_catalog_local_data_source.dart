import '../../domain/campaign.dart';

abstract interface class CampaignCatalogLocalDataSource {
  Future<List<Campaign>> getCampaigns();
}
