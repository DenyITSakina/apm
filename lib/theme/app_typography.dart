import 'package:apm/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografi aplikasi: satu keluarga font (Plus Jakarta Sans) dengan
///Bobot yang konsisten agar semua layar terasa satu sistem.
class AppText {
  const AppText._();

  static const String family = 'Plus Jakarta Sans';

  static TextStyle _base({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    double height = 1.4,
    Color color = AppColors.textPrimary,
    double? spacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: spacing,
    );
  }

  static TextStyle display(BuildContext context) => _base(
    size: _scale(context, 34, 28, 24),
    weight: FontWeight.w800,
    height: 1.15,
    color: AppColors.textPrimary,
    spacing: -0.5,
  );

  static TextStyle title(BuildContext context) => _base(
    size: _scale(context, 26, 22, 19),
    weight: FontWeight.w800,
    height: 1.2,
    spacing: -0.2,
  );

  static TextStyle heading(BuildContext context) => _base(
    size: _scale(context, 19, 17, 16),
    weight: FontWeight.w700,
  );

  static TextStyle body(BuildContext context) => _base(
    size: _scale(context, 15, 14, 13.5),
    color: AppColors.textSecondary,
  );

  static TextStyle bodyStrong(BuildContext context) => _base(
    size: _scale(context, 15, 14, 13.5),
    weight: FontWeight.w600,
  );

  static TextStyle label(BuildContext context) => _base(
    size: _scale(context, 13, 12.5, 12),
    weight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle caption(BuildContext context) => _base(
    size: _scale(context, 12, 11.5, 11),
    weight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle button(BuildContext context) => _base(
    size: _scale(context, 16, 15, 14),
    weight: FontWeight.w700,
    color: Colors.white,
    spacing: 0.3,
  );

  /// Judul besar di header berwarna terang.
  static TextStyle headerTitle(BuildContext context, {double? fontSize}) => _base(
    size: fontSize ?? _scale(context, 30, 26, 22),
    weight: FontWeight.w800,
    color: Colors.white,
    spacing: 1.2,
  );

  static TextStyle headerSubtitle(BuildContext context) => _base(
    size: _scale(context, 14, 13, 12),
    weight: FontWeight.w500,
    color: Color(0xCCFFFFFF),
    height: 1.35,
  );

  /// Angka besar untuk display nomor (scanner, kode booking, antrian).
  static TextStyle numeric(BuildContext context, {double size = 32}) => _base(
    size: size,
    weight: FontWeight.w800,
    color: AppColors.textPrimary,
    spacing: 2,
  );

  static double _scale(
    BuildContext context,
    double mobile,
    double tablet,
    double desktop,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }
}
