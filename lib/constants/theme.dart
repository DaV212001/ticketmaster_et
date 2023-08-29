import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData({required bool isDark}) {
    return ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3953A4)),
        primaryColor: const Color(0xFF3953A4),
        secondaryHeaderColor: const Color(0xFF64C5BA));
  }
}
