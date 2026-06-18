import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ================= Primary (Blue)===========================================
  static const Color primary50 = Color(0xFFE8F1FF);
  static const Color primary100 = Color(0xFFBFD4FF);
  static const Color primary200 = Color(0xFF93B4FF);
  static const Color primary400 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF1D4ED8); // main brand color
  static const Color primary800 = Color(0xFF1E3A8A);
  static const Color primary900 = Color(0xFF0F2060);
  static const Color waterBlue = Color(0xFF0577F9);
  static const Color waterBlueDark = Color(0xFF0063D9);
  static const Color waterBlueLight = Color(0xFF1393FF);
  static const Color waterBubble = Color(0x332BA8FF);

  //==================Accent / Success (Green) =================================
  static const Color accent50 = Color(0xFFECFDF5);
  static const Color accent100 = Color(0xFFD1FAE5);
  static const Color accent400 = Color(0xFF10B981);
  static const Color accent600 = Color(0xFF059669); // price, in-stock, success
  static const Color accent800 = Color(0xFF065F46);

  // ================= Neutrals ================================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color surface = Color(0xFFF9FAFB); // card / input background
  static const Color border = Color(0xFFE5E7EB); // subtle borders
  static const Color divider = Color(0xFFF3F4F6); // list dividers

  // ================= Text ====================================================
  static const Color textPrimary = Color(0xFF1C1C1E); // headings, body
  static const Color textSecondary = Color(0xFFFFFFFF); // labels, hints
  static const Color textDisabled = Color(0xFF9CA3AF); // disabled fields

  // ==================== Semantic =============================================
  static const Color error = Color(0xFFc02e2e);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = accent600;
  static const Color successLight = accent50;
  static const Color info = primary600;
  static const Color infoLight = primary50;
  static const Color isPending = Color(0xFFFFA500);

  // ================ Common shorthands ========================================
  static const Color primary = primary600;
  static const Color accent = accent600;
  static const Color background = white;
  static const Color buttonColor = Color(0xFF4F8C87);
}

class AppGradients {
  AppGradients._();

  // Primary vibrant gradient (Blue to Teal)
  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Teal/Green
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft background gradient for screens
  static const LinearGradient background = LinearGradient(
    colors: [
      Color(0xFFF0FDF4), // Very light mint
      Color(0xFFEFF6FF), // Very light blue
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Glassmorphism subtle gradient for overlays
  static const LinearGradient glass = LinearGradient(
    colors: [
      Color(0x99FFFFFF), // 60% White
      Color(0x33FFFFFF), // 20% White
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
