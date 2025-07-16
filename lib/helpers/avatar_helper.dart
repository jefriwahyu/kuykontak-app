import 'dart:ui';
import 'package:flutter/material.dart';

class AvatarHelper {
  // Daftar warna yang akan digunakan secara acak
  static final List<Color> _avatarColors = [
    Colors.red.shade400,
    Colors.green.shade400,
    Colors.blue.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.pink.shade300,
    Colors.indigo.shade400,
    Colors.brown.shade400,
    Colors.cyan.shade400,
    Colors.lightGreen.shade500,
    Colors.lime.shade600,
    Colors.amber.shade600,
    Colors.deepOrange.shade400,
  ];

  // Fungsi untuk mendapatkan inisial dari nama
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    // Pisahkan nama berdasarkan spasi dan hapus bagian yang kosong
    List<String> words =
        name.trim().split(' ').where((s) => s.isNotEmpty).toList();

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else if (words.length > 1) {
      // Ambil huruf pertama dari kata pertama dan kata terakhir
      return (words[0][0] + words.last[0]).toUpperCase();
    }
    return '?';
  }

  // Fungsi untuk mendapatkan warna konsisten berdasarkan ID
  static Color getAvatarColor(String id) {
    if (id.isEmpty) return _avatarColors[0];
    // Gunakan hash code dari ID untuk memilih warna dari daftar
    return _avatarColors[id.hashCode % _avatarColors.length];
  }
}
