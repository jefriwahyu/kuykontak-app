import 'package:flutter/material.dart';

// Palette warna utama aplikasi
const Color primaryColor = Colors.blue; // Warna primer biru untuk aksen utama
const Color secondaryColor = Color(0xFF42A5F5); // Warna sekunder biru muda
const Color backgroundColor =
    Color(0xFFF5F5F7); // Warna background abu-abu terang
const Color cardColor = Colors.white; // Warna dasar untuk card dan input field
const Color textColor = Colors.black87; // Warna teks utama
const Color accentColor = Color(0xFF64B5F6); // Warna aksen tambahan
const Color darkBlue = Color(0xFF0D47A1); // Warna biru tua untuk elemen khusus
const Color lightBlue = Color(0xFFE3F2FD); // Warna biru sangat muda
const Color deleteColor = Colors.red; // Warna untuk aksi penghapusan

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.light, // Mode tema terang
    primaryColor: primaryColor, // Warna utama aplikasi
    scaffoldBackgroundColor: backgroundColor, // Warna background scaffold
    fontFamily: 'Poppins', // Font family default aplikasi

    // Konfigurasi tema AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor, // Warna background AppBar
      foregroundColor: textColor, // Warna teks dan ikon AppBar
      elevation: 0, // Menghilangkan shadow
      centerTitle: true, // Judul AppBar di tengah
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold, // Gaya teks judul AppBar
      ),
    ),

    // Konfigurasi tema Input/Text Field
    inputDecorationTheme: InputDecorationTheme(
      filled: true, // Mengaktifkan fill color
      fillColor: cardColor, // Warna background input field
      labelStyle: const TextStyle(color: Colors.black54), // Gaya teks label
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Border radius default
        borderSide: BorderSide.none, // Tanpa border line
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Border radius saat enabled
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Border radius saat focused
        borderSide: const BorderSide(
            color: primaryColor, width: 2), // Border saat focus
      ),
    ),

    // Konfigurasi tema Card
    cardTheme: CardTheme(
      color: cardColor, // Warna background card
      elevation: 1, // Tinggi shadow card
      shadowColor: Colors.black12, // Warna shadow card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Border radius card
      ),
    ),

    // Konfigurasi tema Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor, // Warna background button
        foregroundColor: Colors.white, // Warna teks button
        padding:
            const EdgeInsets.symmetric(vertical: 16), // Padding vertikal button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Border radius button
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, // Gaya teks button
        ),
      ),
    ),
  );
}
