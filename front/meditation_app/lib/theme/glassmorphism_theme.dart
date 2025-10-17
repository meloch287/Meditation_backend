import 'package:flutter/material.dart';

final ThemeData glassmorphismTheme = ThemeData(
  primaryColor: Colors.white.withOpacity(0.1),
  scaffoldBackgroundColor: const Color(0xFF0F0F23),
  fontFamily: 'Roboto',

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Colors.white70,
      fontSize: 14,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.15),
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      side: BorderSide(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
    ),
    labelStyle: TextStyle(
      color: Colors.white.withOpacity(0.7),
    ),
    hintStyle: TextStyle(
      color: Colors.white.withOpacity(0.5),
    ),
  ),
);