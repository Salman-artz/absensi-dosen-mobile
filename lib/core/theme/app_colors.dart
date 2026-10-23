import 'package:flutter/material.dart';

/// Nordic Electric Indigo Palette (Pilihan 4 - SaaS Minimalist)
class AppColors {
  AppColors._();

  // Primary Branding
  static const Color primary = Color(0xFF4F46E5);       // Electric Indigo 600
  static const Color primaryDark = Color(0xFF3730A3);   // Deep Indigo 800
  static const Color primaryLight = Color(0xFF6366F1);  // Indigo 500
  static const Color accent = Color(0xFF818CF8);        // Soft Iris 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background & Surfaces (Light)
  static const Color background = Color(0xFFF9FAFB);    // Cool Gray 50
  static const Color surface = Color(0xFFFFFFFF);       // Pure White
  static const Color surfaceVariant = Color(0xFFF3F4F6);// Gray 100
  static const Color border = Color(0xFFE5E7EB);        // Slate 200
  static const Color divider = Color(0xFFF3F4F6);

  // Background & Surfaces (Dark)
  static const Color darkBackground = Color(0xFF0F172A); // Dark Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
  static const Color darkDivider = Color(0xFF1E293B);

  // Typography
  static const Color textPrimary = Color(0xFF111827);   // Gray 900
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textMuted = Color(0xFF9CA3AF);     // Gray 400
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Attendance Status Tokens
  static const Color statusHadir = Color(0xFF16A34A);   // Green 600
  static const Color statusHadirBg = Color(0xFFDCFCE7); // Green 100
  static const Color statusTelat = Color(0xFFD97706);   // Amber 600
  static const Color statusTelatBg = Color(0xFFFEF3C7); // Amber 100
  static const Color statusIzin = Color(0xFF0284C7);    // Sky 600
  static const Color statusIzinBg = Color(0xFFE0F2FE);  // Sky 100
  static const Color statusAlpa = Color(0xFFDC2626);    // Red 600
  static const Color statusAlpaBg = Color(0xFFFEE2E2);  // Red 100

  // Status Dark Tokens (softer bg for dark mode)
  static const Color statusHadirDarkBg = Color(0xFF064E3B);
  static const Color statusTelatDarkBg = Color(0xFF78350F);
  static const Color statusIzinDarkBg = Color(0xFF0C4A6E);
  static const Color statusAlpaDarkBg = Color(0xFF7F1D1D);

  // Helper method for attendance status color
  static Color getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'HADIR':
        return statusHadir;
      case 'TELAT':
        return statusTelat;
      case 'IZIN':
      case 'SAKIT':
      case 'CUTI':
      case 'DINAS_LUAR':
        return statusIzin;
      case 'ALPHA':
      case 'TIDAK_HADIR':
      case 'REJECTED':
        return statusAlpa;
      default:
        return textMuted;
    }
  }

  static Color getStatusBgColor(String? status, {bool isDark = false}) {
    switch (status?.toUpperCase()) {
      case 'HADIR':
        return isDark ? statusHadirDarkBg : statusHadirBg;
      case 'TELAT':
        return isDark ? statusTelatDarkBg : statusTelatBg;
      case 'IZIN':
      case 'SAKIT':
      case 'CUTI':
      case 'DINAS_LUAR':
        return isDark ? statusIzinDarkBg : statusIzinBg;
      case 'ALPHA':
      case 'TIDAK_HADIR':
      case 'REJECTED':
        return isDark ? statusAlpaDarkBg : statusAlpaBg;
      default:
        return isDark ? darkSurfaceVariant : surfaceVariant;
    }
  }
}
