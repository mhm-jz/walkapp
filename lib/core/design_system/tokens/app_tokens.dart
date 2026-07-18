import 'package:flutter/material.dart';

abstract final class AppColors {
  static const lightPrimary = Color(0xFF22C55E);
  static const lightPrimaryContainer = Color(0xFFDCFCE7);
  static const lightSecondary = Color(0xFF06B6D4);
  static const lightSecondaryContainer = Color(0xFFCFFAFE);
  static const lightWarning = Color(0xFFF59E0B);
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightSuccess = Color(0xFF10B981);
  static const lightError = Color(0xFFEF4444);

  static const darkPrimary = Color(0xFF4ADE80);
  static const darkPrimaryContainer = Color(0xFF14532D);
  static const darkSecondary = Color(0xFF22D3EE);
  static const darkSecondaryContainer = Color(0xFF164E63);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111827);
  static const darkSurfaceVariant = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkSuccess = Color(0xFF34D399);
  static const darkError = Color(0xFFF87171);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppRadii {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

abstract final class AppSizes {
  static const minTouchTarget = 48.0;
  static const contentMaxWidth = 720.0;
  static const progressDiameter = 220.0;
  static const progressStroke = 14.0;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 650);
}

abstract final class AppTypography {
  static const fontFamily = 'Roboto';
}
