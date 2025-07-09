import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkTheme = false;
  double _fontSize = 16.0;

  bool get isDarkTheme => _isDarkTheme;
  double get fontSize => _fontSize;

  void toggleTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }
}
