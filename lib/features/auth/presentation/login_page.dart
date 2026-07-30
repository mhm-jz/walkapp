import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import 'auth_form_controller.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_form_container.dart';
import 'widgets/auth_prototype_notice.dart';
import 'widgets/auth_theme_action.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.settingsController,
    required this.onAuthenticated,
    required this.onRegister,
    required this.onBack,
    super.key,
  });

  final AppSettingsController settingsController;
  final VoidCallback onAuthenticated;
  final VoidCallback onRegister;
  final VoidCallback onBack;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formController = AuthFormController(AuthFormType.login);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await _formController.submit(
      l10n: context.l10n,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (success && mounted) widget.onAuthenticated();
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
        title: context.l10n.welcomeBack,
        message: context.l10n.loginWelcomeMessage,
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
                  errorText: _formController.errorFor('password'),
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _formController.obscurePassword,
                    onPressed: _formController.togglePasswordVisibility,
                  ),
                  obscureText: _formController.obscurePassword,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('password'),
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppButton(
                    label: context.l10n.forgotPassword,
                    variant: AppButtonVariant.text,
                    onPressed: _formController.isLoading
                        ? null
                        : () => AppSnackbar.show(
                            context,
                            context.l10n.passwordRecoveryUnavailable,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: context.l10n.login,
                  icon: Icons.arrow_forward_rounded,
                  expanded: true,
                  isLoading: _formController.isLoading,
                  onPressed: _formController.isLoading ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(child: Text(context.l10n.newToWalkApp)),
                    AppButton(
                      label: context.l10n.register,
                      variant: AppButtonVariant.text,
                      onPressed: _formController.isLoading
                          ? null
                          : widget.onRegister,
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
