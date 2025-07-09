import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc/contact_bloc.dart';
import 'ui/contact_list_page.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus seluruh aplikasi dengan BlocProvider
    return BlocProvider(
      create: (context) => ContactBloc()..add(LoadContacts()),
      child: MaterialApp(
        title: 'Aplikasi Kontak',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const ContactListPage(),
      ),
    );
  }
}
