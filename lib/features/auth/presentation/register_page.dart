import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/components/app_selection.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import 'auth_form_controller.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_form_container.dart';
import 'widgets/auth_prototype_notice.dart';
import 'widgets/auth_theme_action.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    required this.settingsController,
    required this.onAuthenticated,
    required this.onLogin,
    required this.onBack,
    super.key,
  });

  final AppSettingsController settingsController;
  final Future<void> Function() onAuthenticated;
  final VoidCallback onLogin;
  final VoidCallback onBack;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _formController = AuthFormController(AuthFormType.register);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await _formController.submit(
      l10n: context.l10n,
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmation: _confirmationController.text,
    );
    if (success && mounted) await widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageLayout(
      backAction: AppIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: context.l10n.back,
        onPressed: _formController.isLoading ? null : widget.onBack,
      ),
      themeAction: AuthThemeAction(
        settingsController: widget.settingsController,
      ),
      header: AuthBrandHeader(
        title: context.l10n.createYourAccount,
        message: context.l10n.registerWelcomeMessage,
      ),
      form: AuthFormContainer(
        child: AnimatedBuilder(
          animation: _formController,
          builder: (context, child) => AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AuthPrototypeNotice(),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _nameController,
                  label: context.l10n.fullName,
                  hint: context.l10n.yourName,
                  errorText: _formController.errorFor('name'),
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const <String>[AutofillHints.name],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _emailController,
                  label: context.l10n.emailAddress,
                  hint: context.l10n.emailExample,
                  errorText: _formController.errorFor('email'),
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  prefixIcon: Icons.mail_outline,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('email'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: context.l10n.password,
                  hint: context.l10n.minimumEightCharacters,
                  errorText: _formController.errorFor('password'),
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _formController.obscurePassword,
                    onPressed: _formController.togglePasswordVisibility,
                  ),
                  obscureText: _formController.obscurePassword,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  enabled: !_formController.isLoading,
                  onChanged: (_) {
                    _formController
                      ..clearError('password')
                      ..clearError('confirmation');
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _confirmationController,
                  label: context.l10n.confirmPassword,
                  errorText: _formController.errorFor('confirmation'),
                  prefixIcon: Icons.lock_reset_outlined,
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _formController.obscureConfirmation,
                    onPressed: _formController.toggleConfirmationVisibility,
                  ),
                  obscureText: _formController.obscureConfirmation,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('confirmation'),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCheckbox(
                  value: _formController.acceptTerms,
                  onChanged: _formController.isLoading
                      ? null
                      : (value) =>
                            _formController.setAcceptTerms(value ?? false),
                  label: context.l10n.acceptTermsAndPrivacy,
                ),
                AnimatedSize(
                  duration: AppDurations.fast,
                  child: _formController.errorFor('terms') == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.md,
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            _formController.errorFor('terms')!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: context.l10n.register,
                  icon: Icons.arrow_forward_rounded,
                  expanded: true,
                  isLoading: _formController.isLoading,
                  onPressed: _formController.isLoading ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        context.l10n.alreadyHaveAccount,
                        style: TextStyle(color: context.appTheme.textSecondary),
                      ),
                    ),
                    AppButton(
                      label: context.l10n.login,
                      variant: AppButtonVariant.text,
                      onPressed: _formController.isLoading
                          ? null
                          : widget.onLogin,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
