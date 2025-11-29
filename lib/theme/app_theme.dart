import 'package:flutter/material.dart';

class AppTheme {
  // Tema terang standar
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    // Warna latar belakang perancah akan diatur di widget utama
    scaffoldBackgroundColor: Colors.white,
  );

  // Definisi gradien latar belakang
  static LinearGradient backgroundGradientSatu = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6EC1E4), 
      Color(0xFF61CE70),
    ],
  );

   static LinearGradient backgroundGradientDua = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF61CE70),
      Color(0xFF6EC1E4),
    ],
  );
}
