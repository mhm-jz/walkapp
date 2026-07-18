import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/components/app_selection.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import 'auth_form_controller.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_form_container.dart';
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
        tooltip: 'Back',
        onPressed: _formController.isLoading ? null : widget.onBack,
      ),
      themeAction: AuthThemeAction(
        settingsController: widget.settingsController,
      ),
      header: const AuthBrandHeader(
        title: 'Welcome back',
        message: 'Continue your journey and reach today’s goal.',
      ),
      form: AuthFormContainer(
        child: AnimatedBuilder(
          animation: _formController,
          builder: (context, child) => AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  controller: _emailController,
                  label: 'Email address',
                  hint: 'you@example.com',
                  errorText: _formController.errorFor('email'),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('email'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  errorText: _formController.errorFor('password'),
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: PasswordVisibilityButton(
                    obscured: _formController.obscurePassword,
                    onPressed: _formController.togglePasswordVisibility,
                  ),
                  obscureText: _formController.obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  enabled: !_formController.isLoading,
                  onChanged: (_) => _formController.clearError('password'),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 190),
                      child: AppCheckbox(
                        value: _formController.rememberMe,
                        onChanged: _formController.isLoading
                            ? null
                            : (value) =>
                                  _formController.setRememberMe(value ?? false),
                        label: 'Remember me',
                      ),
                    ),
                    AppButton(
                      label: 'Forgot password?',
                      variant: AppButtonVariant.text,
                      onPressed: _formController.isLoading
                          ? null
                          : () => AppSnackbar.show(
                              context,
                              'Password recovery will be available when authentication is connected.',
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Log in',
                  icon: Icons.arrow_forward_rounded,
                  expanded: true,
                  isLoading: _formController.isLoading,
                  onPressed: _formController.isLoading ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Flexible(child: Text('New to WalkApp?')),
                    AppButton(
                      label: 'Create account',
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
