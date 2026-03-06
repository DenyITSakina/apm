import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0D8AAE);
  static const Color primaryLight = Color(0xFF4FB3D9);
  static const Color primaryDark = Color(0xFF0A6B8A);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color accent = Color(0xFFFFA000);
  static const Color background = Color(0xFFEFF7F9);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  static const Color teal600 = Color(0xFF00897B);
  static const Color teal700 = Color(0xFF00796B);
  static const Color teal800 = Color(0xFF00695C);
  static const Color teal50 = Color(0xFFE0F2F1);
}

class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static final TextStyle labelText = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle errorText = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.error,
  );

  static final TextStyle successText = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.success,
  );
}

class AppDimens {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  static const double buttonHeight = 60.0;
  static const double inputHeight = 56.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 30.0;
}
