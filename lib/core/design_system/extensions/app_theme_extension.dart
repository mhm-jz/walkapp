import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.warning,
    required this.success,
    required this.border,
    required this.textSecondary,
    required this.successForeground,
    required this.successContainer,
    required this.warningForeground,
    required this.warningContainer,
    required this.errorForeground,
    required this.errorContainer,
    required this.informationForeground,
    required this.informationContainer,
    required this.neutralForeground,
    required this.neutralContainer,
  });

  final Color warning;
  final Color success;
  final Color border;
  final Color textSecondary;
  final Color successForeground;
  final Color successContainer;
  final Color warningForeground;
  final Color warningContainer;
  final Color errorForeground;
  final Color errorContainer;
  final Color informationForeground;
  final Color informationContainer;
  final Color neutralForeground;
  final Color neutralContainer;

  @override
  AppThemeExtension copyWith({
    Color? warning,
    Color? success,
    Color? border,
    Color? textSecondary,
    Color? successForeground,
    Color? successContainer,
    Color? warningForeground,
    Color? warningContainer,
    Color? errorForeground,
    Color? errorContainer,
    Color? informationForeground,
    Color? informationContainer,
    Color? neutralForeground,
    Color? neutralContainer,
  }) {
    return AppThemeExtension(
      warning: warning ?? this.warning,
      success: success ?? this.success,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      successForeground: successForeground ?? this.successForeground,
      successContainer: successContainer ?? this.successContainer,
      warningForeground: warningForeground ?? this.warningForeground,
      warningContainer: warningContainer ?? this.warningContainer,
      errorForeground: errorForeground ?? this.errorForeground,
      errorContainer: errorContainer ?? this.errorContainer,
      informationForeground:
          informationForeground ?? this.informationForeground,
      informationContainer: informationContainer ?? this.informationContainer,
      neutralForeground: neutralForeground ?? this.neutralForeground,
      neutralContainer: neutralContainer ?? this.neutralContainer,
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
      successForeground: Color.lerp(
        successForeground,
        other.successForeground,
        t,
      )!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warningForeground: Color.lerp(
        warningForeground,
        other.warningForeground,
        t,
      )!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      errorForeground: Color.lerp(errorForeground, other.errorForeground, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      informationForeground: Color.lerp(
        informationForeground,
        other.informationForeground,
        t,
      )!,
      informationContainer: Color.lerp(
        informationContainer,
        other.informationContainer,
        t,
      )!,
      neutralForeground: Color.lerp(
        neutralForeground,
        other.neutralForeground,
        t,
      )!,
      neutralContainer: Color.lerp(
        neutralContainer,
        other.neutralContainer,
        t,
      )!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
