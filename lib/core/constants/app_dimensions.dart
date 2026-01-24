import 'package:flutter/animation.dart';

/// App-wide dimension constants
class AppDimensions {
  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Spacing
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;

  // Image sizes
  static const double imageCacheSize = 200.0;
  static const double avatarSmall = 40.0;
  static const double avatarMedium = 60.0;
  static const double avatarLarge = 100.0;
}

/// App-wide text size constants
class AppTextSizes {
  static const double tiny = 10.0;
  static const double small = 12.0;
  static const double body = 14.0;
  static const double bodyLarge = 16.0;
  static const double subtitle = 18.0;
  static const double title = 20.0;
  static const double heading = 24.0;
  static const double headingLarge = 28.0;
  static const double display = 32.0;
}

/// App-wide duration constants
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 1000);
}

/// App-wide animation curve constants
class AppCurves {
  static const ease = Curves.ease;
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const bounceOut = Curves.bounceOut;
}
