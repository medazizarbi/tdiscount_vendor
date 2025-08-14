import 'package:flutter/material.dart';

class TColors {
  // product card colors
  static const Color cardlight = Color.fromARGB(255, 255, 255, 255);
  static const Color carddark = Color.fromARGB(255, 54, 54, 54);
  // App theme colors
  static const Color primary = Color.fromARGB(255, 255, 199, 29);
  static const Color secondary = Color.fromARGB(255, 255, 15, 0);
  static const Color accent = Color(0xFFb0c7ff);

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;
  static const Color textprice = Color.fromARGB(255, 228, 60, 26);

  // Background colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  // Background Container colors for the white widget in evry screen
  static const Color lightContainer = Color.fromRGBO(222, 222, 222, 1);
  static Color darkContainer = const Color.fromARGB(255, 0, 0, 0);

  // Button colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}

Color themedColor(BuildContext context, Color light, Color dark) {
  return Theme.of(context).brightness == Brightness.dark ? dark : light;
}
