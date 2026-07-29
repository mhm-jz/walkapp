import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/campaign_enrollment_controller.dart';
import '../domain/campaign.dart';
import '../domain/campaign_enrollment.dart';
import '../domain/campaign_enrollment_status.dart';
import '../domain/campaign_type.dart';
import 'campaign_formatters.dart';
import 'widgets/campaign_shared_widgets.dart';

class ActiveCampaignPage extends StatefulWidget {
  const ActiveCampaignPage({required this.controller, super.key});

  final CampaignEnrollmentController controller;

  @override
  State<ActiveCampaignPage> createState() => _ActiveCampaignPageState();
}

class _ActiveCampaignPageState extends State<ActiveCampaignPage> {
  bool _completionScheduled = false;

  Future<void> _showCompletion(Campaign campaign) async {
    await AppDialog.show<void>(
      context,
      title: 'Campaign completed',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Icon(
              Icons.celebration_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'You unlocked ${campaign.reward.discountLabel}. '
            'Reward claiming will be added in the next MVP phase.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        AppButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
      ],
    );
    await widget.controller.acknowledgeCompletion();
  }

  Future<void> _confirmLeave() async {
    final shouldLeave = await AppDialog.show<bool>(
      context,
      title: 'Leave this campaign?',
      content: const Text(
        'Your campaign progress will no longer remain active.\n\n'
        'Your normal health steps and daily goal history will not be deleted.',
      ),
      actions: <Widget>[
        AppButton(
          label: 'Keep Campaign',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Leave Campaign',
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (shouldLeave != true || !mounted) return;
    final left = await widget.controller.leaveActiveCampaign();
    if (!mounted) return;
    if (left) {
      AppSnackbar.show(context, 'Campaign left. Health tracking continues.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.show(
        context,
        widget.controller.userMessage ??
            'The campaign could not be left. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _startTracking() async {
    await widget.controller.stepController.start();
    if (!mounted) return;
    final error = widget.controller.stepController.uiError;
    AppSnackbar.show(
      context,
      error == null
          ? 'Step tracking started'
          : 'Tracking could not be started. Please try again.',
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Campaign')),
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          widget.controller,
          widget.controller.stepController,
        ]),
        builder: (context, child) {
          final enrollment = widget.controller.recentEnrollment;
          if (widget.controller.viewState ==
              CampaignEnrollmentViewState.loading) {
            return const Center(
              child: AppLoadingIndicator(label: 'Loading campaign'),
            );
          }
          if (enrollment == null) {
            return const Center(
              child: AppEmptyState(
                title: 'No campaign to show',
                message: 'Return to Campaigns to discover a campaign.',
                icon: Icons.campaign_outlined,
              ),
            );
          }
          final campaign = widget.controller.campaignFor(enrollment);
          if (campaign == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppErrorView(
                  message:
                      'This saved campaign is unavailable. Your local record has been preserved.',
                ),
              ),
            );
          }
          if (enrollment.status == CampaignEnrollmentStatus.completed &&
              !enrollment.completionAcknowledged &&
              !_completionScheduled) {
            _completionScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showCompletion(campaign);
            });
          }
          return _CampaignBody(
            campaign: campaign,
            enrollment: enrollment,
            controller: widget.controller,
            onStartTracking: _startTracking,
            onLeave: _confirmLeave,
          );
        },
      ),
    );
  }
}

class _CampaignBody extends StatelessWidget {
  const _CampaignBody({
    required this.campaign,
    required this.enrollment,
    required this.controller,
    required this.onStartTracking,
    required this.onLeave,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;
  final VoidCallback onStartTracking;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(campaign: campaign, enrollment: enrollment),
              const SizedBox(height: AppSpacing.xl),
              _ProgressCard(
                campaign: campaign,
                enrollment: enrollment,
                controller: controller,
              ),
              const SizedBox(height: AppSpacing.lg),
              _TrackingCard(
                isTracking: controller.stepController.snapshot.isTracking,
                onStart: onStartTracking,
              ),
              const SizedBox(height: AppSpacing.lg),
              _RulesCard(campaign: campaign, enrollment: enrollment),
              if (enrollment.status == CampaignEnrollmentStatus.active) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Leave Campaign',
                  icon: Icons.exit_to_app,
                  variant: AppButtonVariant.destructive,
                  expanded: true,
                  onPressed: onLeave,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.campaign, required this.enrollment});

