import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors based on the design
  static const Color background = Color(0xFF1A1A1A); // Dark background
  static const Color surface = Color(0xFF2A2A2A); // Card/container background
  static const Color primary = Color(0xFF28A745); // Green primary color
  static const Color primaryVariant = Color(0xFF1E7E34); // Darker green
  static const Color secondary = Color(0xFF28A745); // Same as primary
  static const Color accent = Color(0xFF00D2FF); // Light blue accent

  // Text colors
  static const Color onBackground = Color(
    0xFFFFFFFF,
  ); // White text on dark background
  static const Color onSurface = Color(0xFFFFFFFF); // White text on surfaces
  static const Color textSecondary = Color(0xFF999999); // Gray text
  static const Color textHint = Color(0xFF666666); // Hint text color

  // Button colors
  static const Color buttonPrimary = Color(0xFF28A745); // Primary button color
  static const Color buttonSecondary = Color(
    0xFF6C757D,
  ); // Secondary button color
  static const Color buttonDisabled = Color(0xFF666666); // Disabled button

  // Input field colors
  static const Color inputBorder = Color(0xFF444444); // Input border
  static const Color inputFocused = Color(0xFF28A745); // Focused input border

  // Status colors
  static const Color error = Color(0xFFDC3545); // Error red
  static const Color success = Color(0xFF28A745); // Success green
  static const Color warning = Color(0xFFFFC107); // Warning yellow

  // Country flag and misc
  static const Color ukraineBlue = Color(0xFF005BBB);
  static const Color ukraineYellow = Color(0xFFFFD500);
}
