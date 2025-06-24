import 'package:flutter/material.dart';

class ThemeProvider {
  static const availableThemes = ["Default", "Dark", "Light"];

  static ThemeData getTheme(String theme) {
    switch (theme) {
      case "Dark":
        return ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark().copyWith(
            primary: Colors.deepPurple,
            secondary: Colors.teal,
          ),
        );
      case "Light":
        return ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light().copyWith(
            primary: Colors.blue,
            secondary: Colors.orange,
          ),
        );
      default:
        return ThemeData().copyWith(
          colorScheme: const ColorScheme.light().copyWith(
            primary: Colors.indigo,
            secondary: Colors.pink,
          ),
        );
    }
  }
}
