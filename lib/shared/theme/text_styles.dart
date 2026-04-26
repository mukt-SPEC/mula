import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.geist(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static TextStyle get displayMedium =>
      GoogleFonts.geist(fontSize: 45, fontWeight: FontWeight.w400);

  static TextStyle get displaySmall =>
      GoogleFonts.geist(fontSize: 36, fontWeight: FontWeight.w400);

  static TextStyle get headlineLarge =>
      GoogleFonts.geist(fontSize: 32, fontWeight: FontWeight.w400);

  static TextStyle get headlineMedium =>
      GoogleFonts.geist(fontSize: 28, fontWeight: FontWeight.w400);

  static TextStyle get headlineSmall =>
      GoogleFonts.geist(fontSize: 24, fontWeight: FontWeight.w400);

  static TextStyle get titleLarge =>
      GoogleFonts.geist(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium => GoogleFonts.geist(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static TextStyle get titleSmall => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => GoogleFonts.geist(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get bodySmall => GoogleFonts.geist(
    fontSize: 12, // Base size
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle get labelLarge => GoogleFonts.geist(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.geist(
    fontSize: 12, // Base size
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.geist(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // --- Geist Mono ---

  static TextStyle get monoDisplay =>
      GoogleFonts.geistMono(fontSize: 32, fontWeight: FontWeight.w600);

  static TextStyle get monoTitleLarge =>
      GoogleFonts.geistMono(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get monoBodyLarge => GoogleFonts.geistMono(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get monoBodyMedium => GoogleFonts.geistMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get monoBodySmall => GoogleFonts.geistMono(
    fontSize: 12, // Base size
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle get monoLabel => GoogleFonts.geistMono(
    fontSize: 12, // Base size
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
