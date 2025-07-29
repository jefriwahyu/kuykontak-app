import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/contact_bloc.dart';
import 'ui/contact_list_page.dart';
import 'ui/splash_screen.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

// Main function sebagai entry point aplikasi
void main() {
  runApp(
    // Menggunakan ChangeNotifierProvider untuk manajemen state theme
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

// Widget root dari aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus aplikasi dengan BlocProvider untuk manajemen state kontak
    return BlocProvider(
      // Inisialisasi ContactBloc dan langsung memuat kontak saat pertama kali dibuat
      create: (context) => ContactBloc()..add(LoadContacts()),
      child: MaterialApp(
        title: 'Aplikasi Kontak',
        debugShowCheckedModeBanner: false, // Menyembunyikan debug banner
        theme: buildAppTheme(), // Menerapkan tema kustom
        initialRoute: '/', // Route awal aplikasi
        routes: {
          // Daftar route yang tersedia dalam aplikasi
          '/': (context) =>
              const SplashScreen(), // Screen splash saat pertama kali dibuka
          '/home': (context) =>
              ContactListPage(), // Halaman utama daftar kontak
        },
      ),
    );
  }
}
