import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.warning,
    required this.success,
    required this.border,
    required this.textSecondary,
  });

  final Color warning;
  final Color success;
  final Color border;
  final Color textSecondary;

  @override
  AppThemeExtension copyWith({
    Color? warning,
    Color? success,
    Color? border,
    Color? textSecondary,
  }) {
    return AppThemeExtension(
      warning: warning ?? this.warning,
      success: success ?? this.success,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
