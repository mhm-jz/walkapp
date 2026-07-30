import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/design_system/components/app_feedback.dart';
import '../../../../core/design_system/components/app_fields.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';

class DailyGoalSheet extends StatefulWidget {
  const DailyGoalSheet({required this.initialGoal, super.key});

  static const minimumGoal = 1000;
  static const maximumGoal = 100000;
  static const goalIncrement = 1000;
  static const quickGoals = <int>[5000, 10000, 15000, 20000];

  final int initialGoal;

  static Future<int?> show(BuildContext context, {required int currentGoal}) {
    return AppBottomSheet.show<int>(
      context,
      child: DailyGoalSheet(initialGoal: currentGoal),
    );
  }

  @override
  State<DailyGoalSheet> createState() => _DailyGoalSheetState();
}

class _DailyGoalSheetState extends State<DailyGoalSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  int get _parsedGoal =>
      int.tryParse(_controller.text.replaceAll(',', '').trim()) ??
      widget.initialGoal;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoal.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setGoal(int value) {
    final clamped = value.clamp(
      DailyGoalSheet.minimumGoal,
      DailyGoalSheet.maximumGoal,
    );
    setState(() {
      _controller.text = clamped.toString();
      _errorText = null;
    });
  }

  void _save() {
    final parsed = int.tryParse(_controller.text.replaceAll(',', '').trim());
    if (parsed == null ||
        parsed < DailyGoalSheet.minimumGoal ||
        parsed > DailyGoalSheet.maximumGoal) {
      setState(() {
        _errorText = context.l10n.goalRangeError;
      });
      return;
    }
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.dailyStepGoal,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.goalSheetDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppIconButton(
                icon: Icons.remove,
                tooltip: context.l10n.decreaseGoal,
                onPressed: () =>
                    _setGoal(_parsedGoal - DailyGoalSheet.goalIncrement),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  controller: _controller,
                  label: context.l10n.goalInSteps,
                  errorText: _errorText,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.flag_outlined,
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                  onSubmitted: (_) => _save(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconButton(
                icon: Icons.add,
                tooltip: context.l10n.increaseGoal,
                onPressed: () =>
                    _setGoal(_parsedGoal + DailyGoalSheet.goalIncrement),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.quickOptions,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final goal in DailyGoalSheet.quickGoals)
                AppButton(
                  label: '$goal',
                  variant: _parsedGoal == goal
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.outlined,
                  onPressed: () => _setGoal(goal),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack =
                  constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              final cancel = AppButton(
                label: context.l10n.cancel,
                expanded: stack,
                variant: AppButtonVariant.outlined,
                onPressed: () => Navigator.of(context).pop(),
              );
              final save = AppButton(
                label: context.l10n.saveGoal,
                expanded: stack,
                onPressed: _save,
              );
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    cancel,
                    const SizedBox(height: AppSpacing.sm),
                    save,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: cancel),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: save),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
