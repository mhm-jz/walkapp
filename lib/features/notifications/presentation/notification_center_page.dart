import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/notification_controller.dart';
import '../domain/app_notification.dart';
import '../domain/app_notification_destination.dart';
import '../domain/app_notification_status.dart';
import '../domain/app_notification_type.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({
    required this.controller,
    required this.onOpenNotification,
    super.key,
  });

  final NotificationController controller;
  final Future<void> Function(AppNotification notification) onOpenNotification;

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  Future<void> _clearRead() async {
    final count = widget.controller.readCount;
    if (count == 0) return;
    var confirmed = true;
    if (count > 1) {
      confirmed =
          await AppDialog.show<bool>(
            context,
            title: 'Clear read notifications?',
            content: Text(
              '$count read notifications will be removed from this device. Unread notifications will stay.',
            ),
            actions: <Widget>[
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              AppButton(
                label: 'Clear read',
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ) ==
          true;
    }
    if (confirmed) await widget.controller.deleteReadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) {
            final controller = widget.controller;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: switch (controller.viewState) {
                NotificationViewState.loading => const Center(
                  key: ValueKey('loading'),
                  child: AppLoadingIndicator(label: 'Loading notifications'),
                ),
                NotificationViewState.error => Center(
                  key: const ValueKey('error'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppErrorView(
                      message:
                          controller.userMessage ??
                          'Notifications could not be loaded.',
                      onRetry: controller.refresh,
                    ),
                  ),
                ),
                NotificationViewState.empty => const Center(
                  key: ValueKey('empty'),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: AppEmptyState(
                      title: 'No notifications yet',
                      message:
                          'Updates about goals, campaigns, and rewards will appear here.',
                      icon: Icons.notifications_none,
                    ),
                  ),
                ),
                NotificationViewState.content => _content(context),
              },
            );
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final unread = widget.controller.notifications
        .where((item) => item.status == AppNotificationStatus.unread)
        .toList(growable: false);
    final earlier = widget.controller.notifications
        .where((item) => item.status == AppNotificationStatus.read)
        .toList(growable: false);
    return ListView(
      key: const ValueKey('content'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        Text(
          'Updates about your health goals, campaigns, and rewards.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        if (unread.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Mark all as read',
              variant: AppButtonVariant.text,
              onPressed: widget.controller.markAllAsRead,
            ),
          ),
          _section(context, 'Unread', unread),
        ],
        if (earlier.isNotEmpty) _section(context, 'Earlier', earlier),
        if (widget.controller.readCount > 0) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Clear read notifications',
            variant: AppButtonVariant.outlined,
            icon: Icons.delete_sweep_outlined,
            onPressed: _clearRead,
          ),
        ],
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<AppNotification> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _NotificationCard(
              notification: item,
              onTap: () => widget.onOpenNotification(item),
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = notification.status == AppNotificationStatus.unread;
    return Semantics(
      button: true,
      label:
          '${unread ? 'Unread notification. ' : ''}${notification.title}. ${notification.message}',
      child: AppCard(
        padding: EdgeInsets.zero,
        color: unread ? Theme.of(context).colorScheme.secondaryContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(_iconFor(notification.type)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          if (unread)
                            const Padding(
                              padding: EdgeInsets.only(left: AppSpacing.sm),
                              child: Text(
                                'NEW',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(notification.message),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _friendlyCreatedAt(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (notification.destination != AppNotificationDestination.none)
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(AppNotificationType type) => switch (type) {
    AppNotificationType.dailyGoalReminder => Icons.directions_walk_outlined,
    AppNotificationType.dailyGoalCompleted => Icons.flag_outlined,
    AppNotificationType.campaignEndingSoon => Icons.timer_outlined,
    AppNotificationType.campaignCompleted => Icons.emoji_events_outlined,
    AppNotificationType.campaignRewardReady => Icons.redeem_outlined,
    AppNotificationType.campaignPointsEarned => Icons.stars_outlined,
    AppNotificationType.couponExpiringSoon => Icons.confirmation_num_outlined,
    AppNotificationType.generalInformation => Icons.info_outline,
  };

  static String _friendlyCreatedAt(DateTime value) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final date = DateUtils.dateOnly(value);
    final time = TimeOfDay.fromDateTime(value);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    if (date == today) return 'Today, $hour:$minute $period';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${value.day}.${value.month}.${value.year}';
  }
}
