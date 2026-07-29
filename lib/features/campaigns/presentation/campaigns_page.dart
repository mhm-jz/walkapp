import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign.dart';
import '../domain/campaign_category.dart';
import '../domain/campaign_status.dart';
import 'campaign_details_page.dart';
import 'campaign_formatters.dart';
import 'widgets/campaign_cards.dart';

enum _CampaignsViewState { loading, content, empty, error }

enum _StatusFilter { all, available, endingSoon, upcoming }

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({required this.repository, super.key});

  final CampaignRepository repository;

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  _CampaignsViewState _viewState = _CampaignsViewState.loading;
  _StatusFilter _statusFilter = _StatusFilter.all;
  CampaignCategory? _categoryFilter;
  List<Campaign> _campaigns = const <Campaign>[];

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() => _viewState = _CampaignsViewState.loading);
    try {
      final campaigns = await widget.repository.getCampaigns();
      if (!mounted) return;
      setState(() {
        _campaigns = campaigns;
        _viewState = campaigns.isEmpty
            ? _CampaignsViewState.empty
            : _CampaignsViewState.content;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _viewState = _CampaignsViewState.error);
    }
  }

  void _openDetails(Campaign campaign) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CampaignDetailsPage(campaign: campaign),
      ),
    );
  }

  List<Campaign> get _filteredCampaigns {
    final now = DateTime.now();
    return _campaigns
        .where((campaign) {
          final status = campaign.statusAt(now);
          final matchesStatus = switch (_statusFilter) {
            _StatusFilter.all => true,
            _StatusFilter.available => status == CampaignStatus.available,
            _StatusFilter.endingSoon => status == CampaignStatus.endingSoon,
            _StatusFilter.upcoming => status == CampaignStatus.upcoming,
          };
          final matchesCategory =
              _categoryFilter == null || campaign.category == _categoryFilter;
          return matchesStatus && matchesCategory;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.xl),
                      _buildBody(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Campaigns', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Walk toward meaningful goals and unlock brand rewards.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppStatusChip(
          label: 'Local prototype content',
          status: AppStatus.neutral,
          icon: Icons.science_outlined,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return switch (_viewState) {
      _CampaignsViewState.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: AppLoadingIndicator(label: 'Loading campaigns')),
      ),
      _CampaignsViewState.error => AppErrorView(
        message: 'Campaigns could not be loaded. Please try again.',
        onRetry: _loadCampaigns,
      ),
      _CampaignsViewState.empty => const AppCard(
        child: AppEmptyState(
          title: 'No campaigns available yet',
          message: 'New walking campaigns will appear here.',
          icon: Icons.campaign_outlined,
        ),
      ),
      _CampaignsViewState.content => _CampaignContent(
        campaigns: _filteredCampaigns,
        statusFilter: _statusFilter,
        categoryFilter: _categoryFilter,
        onStatusChanged: (value) => setState(() => _statusFilter = value),
        onCategoryChanged: (value) => setState(() => _categoryFilter = value),
        onView: _openDetails,
      ),
    };
  }
}

class _CampaignContent extends StatelessWidget {
  const _CampaignContent({
    required this.campaigns,
    required this.statusFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onView,
  });

  final List<Campaign> campaigns;
  final _StatusFilter statusFilter;
  final CampaignCategory? categoryFilter;
  final ValueChanged<_StatusFilter> onStatusChanged;
  final ValueChanged<CampaignCategory?> onCategoryChanged;
  final ValueChanged<Campaign> onView;

  @override
  Widget build(BuildContext context) {
    Campaign? featured;
    for (final campaign in campaigns) {
      if (campaign.isFeatured &&
          campaign.statusAt(DateTime.now()) == CampaignStatus.available) {
        featured = campaign;
        break;
      }
    }
    final listedCampaigns = campaigns
        .where((campaign) => campaign.id != featured?.id)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (featured != null) ...<Widget>[
          Text(
            'Featured campaign',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          FeaturedCampaignCard(
            campaign: featured,
            onView: () => onView(featured!),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        _CampaignFilterBar(
          statusFilter: statusFilter,
          categoryFilter: categoryFilter,
          onStatusChanged: onStatusChanged,
          onCategoryChanged: onCategoryChanged,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (campaigns.isEmpty)
          const AppCard(
            child: AppEmptyState(
              title: 'No matching campaigns',
              message: 'Try another status or category filter.',
              icon: Icons.filter_alt_off_outlined,
            ),
          )
        else ...<Widget>[
          Text(
            'Discover campaigns',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (
            var index = 0;
            index < listedCampaigns.length;
            index++
          ) ...<Widget>[
            CampaignCard(
              campaign: listedCampaigns[index],
              onView: () => onView(listedCampaigns[index]),
            ),
            if (index != listedCampaigns.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _CampaignFilterBar extends StatelessWidget {
  const _CampaignFilterBar({
    required this.statusFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onCategoryChanged,
  });

  final _StatusFilter statusFilter;
  final CampaignCategory? categoryFilter;
  final ValueChanged<_StatusFilter> onStatusChanged;
  final ValueChanged<CampaignCategory?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Filter campaigns',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final filter in _StatusFilter.values) ...<Widget>[
                  FilterChip(
                    label: Text(_statusFilterLabel(filter)),
                    selected: statusFilter == filter,
                    onSelected: (_) => onStatusChanged(filter),
                  ),
                  if (filter != _StatusFilter.values.last)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<CampaignCategory?>(
            initialValue: categoryFilter,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            isExpanded: true,
            items: <DropdownMenuItem<CampaignCategory?>>[
              const DropdownMenuItem<CampaignCategory?>(
                child: Text('All categories'),
              ),
              for (final category in CampaignCategory.values)
                DropdownMenuItem<CampaignCategory?>(
                  value: category,
                  child: Text(campaignCategoryLabel(category)),
                ),
            ],
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }

  String _statusFilterLabel(_StatusFilter filter) => switch (filter) {
    _StatusFilter.all => 'All',
    _StatusFilter.available => 'Available',
    _StatusFilter.endingSoon => 'Ending soon',
    _StatusFilter.upcoming => 'Upcoming',
  };
}
