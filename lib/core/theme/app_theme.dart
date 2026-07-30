import 'package:flutter/material.dart';

import '../design_system/extensions/app_theme_extension.dart';
import '../design_system/tokens/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? AppColors.darkPrimary : AppColors.lightPrimary,
      onPrimary: dark ? AppColors.darkBackground : Colors.white,
      primaryContainer: dark
          ? AppColors.darkPrimaryContainer
          : AppColors.lightPrimaryContainer,
      onPrimaryContainer: dark
          ? AppColors.darkTextPrimary
          : const Color(0xFF14532D),
      secondary: dark ? AppColors.darkSecondary : AppColors.lightSecondary,
      onSecondary: dark ? AppColors.darkBackground : Colors.white,
      secondaryContainer: dark
          ? AppColors.darkSecondaryContainer
          : AppColors.lightSecondaryContainer,
      onSecondaryContainer: dark
          ? AppColors.darkTextPrimary
          : const Color(0xFF164E63),
      error: dark ? AppColors.darkError : AppColors.lightError,
      onError: dark ? AppColors.darkBackground : Colors.white,
      errorContainer: dark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
      onErrorContainer: dark
          ? const Color(0xFFFECACA)
          : const Color(0xFF7F1D1D),
      surface: dark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      surfaceContainerHighest: dark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      onSurfaceVariant: dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary,
      outline: dark ? AppColors.darkBorder : AppColors.lightBorder,
      outlineVariant: dark ? AppColors.darkBorder : AppColors.lightBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark
          ? AppColors.lightSurface
          : AppColors.darkSurfaceVariant,
      onInverseSurface: dark
          ? AppColors.lightTextPrimary
          : AppColors.darkTextPrimary,
      inversePrimary: dark ? AppColors.lightPrimary : AppColors.darkPrimary,
    );
    final textTheme = ThemeData(brightness: brightness).textTheme
        .apply(
          fontFamily: AppTypography.fontFamily,
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        )
        .copyWith(
          headlineLarge: ThemeData(
            brightness: brightness,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
          headlineMedium: ThemeData(
            brightness: brightness,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          titleLarge: ThemeData(
            brightness: brightness,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: ThemeData(
            brightness: brightness,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide(color: scheme.outline),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: shape,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: shape,
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size.square(AppSizes.minTouchTarget),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xs),
        ),
      ),
      radioTheme: const RadioThemeData(visualDensity: VisualDensity.standard),
      switchTheme: const SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          warning: dark ? AppColors.darkWarning : AppColors.lightWarning,
          success: dark ? AppColors.darkSuccess : AppColors.lightSuccess,
          border: dark ? AppColors.darkBorder : AppColors.lightBorder,
          textSecondary: dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          successForeground: dark
              ? const Color(0xFFBBF7D0)
              : const Color(0xFF14532D),
          successContainer: dark
              ? const Color(0xFF14532D)
              : const Color(0xFFDCFCE7),
          warningForeground: dark
              ? const Color(0xFFFDE68A)
              : const Color(0xFF78350F),
          warningContainer: dark
              ? const Color(0xFF78350F)
              : const Color(0xFFFEF3C7),
          errorForeground: dark
              ? const Color(0xFFFECACA)
              : const Color(0xFF7F1D1D),
          errorContainer: dark
              ? const Color(0xFF7F1D1D)
              : const Color(0xFFFEE2E2),
          informationForeground: dark
              ? const Color(0xFFCFFAFE)
              : const Color(0xFF164E63),
          informationContainer: dark
              ? const Color(0xFF164E63)
              : const Color(0xFFCFFAFE),
          neutralForeground: dark
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF334155),
          neutralContainer: dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
      ],
    );
  }
}
