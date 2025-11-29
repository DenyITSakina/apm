import 'package:flutter/material.dart';

class TextStyles {
  // Font Families
  static const String primaryFont = 'LeagueSpartan';
  static const String secondaryFont = 'Mitr';
  static const String accentFont = 'Roboto';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Text Styles untuk aplikasi

  // Headers
  static TextStyle headerLarge({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 32,
      fontWeight: bold,
      color: color,
    );
  }

  static TextStyle headerMedium({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 24,
      fontWeight: semiBold,
      color: color,
    );
  }

  static TextStyle headerSmall({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: medium,
      color: color,
    );
  }

  // Body Text
  static TextStyle bodyLarge({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 18,
      fontWeight: regular,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: regular,
      color: color,
    );
  }

  static TextStyle bodySmall({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: regular,
      color: color,
    );
  }

  // Caption
  static TextStyle caption({Color color = Colors.white54}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: light,
      color: color,
    );
  }

  // Button Text
  static TextStyle buttonLarge({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 18,
      fontWeight: semiBold,
      color: color,
    );
  }

  static TextStyle buttonMedium({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: medium,
      color: color,
    );
  }

  static TextStyle buttonSmall({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: medium,
      color: color,
    );
  }

  // Custom Text Styles untuk komponen spesifik
  static TextStyle drawerTitle({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: secondaryFont,
      fontSize: 20,
      fontWeight: semiBold,
      color: color,
    );
  }

  static TextStyle drawerItem({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: medium,
      color: color,
    );
  }

  static TextStyle appBarTitle({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: secondaryFont,
      fontSize: 18,
      fontWeight: bold,
      color: color,
    );
  }

  static TextStyle bottomNavLabel({Color color = Colors.white}) {
    return TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: medium,
      color: color,
    );
  }
}