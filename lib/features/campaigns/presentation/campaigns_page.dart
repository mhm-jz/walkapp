import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../application/campaign_enrollment_controller.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign.dart';
import '../domain/campaign_category.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_enrollment.dart';
import '../domain/campaign_type.dart';
import '../../rewards/application/rewards_controller.dart';
import 'active_campaign_page.dart';
import 'campaign_details_page.dart';
import 'campaign_formatters.dart';
import 'widgets/campaign_cards.dart';

enum _CampaignsViewState { loading, content, empty, error }

enum _StatusFilter { all, available, endingSoon, upcoming }

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({
    required this.repository,
    required this.enrollmentController,
    required this.settingsController,
    required this.rewardsController,
    super.key,
  });

  final CampaignRepository repository;
  final CampaignEnrollmentController enrollmentController;
  final AppSettingsController settingsController;
  final RewardsController rewardsController;

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
      final interests = widget.settingsController.rewardInterests;
      final ordered = campaigns.indexed.toList()
        ..sort((a, b) {
          if (interests.isEmpty || interests.contains('بدون ترجیح')) {
            return a.$1.compareTo(b.$1);
          }
          final aMatches = interests.contains(
            campaignCategoryLabel(context.l10n, a.$2.category),
          );
          final bMatches = interests.contains(
            campaignCategoryLabel(context.l10n, b.$2.category),
          );
          if (aMatches == bMatches) return a.$1.compareTo(b.$1);
          return aMatches ? -1 : 1;
        });
      if (!mounted) return;
      setState(() {
        _campaigns = ordered.map((item) => item.$2).toList(growable: false);
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
        builder: (context) => CampaignDetailsPage(
          campaign: campaign,
          enrollmentController: widget.enrollmentController,
          settingsController: widget.settingsController,
          rewardsController: widget.rewardsController,
        ),
      ),
    );
  }

  void _openActiveCampaign() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ActiveCampaignPage(
          controller: widget.enrollmentController,
          rewardsController: widget.rewardsController,
        ),
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
            padding: const EdgeInsetsDirectional.fromSTEB(
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
        Text(
          context.l10n.campaigns,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.campaignsDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppStatusChip(
          label: context.l10n.localPrototypeContent,
          status: AppStatus.neutral,
          icon: Icons.science_outlined,
        ),
      ],
    );
  }

  Widget _buildBody() {
    final content = switch (_viewState) {
      _CampaignsViewState.loading => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(
          child: AppLoadingIndicator(label: context.l10n.loadingCampaigns),
        ),
      ),
      _CampaignsViewState.error => AppErrorView(
        message: context.l10n.campaignsLoadError,
        onRetry: _loadCampaigns,
      ),
      _CampaignsViewState.empty => AppCard(
        child: AppEmptyState(
          title: context.l10n.noCampaignsAvailable,
          message: context.l10n.noCampaignsDescription,
          icon: Icons.campaign_outlined,
        ),
      ),
      _CampaignsViewState.content => _CampaignContent(
        campaigns: _filteredCampaigns,
        enrollmentController: widget.enrollmentController,
        statusFilter: _statusFilter,
        categoryFilter: _categoryFilter,
        onStatusChanged: (value) => setState(() => _statusFilter = value),
        onCategoryChanged: (value) => setState(() => _categoryFilter = value),
        onView: _openDetails,
      ),
    };
    return AnimatedBuilder(
      animation: widget.enrollmentController,
      builder: (context, child) {
        final enrollment = widget.enrollmentController.activeEnrollment;
        final campaign = enrollment == null
            ? null
            : widget.enrollmentController.campaignFor(enrollment);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (enrollment != null && campaign != null) ...<Widget>[
              _ActiveCampaignCard(
                campaign: campaign,
                enrollment: enrollment,
                controller: widget.enrollmentController,
                onContinue: _openActiveCampaign,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (widget.enrollmentController.userMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: AppErrorView(
                  message:
                      widget.enrollmentController.userMessage ??
                      context.l10n.campaignEnrollmentLoadError,
                  onRetry:
                      widget.enrollmentController.viewState ==
                          CampaignEnrollmentViewState.error
                      ? widget.enrollmentController.initialize
                      : null,
                  compact: true,
                ),
              ),
            content,
          ],
        );
      },
    );
  }
}

class _CampaignContent extends StatelessWidget {
  const _CampaignContent({
    required this.campaigns,
    required this.enrollmentController,
    required this.statusFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onView,
  });

  final List<Campaign> campaigns;
  final CampaignEnrollmentController enrollmentController;
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
            context.l10n.featuredCampaign,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          FeaturedCampaignCard(
            campaign: featured,
            enrollmentStatus: enrollmentController
                .enrollmentFor(featured.id)
                ?.status,
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
          AppCard(
            child: AppEmptyState(
              title: context.l10n.noMatchingCampaigns,
              message: context.l10n.tryAnotherCampaignFilter,
              icon: Icons.filter_alt_off_outlined,
            ),
          )
        else ...<Widget>[
          Text(
            context.l10n.discoverCampaigns,
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
              enrollmentStatus: enrollmentController
                  .enrollmentFor(listedCampaigns[index].id)
                  ?.status,
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

class _ActiveCampaignCard extends StatelessWidget {
  const _ActiveCampaignCard({
    required this.campaign,
    required this.enrollment,
    required this.controller,
    required this.onContinue,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final stepTarget = campaign.type == CampaignType.stepTarget;
    final progress = controller.progressFor(campaign, enrollment);
    final progressText = stepTarget
        ? context.l10n.campaignStepProgress(
            formatCampaignNumber(enrollment.totalEligibleSteps),
            formatCampaignNumber(campaign.targetSteps ?? 0),
          )
        : context.l10n.goalDaysCompleted(
            controller.completedGoalDays(enrollment),
            campaign.requiredGoalDays ?? 0,
          );
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.directions_walk),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'چالش فعال',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              AppStatusChip(
                label: context.l10n.active,
                status: AppStatus.info,
                icon: Icons.sensors,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(campaign.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: progressText,
            child: LinearProgressIndicator(value: progress, minHeight: 10),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(progressText),
          const SizedBox(height: AppSpacing.xs),
          Text(campaignTiming(context.l10n, campaign, DateTime.now())),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: context.l10n.continueCampaign,
              icon: Icons.arrow_forward,
              onPressed: onContinue,
            ),
          ),
        ],
      ),
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
            context.l10n.filterCampaigns,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final filter in _StatusFilter.values) ...<Widget>[
                  FilterChip(
                    label: Text(_statusFilterLabel(context, filter)),
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
              labelText: 'دسته‌بندی',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            isExpanded: true,
            items: <DropdownMenuItem<CampaignCategory?>>[
              DropdownMenuItem<CampaignCategory?>(
                child: Text(context.l10n.allCategories),
              ),
              for (final category in CampaignCategory.values)
                DropdownMenuItem<CampaignCategory?>(
                  value: category,
                  child: Text(campaignCategoryLabel(context.l10n, category)),
                ),
            ],
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }

  String _statusFilterLabel(BuildContext context, _StatusFilter filter) =>
      switch (filter) {
        _StatusFilter.all => context.l10n.allFilter,
        _StatusFilter.available => context.l10n.campaignAvailableStatus,
        _StatusFilter.endingSoon => context.l10n.endingSoon,
        _StatusFilter.upcoming => context.l10n.campaignUpcomingStatus,
      };
}
