import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData mainTheme = ThemeData(
    primaryColor: const Color(0xFFFFDF70),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    ),
  );
}
