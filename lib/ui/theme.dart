import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const yellow = Color(0xFFF6C709);
  static const deepYellow = Color(0xFFECC300);
  static const dark = Color(0xFF111111);
  static const lightGray = Color(0xFFF2F2F2);
  static const cardBorder = Color(0xFFDDDBDA);
}

final appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.manropeTextTheme(),
  primaryColor: AppColors.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
  ),
);