  final Campaign campaign;
  final CampaignEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            CampaignBrandMark(initials: campaign.brand.initials),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                campaign.brand.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(campaign.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: AppStatusChip(
            label: _enrollmentStatusLabel(enrollment.status),
            status: switch (enrollment.status) {
              CampaignEnrollmentStatus.active => AppStatus.info,
              CampaignEnrollmentStatus.completed => AppStatus.success,
              CampaignEnrollmentStatus.expired => AppStatus.neutral,
              CampaignEnrollmentStatus.left => AppStatus.neutral,
            },
            icon: switch (enrollment.status) {
              CampaignEnrollmentStatus.active => Icons.directions_walk,
              CampaignEnrollmentStatus.completed => Icons.verified_outlined,
              CampaignEnrollmentStatus.expired => Icons.event_busy_outlined,
              CampaignEnrollmentStatus.left => Icons.exit_to_app,
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Joined ${campaignDate(enrollment.joinedAt)}  •  '
          'Ends ${campaignDate(campaign.endAt)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          enrollment.status == CampaignEnrollmentStatus.expired
              ? 'Campaign ended'
              : enrollment.status == CampaignEnrollmentStatus.completed
              ? 'Requirement completed'
              : campaignTiming(campaign, DateTime.now()),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.campaign,
    required this.enrollment,
    required this.controller,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(campaign, enrollment);
    final percent = (progress * 100).round();
    final isStepTarget = campaign.type == CampaignType.stepTarget;
    final completedDays = controller.completedGoalDays(enrollment);
    final requiredDays = campaign.requiredGoalDays ?? 0;
    final today = controller.eligibleStepsToday(enrollment);
    final capturedGoal = enrollment.goalAtEnrollment ?? 0;
    return Semantics(
      label: isStepTarget
          ? '$percent percent complete, ${enrollment.totalEligibleSteps} of ${campaign.targetSteps} campaign steps'
          : '$completedDays of $requiredDays goal days complete',
      child: AppCard(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              enrollment.status == CampaignEnrollmentStatus.completed
                  ? 'Campaign completed'
                  : enrollment.status == CampaignEnrollmentStatus.expired
                  ? 'Final campaign progress'
                  : 'Campaign progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(value: progress, minHeight: 12),
            const SizedBox(height: AppSpacing.md),
            if (isStepTarget) ...<Widget>[
              Text(
                '${formatCampaignNumber(enrollment.totalEligibleSteps)} / '
                '${formatCampaignNumber(campaign.targetSteps ?? 0)} campaign steps',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${formatCampaignNumber(((campaign.targetSteps ?? 0) - enrollment.totalEligibleSteps).clamp(0, 1 << 31))} steps remaining  •  $percent%',
              ),
            ] else ...<Widget>[
              Text(
                '$completedDays / $requiredDays goal days completed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${formatCampaignNumber(today)} / '
                '${formatCampaignNumber(capturedGoal)} eligible steps today',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(requiredDays - completedDays).clamp(0, requiredDays)} required days remaining',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Captured daily goal: ${formatCampaignNumber(capturedGoal)} steps',
              ),
            ],
            if (enrollment.status ==
                CampaignEnrollmentStatus.completed) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'You unlocked ${campaign.reward.discountLabel}. '
                'Reward claiming will be added in the next MVP phase.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.isTracking, required this.onStart});

  final bool isTracking;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isTracking ? Icons.sensors : Icons.sensors_off_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  isTracking ? 'Tracking is active' : 'Tracking is stopped',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isTracking
                      ? 'Eligible confirmed steps will update this campaign automatically.'
                      : 'Campaign progress changes only while eligible confirmed steps are recorded.',
                ),
                if (!isTracking) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Start Tracking',
                      icon: Icons.play_arrow,
                      onPressed: onStart,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.campaign, required this.enrollment});

  final Campaign campaign;
  final CampaignEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final rules = <String>[
      'Only confirmed steps recorded after enrollment count.',
      'Health progress and the daily goal continue independently.',
      if (campaign.type == CampaignType.dailyGoalConsistency)
        'This campaign keeps the captured ${formatCampaignNumber(enrollment.goalAtEnrollment ?? 0)}-step goal even if Settings changes.',
      'Deadline: ${campaignDate(campaign.endAt)}.',
      'Reward preview: ${campaign.reward.discountLabel}.',
      'This is offline local prototype state. Device-local time is used.',
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Campaign rules',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < rules.length; index++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(rules[index])),
              ],
            ),
            if (index != rules.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

String _enrollmentStatusLabel(CampaignEnrollmentStatus status) =>
    switch (status) {
      CampaignEnrollmentStatus.active => 'Active',
      CampaignEnrollmentStatus.completed => 'Completed',
      CampaignEnrollmentStatus.expired => 'Campaign ended',
      CampaignEnrollmentStatus.left => 'Left',
    };
