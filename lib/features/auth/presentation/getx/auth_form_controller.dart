import 'package:get/get.dart';

import '../../../../core/presentation/reactive_controller.dart';
import '../../../../l10n/app_localizations.dart';

enum AuthFormType { login, register }

/// Application state and validation for authentication forms.
final class AuthFormController extends ReactiveController {
  AuthFormController(this.type);

  final AuthFormType type;

  final RxBool _isLoading = false.obs;
  final RxBool _rememberMe = false.obs;
  final RxBool _acceptTerms = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmation = true.obs;
  bool _disposed = false;
  final RxMap<String, String> _errors = <String, String>{}.obs;

  bool get isLoading => _isLoading.value;
  bool get rememberMe => _rememberMe.value;
  bool get acceptTerms => _acceptTerms.value;
  bool get obscurePassword => _obscurePassword.value;
  bool get obscureConfirmation => _obscureConfirmation.value;
  String? errorFor(String field) => _errors[field];

  void setRememberMe(bool value) {
    _rememberMe.value = value;
    refreshState();
  }

  void setAcceptTerms(bool value) {
    _acceptTerms.value = value;
    if (value) _removeError('terms');
    refreshState();
  }

  void togglePasswordVisibility() {
    _obscurePassword.toggle();
    refreshState();
  }

  void toggleConfirmationVisibility() {
    _obscureConfirmation.toggle();
    refreshState();
  }

  void clearError(String field) {
    if (_errors.containsKey(field)) {
      _removeError(field);
      refreshState();
    }
  }

  Future<bool> submit({
    required AppLocalizations l10n,
    required String email,
    required String password,
    String fullName = '',
    String confirmation = '',
  }) async {
    if (_isLoading.value) return false;
    final errors = <String, String>{};
    if (type == AuthFormType.register && fullName.trim().isEmpty) {
      errors['name'] = l10n.enterFullName;
    }
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      errors['email'] = l10n.enterEmailAddress;
    } else if (!_looksLikeEmail(normalizedEmail)) {
      errors['email'] = l10n.enterValidEmailAddress;
    }
    if (password.isEmpty) {
      errors['password'] = l10n.enterPassword;
    } else if (type == AuthFormType.register && password.length < 8) {
      errors['password'] = l10n.useAtLeastEightCharacters;
    }
    if (type == AuthFormType.register) {
      if (confirmation.isEmpty) {
        errors['confirmation'] = l10n.confirmPassword;
      } else if (confirmation != password) {
        errors['confirmation'] = l10n.passwordsDoNotMatch;
      }
      if (!_acceptTerms.value) {
        errors['terms'] = l10n.acceptTermsToContinue;
      }
    }
    _errors.assignAll(errors);
    refreshState();
    if (errors.isNotEmpty) return false;

    _isLoading.value = true;
    refreshState();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (_disposed) return false;
    _isLoading.value = false;
    refreshState();
    return true;
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  void _removeError(String field) {
    _errors.remove(field);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
