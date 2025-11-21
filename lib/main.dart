import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'welcome1.dart';
import 'welcome2.dart';
import 'theme/app_colors.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.azul,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Pantalla inicial: Login
      home: const LoginPage(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/welcome1': (_) => const Welcome1Page(),
        '/welcome2': (_) => const Welcome2Page(),
      },
    );
  }
}
