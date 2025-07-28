import 'package:flutter/material.dart';

/// Controller untuk mengelola tema dan ukuran font aplikasi.
/// Menggunakan [ChangeNotifier] untuk memberi tahu listener ketika terjadi perubahan.
class ThemeController extends ChangeNotifier {
  // Status tema gelap, default false (tema terang)
  bool _isDarkTheme = false;

  // Ukuran font default
  double _fontSize = 16.0;

  // Getter untuk mendapatkan status tema gelap
  bool get isDarkTheme => _isDarkTheme;

  // Getter untuk mendapatkan ukuran font saat ini
  double get fontSize => _fontSize;

  /// Mengubah tema antara gelap dan terang
  /// [value] : true untuk tema gelap, false untuk tema terang
  void toggleTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners(); // Memberi tahu semua listener tentang perubahan tema
  }

  /// Mengatur ukuran font baru
  /// [value] : nilai ukuran font baru
  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners(); // Memberi tahu semua listener tentang perubahan ukuran font
  }
}
