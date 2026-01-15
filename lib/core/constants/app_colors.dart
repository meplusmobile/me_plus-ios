import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFAA72A); // Orange/Gold
  static const Color primaryLight = Color(0xFFFCC36E);
  static const Color primaryDark = Color(0xFF815C23);
  static const Color primaryVeryLight = Color(
    0xFFFBEFDF,
  ); // Very light orange background
  static const Color primaryPale = Color(0xFFFFFBF5); // Pale orange tint

  // Secondary Colors
  static const Color secondary = Color(0xFF6B8BCA); // Blue
  static const Color secondaryDark = Color(0xFF5A7BA6); // Darker blue
  static const Color secondaryLight = Color(0xFF3DD5D5); // Cyan
  static const Color secondaryCyan = Color(0xFF71E9E9);
  static const Color secondaryLightCyan = Color(0xFFA0F7F7);
  static const Color secondaryBlue = Color(0xFF5DADE2); // Light blue
  static const Color secondaryDeepBlue = Color(0xFF60A5FA); // Deep blue

  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF8BC34A);
  static const Color successBright = Color(0xFF6FD195); // Bright green
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color errorLight = Color(0xFFFF4444);
  static const Color errorBright = Color(0xFFE74C3C); // Bright red
  static const Color errorDanger = Color(0xFFE83636); // Danger red
  static const Color errorCritical = Color(0xFFC32430); // Critical red
  static const Color warning = Color(0xFFFFB300); // Orange
  static const Color warningYellow = Color(0xFFF4D03F); // Yellow warning
  static const Color warningGold = Color(0xFFDAA520); // Gold warning
  static const Color warningAmber = Color(0xFFF59E0B); // Amber
  static const Color warningPale = Color(0xFFFDE047); // Pale yellow
  static const Color warningYellowBright = Color(0xFFFBC02D); // Bright yellow

  // Text Colors
  static const Color textPrimary = Color(0xFF2E2E2E); // Dark gray
  static const Color textSecondary = Color(0xFF8B8B8B); // Medium gray
  static const Color textLight = Color(0xFFF8F8F8); // Almost white
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMedium = Color(0xFF6E6E6E); // Medium-dark gray
  static const Color textDark = Color(0xFF374151); // Very dark gray
  static const Color textCharcoal = Color(0xFF455A64); // Charcoal

  static const Color background = Color(0xFFF8F8F8);
  static const Color backgroundLight = Color(0xFFFFF3E0); // Light beige
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2E2E2E);
  static const Color surfaceGray = Color(0xFFF5F5F5); // Light gray surface
  static const Color surfaceInput = Color(0xFFFBFBFB); // Input field background

  // UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFE6E6E6);
  static const Color dividerGray = Color(0xFFE5E5E5);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledGray = Color(0xFFB0BEC5); // Gray disabled
  static const Color overlay = Color(0x80000000); // Black with 50% opacity
  static const Color searchIcon = Color(0xFFCCCCCC); // Search icon gray

  // Navigation Colors
  static const Color navSelected = Color(0xFF8E8E93);

  // Additional UI Colors
  static const Color goldAccent = Color(0xFFF9A62A); // Gold accent

  // Transparent
  static const Color transparent = Colors.transparent;

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
