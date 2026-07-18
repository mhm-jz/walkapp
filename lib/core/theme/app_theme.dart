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
      onPrimary: AppColors.darkBackground,
      primaryContainer: dark
          ? AppColors.darkPrimaryContainer
          : AppColors.lightPrimaryContainer,
      onPrimaryContainer: dark
          ? AppColors.darkTextPrimary
          : const Color(0xFF14532D),
      secondary: dark ? AppColors.darkSecondary : AppColors.lightSecondary,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: dark
          ? AppColors.darkSecondaryContainer
          : AppColors.lightSecondaryContainer,
      onSecondaryContainer: dark
          ? AppColors.darkTextPrimary
          : const Color(0xFF164E63),
      error: dark ? AppColors.darkError : AppColors.lightError,
      onError: AppColors.darkBackground,
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
    final errorTextColor = dark
        ? scheme.error
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.24), scheme.error);

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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.xl,
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
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.46),
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
        disabledBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        errorStyle: TextStyle(color: errorTextColor),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
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
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
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
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.14),
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          warning: dark ? AppColors.darkWarning : AppColors.lightWarning,
          success: dark ? AppColors.darkSuccess : AppColors.lightSuccess,
          border: dark ? AppColors.darkBorder : AppColors.lightBorder,
          textSecondary: dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ],
    );
  }
}
