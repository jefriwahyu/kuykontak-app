import 'package:flutter/material.dart';

/// [SlideRightRoute] adalah kelas untuk membuat animasi transisi halaman
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          // Durasi total animasi transisi.
          transitionDuration: const Duration(milliseconds: 300),

          // Builder untuk halaman tujuan yang akan ditampilkan setelah transisi.
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,

          // Builder yang mendefinisikan dan membuat widget animasi transisi.
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            // Tentukan posisi awal dan akhir transisi.
            const begin =
                Offset(1.0, 0.0); // Mulai dari kanan (100% lebar layar).
            const end = Offset.zero; // Berakhir di posisi normal (0,0).
            const curve = Curves.easeOut; // Kurva untuk memperhalus animasi.

            // Gabungkan posisi (Tween) dengan kurva animasi.
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            // Gunakan SlideTransition untuk menganimasikan perpindahan halaman.
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
