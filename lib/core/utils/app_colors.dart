import 'package:flutter/material.dart';

/// App color scheme
/// Primary Color: E71D4E (Red/Pink)
/// Contrast Color: FFD12E (Yellow)
/// Secondary Color: 110934 (Dark Blue/Purple)
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFE71D4E);
  static const Color contrast = Color(0xFFFFD12E);
  static const Color secondary = Color(0xFF110934);

  // Shades and Tints
  static const Color primaryLight = Color(0xFFFF4D75);
  static const Color primaryDark = Color(0xFFB01539);

  static const Color secondaryLight = Color(0xFF1A1254);
  static const Color secondaryDark = Color(0xFF080419);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);

  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE71D4E); // Using primary color
  static const Color warning = Color(0xFFFFD12E); // Using contrast color
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF110934); // Using secondary color
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
}
