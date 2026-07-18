import 'package:flutter/foundation.dart';

enum AuthFormType { login, register }

final class AuthFormController extends ChangeNotifier {
  AuthFormController(this.type);

  final AuthFormType type;

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _disposed = false;
  Map<String, String> _errors = const <String, String>{};

  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  bool get acceptTerms => _acceptTerms;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmation => _obscureConfirmation;
  String? errorFor(String field) => _errors[field];

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setAcceptTerms(bool value) {
    _acceptTerms = value;
    if (value) _removeError('terms');
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmationVisibility() {
    _obscureConfirmation = !_obscureConfirmation;
    notifyListeners();
  }

  void clearError(String field) {
    if (_errors.containsKey(field)) {
      _removeError(field);
      notifyListeners();
    }
  }

  Future<bool> submit({
    required String email,
    required String password,
    String fullName = '',
    String confirmation = '',
  }) async {
    if (_isLoading) return false;
    final errors = <String, String>{};
    if (type == AuthFormType.register && fullName.trim().isEmpty) {
      errors['name'] = 'Enter your full name';
    }
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      errors['email'] = 'Enter your email address';
    } else if (!_looksLikeEmail(normalizedEmail)) {
      errors['email'] = 'Enter a valid email address';
    }
    if (password.isEmpty) {
      errors['password'] = 'Enter your password';
    } else if (type == AuthFormType.register && password.length < 8) {
      errors['password'] = 'Use at least 8 characters';
    }
    if (type == AuthFormType.register) {
      if (confirmation.isEmpty) {
        errors['confirmation'] = 'Confirm your password';
      } else if (confirmation != password) {
        errors['confirmation'] = 'Passwords do not match';
      }
      if (!_acceptTerms) {
        errors['terms'] = 'Accept the terms and privacy policy to continue';
      }
    }
    _errors = errors;
    notifyListeners();
    if (errors.isNotEmpty) return false;

    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (_disposed) return false;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    final dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1;
  }

  void _removeError(String field) {
    _errors = Map<String, String>.of(_errors)..remove(field);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
