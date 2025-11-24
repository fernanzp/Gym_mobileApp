import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'core/session.dart'; // Importamos session para checar el token

// Importa tus pantallas
import 'login.dart';
import 'home.dart';
import 'onboarding_page_view.dart'; // Tu pantalla deslizable

void main() async {
  // Aseguramos que los widgets estén listos antes de correr la app (necesario para Session)
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
        // Mantenemos tu color azul
        colorSchemeSeed: const Color(0xFF0066FF), 
        scaffoldBackgroundColor: Colors.white,
      ),
      
      // AuthCheck es el cerebro: decide si mostrar Bienvenida o Home al arrancar
      home: const AuthCheck(), 
      
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/onboarding': (_) => const OnboardingPage(),
      },
    );
  }
}

// WIDGET: Chequeo de Sesión
// Revisa si existe un token guardado apenas abre la app
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: Session.token, // Leemos el token del almacenamiento
      builder: (context, snapshot) {
        // 1. Mientras carga, mostramos un circulito
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay token (Usuario ya logueado antes), va directo al Home
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          return const HomePage();
        }

        // 3. Si NO hay token (Nuevo o cerró sesión), va a la Bienvenida deslizable
        return const OnboardingPage();
      },
    );
  }
}