import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'core/session.dart'; 

import 'login.dart';
import 'home.dart';
import 'onboarding_page_view.dart';
import 'notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0066FF), 
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthCheck(), 
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/onboarding': (_) => const OnboardingPage(),
        '/notifications': (_) => const NotificationsPage(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: Session.token,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return const HomePage();
        }
        return const OnboardingPage();
      },
    );
  }
}