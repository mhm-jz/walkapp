import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../core/preferences/personalization_options.dart';
import '../../step_counter/presentation/widgets/daily_goal_sheet.dart';
import 'account_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.settingsController, super.key});

  final AppSettingsController settingsController;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late bool _isEditing;
  bool _isSaving = false;
  String? _nameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.settingsController.profileName,
    );
    _emailController = TextEditingController(
      text: widget.settingsController.profileEmail,
    );
    _isEditing =
        widget.settingsController.profileName.isEmpty ||
        widget.settingsController.profileEmail.isEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _cancelEditing() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _nameController.text = widget.settingsController.profileName;
      _emailController.text = widget.settingsController.profileEmail;
      _nameError = null;
      _emailError = null;
      _isEditing = false;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final nameError = name.isEmpty ? 'Enter your full name' : null;
    final emailError = email.isEmpty
        ? 'Enter your email address'
        : !_looksLikeEmail(email)
        ? 'Enter a valid email address'
        : null;
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
    });
    if (nameError != null || emailError != null) return;

    setState(() => _isSaving = true);
    try {
      await widget.settingsController.setProfile(fullName: name, email: email);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppSnackbar.show(
        context,
        'Profile could not be saved. Please try again.',
        isError: true,
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
    AppSnackbar.show(context, 'Profile saved');
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  Future<void> _editGoal() async {
    final goal = await DailyGoalSheet.show(
      context,
      currentGoal: widget.settingsController.dailyGoal,
    );
    if (goal == null || !mounted) return;
    await widget.settingsController.setDailyGoal(goal);
    if (mounted) AppSnackbar.show(context, 'Daily goal updated');
  }

  Future<void> _setCity(String? city) async {
    if (city == null) return;
    await widget.settingsController.setPersonalization(
      rewardInterests: widget.settingsController.rewardInterests,
      selectedCity: city,
    );
    if (mounted) AppSnackbar.show(context, 'City updated');
  }

  Future<void> _toggleInterest(String value) async {
    final selected = widget.settingsController.rewardInterests.toSet();
    if (value == PersonalizationOptions.noPreference) {
      selected
        ..clear()
        ..add(value);
    } else {
      selected.remove(PersonalizationOptions.noPreference);
      selected.contains(value) ? selected.remove(value) : selected.add(value);
      if (selected.isEmpty) selected.add(PersonalizationOptions.noPreference);
    }
    await widget.settingsController.setPersonalization(
      rewardInterests: selected.toList(growable: false),
      selectedCity: widget.settingsController.selectedCity,
    );
    if (mounted) AppSnackbar.show(context, 'Reward interests updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: widget.settingsController,
                      builder: (context, child) => AccountAvatar(
                        fullName: _isEditing
                            ? _nameController.text
                            : widget.settingsController.profileName,
                        radius: 42,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _isEditing
                          ? 'Your account details'
                          : widget.settingsController.profileName.isEmpty
                          ? 'Complete your profile'
                          : widget.settingsController.profileName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Stored privately with your local app preferences.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      child: AnimatedSwitcher(
                        duration: AppDurations.fast,
                        child: _isEditing
                            ? AutofillGroup(
                                key: const ValueKey<String>('edit'),
                                child: Column(
                                  children: <Widget>[
                                    AppTextField(
                                      controller: _nameController,
                                      label: 'Full name',
                                      errorText: _nameError,
                                      keyboardType: TextInputType.name,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.name,
                                      ],
                                      enabled: !_isSaving,
                                      prefixIcon: Icons.person_outline,
                                      onChanged: (_) {
                                        if (_nameError != null) {
                                          setState(() => _nameError = null);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    AppTextField(
                                      controller: _emailController,
                                      label: 'Email address',
                                      errorText: _emailError,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                      ],
                                      enabled: !_isSaving,
                                      prefixIcon: Icons.mail_outline,
                                      onChanged: (_) {
                                        if (_emailError != null) {
                                          setState(() => _emailError = null);
                                        }
                                      },
                                      onSubmitted: (_) => _save(),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: AppButton(
                                            label: 'Cancel',
                                            variant: AppButtonVariant.outlined,
                                            onPressed: _isSaving
                                                ? null
                                                : _cancelEditing,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: AppButton(
                                            label: 'Save',
                                            icon: Icons.check,
                                            isLoading: _isSaving,
                                            onPressed: _isSaving ? null : _save,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : _ProfileDetails(
                                key: const ValueKey<String>('details'),
                                fullName: widget.settingsController.profileName,
                                email: widget.settingsController.profileEmail,
                                onEdit: () => setState(() => _isEditing = true),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedBuilder(
                      animation: widget.settingsController,
                      builder: (context, child) => AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Personalization',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppDropdownField<String>(
                              label: 'City',
                              value: widget.settingsController.selectedCity,
                              items: <DropdownMenuItem<String>>[
                                for (final city
                                    in PersonalizationOptions.cities)
                                  DropdownMenuItem<String>(
                                    value: city,
                                    child: Text(city),
                                  ),
                              ],
                              onChanged: _setCity,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Reward interests',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: <Widget>[
                                for (final interest in <String>[
                                  ...PersonalizationOptions.rewardInterests,
                                  PersonalizationOptions.noPreference,
                                ])
                                  FilterChip(
                                    label: Text(interest),
                                    selected: widget
                                        .settingsController
                                        .rewardInterests
                                        .contains(interest),
                                    onSelected: (_) =>
                                        _toggleInterest(interest),
                                  ),
                              ],
                            ),
                            const Divider(height: AppSpacing.xl),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Daily goal: '
                                    '${widget.settingsController.dailyGoal} steps',
                                  ),
                                ),
                                AppIconButton(
                                  icon: Icons.edit_outlined,
                                  tooltip: 'Edit daily goal',
                                  onPressed: _editGoal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({
    required this.fullName,
    required this.email,
    required this.onEdit,
    super.key,
  });

  final String fullName;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _DetailRow(
          icon: Icons.person_outline,
          label: 'Full name',
          value: fullName.isEmpty ? 'Not added' : fullName,
        ),
        const Divider(height: AppSpacing.xl),
        _DetailRow(
          icon: Icons.mail_outline,
          label: 'Email address',
          value: email.isEmpty ? 'Not added' : email,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Edit profile',
          icon: Icons.edit_outlined,
          expanded: true,
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}
