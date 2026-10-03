import 'package:flutter/material.dart';

/// Design token untuk seluruh aplikasi Anjungan Pendaftaran Mandiri.
///
/// Semua warna, radius, dan shadow di aplikasi ini sebaiknya diambil dari
/// file ini supaya tampilan antar halaman konsisten.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF0E7C86);
  static const Color primaryDark = Color(0xFF0A5C64);
  static const Color primaryLight = Color(0xFF3FA7B0);
  static const Color primarySoft = Color(0xFFE4F4F6);

  static const Color accent = Color(0xFF10B981);
  static const Color accentDark = Color(0xFF059669);
  static const Color accentSoft = Color(0xFFE7F8F1);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFECFDF3);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFF7E6);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFEFF6FF);

  // Neutral
  static const Color background = Color(0xFFF1F6F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7FAFB);
  static const Color border = Color(0xFFDCE7E9);
  static const Color borderStrong = Color(0xFFBFDCDF);

  static const Color textPrimary = Color(0xFF14343A);
  static const Color textSecondary = Color(0xFF4E6E75);
  static const Color textMuted = Color(0xFF8AA5AB);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Layanan
  static const Color bpjs = Color(0xFF2563EB);
  static const Color bpjsDark = Color(0xFF1D4ED8);
  static const Color umum = Color(0xFF0F9D58);
  static const Color umumDark = Color(0xFF047857);
}

class AppGradients {
  const AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryLight, AppColors.accent],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient brandSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3FBFB), Color(0xFFE8F6F1)],
  );

  static const LinearGradient bpjs = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.bpjs, Color(0xFF3B82F6), Color(0xFF60A5FA)],
  );

  static const LinearGradient umum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.umum, Color(0xFF22C55E), Color(0xFF4ADE80)],
  );

  static const LinearGradient footer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryDark, AppColors.primary],
  );
}

class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 26;
  static const double pill = 999;
}

class AppShadow {
  const AppShadow._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F0E7C86),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A0E7C86),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1A0E7C86),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.32),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppSpacing {
  const AppSpacing._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 44;
}

/// Informasi versi aplikasi, disinkronkan dengan `version:` di pubspec.yaml.
class AppInfo {
  const AppInfo._();

  static const String appName = 'APM RSU Sakina Idaman';
  static const String version = '1.0.0';

  static String get label => 'v$version';
}
