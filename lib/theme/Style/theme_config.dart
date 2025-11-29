import 'package:flutter/material.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blueGrey.shade900,
      scaffoldBackgroundColor: Colors.grey.shade100,
      fontFamily: TextStyles.primaryFont,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyles.headerLarge(color: Colors.black87),
        displayMedium: TextStyles.headerMedium(color: Colors.black87),
        displaySmall: TextStyles.headerSmall(color: Colors.black87),
        bodyLarge: TextStyles.bodyLarge(color: Colors.black87),
        bodyMedium: TextStyles.bodyMedium(color: Colors.black87),
        bodySmall: TextStyles.bodySmall(color: Colors.black54),
        labelLarge: TextStyles.buttonLarge(color: Colors.white),
        labelMedium: TextStyles.buttonMedium(color: Colors.white),
        labelSmall: TextStyles.buttonSmall(color: Colors.white),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey.shade900,
        titleTextStyle: TextStyles.appBarTitle(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.blueGrey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: TextStyles.bottomNavLabel(),
        unselectedLabelStyle: TextStyles.bottomNavLabel(color: Colors.white54),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blueGrey.shade900,
      scaffoldBackgroundColor: Colors.blueGrey.shade900,
      fontFamily: TextStyles.primaryFont,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyles.headerLarge(),
        displayMedium: TextStyles.headerMedium(),
        displaySmall: TextStyles.headerSmall(),
        bodyLarge: TextStyles.bodyLarge(),
        bodyMedium: TextStyles.bodyMedium(),
        bodySmall: TextStyles.bodySmall(color: Colors.white70),
        labelLarge: TextStyles.buttonLarge(),
        labelMedium: TextStyles.buttonMedium(),
        labelSmall: TextStyles.buttonSmall(),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blueGrey.shade800,
        titleTextStyle: TextStyles.appBarTitle(),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}