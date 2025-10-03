import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTextTheme = TextTheme(
  displayLarge: GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ), // Headlines (e.g. app bar title)

  titleMedium: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ), // Section titles

  bodyLarge: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  ), // Main body text

  bodyMedium: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  ), // Secondary body text

  labelLarge: GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  ), // Button text

  labelSmall: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  ), // Captions / helper text
);

final theme = ThemeData(
  textTheme: appTextTheme,
  primarySwatch: Colors.blue,
);
