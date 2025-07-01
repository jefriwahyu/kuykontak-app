import 'package:flutter/material.dart';

// Warna utama dari mockup
const Color primaryColor = Colors.blue; // Warna aksen biru
const Color backgroundColor =
    Color(0xFFF5F5F7); // Warna latar belakang sedikit abu-abu
const Color cardColor = Colors.white; // Warna untuk card atau input field
const Color textColor = Colors.black87;
const Color deleteColor = Colors.red;

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Poppins', // Anda bisa ganti font sesuai selera

    // Tema untuk AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor:
          textColor, // Warna untuk ikon (seperti tombol kembali) dan teks
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Tema untuk Text Field
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      labelStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // Tema untuk Card
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Tema untuk Tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
