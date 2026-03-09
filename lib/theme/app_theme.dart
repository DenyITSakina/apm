import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  static LinearGradient backgroundGradientSatu = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6EC1E4), Color(0xFF61CE70)],
  );

  static LinearGradient backgroundGradientDua = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF61CE70), Color(0xFF6EC1E4)],
  );
}
