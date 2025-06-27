import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (based on the pink theme from the images)
  static const Color primary = Color(0xFFE91E63); // Pink
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primaryLight = Color(0xFFF8BBD9);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color secondaryDark = Color(0xFFE65100);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Form Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocused = Color(0xFFE91E63);
  static const Color inputError = Color(0xFFF44336);
  static const Color inputSuccess = Color(0xFF4CAF50);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFFE91E63);
  static const Color buttonSecondary = Color(0xFFFF9800);
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE91E63),
      Color(0xFFC2185B),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9800),
      Color(0xFFE65100),
    ],
  );
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}