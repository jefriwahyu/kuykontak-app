import 'package:flutter/material.dart';

// Kelas ini akan kita gunakan untuk menggantikan MaterialPageRoute
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          // Durasi animasi
          transitionDuration: const Duration(milliseconds: 300),
          // Halaman tujuan
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          // Builder untuk membuat transisi animasinya
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            // Tentukan posisi awal dan akhir
            const begin = Offset(1.0, 0.0); // Mulai dari kanan luar layar
            const end = Offset.zero; // Berakhir di tengah layar
            // Tentukan kurva animasi (misal: ease-out)
            const curve = Curves.easeOut;

            // Gabungkan tween dengan kurva
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            // Gunakan SlideTransition untuk menganimasikan perpindahan halaman
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
