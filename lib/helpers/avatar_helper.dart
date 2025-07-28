import 'dart:ui';
import 'package:flutter/material.dart';

// Kumpulan fungsi bantuan untuk membuat avatar.
class AvatarHelper {
  // Palet warna yang tersedia untuk latar belakang avatar.
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

  // Mendapatkan 1-2 huruf inisial dari nama lengkap.
  static String getInitials(String name) {
    if (name.isEmpty) return '?';

    // Pisahkan nama berdasarkan spasi untuk mendapatkan setiap kata.
    List<String> words =
        name.trim().split(' ').where((s) => s.isNotEmpty).toList();

    if (words.length == 1) {
      // Jika hanya satu kata, ambil huruf pertamanya.
      return words[0][0].toUpperCase();
    } else if (words.length > 1) {
      // Jika lebih dari satu kata, ambil inisial dari kata pertama dan terakhir.
      return (words[0][0] + words.last[0]).toUpperCase();
    }

    return '?';
  }

  // Memilih warna yang konsisten dari palet berdasarkan ID.
  static Color getAvatarColor(String id) {
    if (id.isEmpty) return _avatarColors[0];

    // Hashcode ID dipakai agar ID yang sama selalu mendapat warna yang sama.
    return _avatarColors[id.hashCode % _avatarColors.length];
  }
}
