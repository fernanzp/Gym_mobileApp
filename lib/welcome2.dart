import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class Welcome2Page extends StatelessWidget {
  const Welcome2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Asegúrate de agregar esta imagen a tus assets con este nombre
                image: AssetImage('assets/images/welcome_bg2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. DEGRADADO OSCURO (Overlay)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.4, 0.6, 0.85, 1.0],
              ),
            ),
          ),

          // 3. CONTENIDO
          SafeArea(
            child: Padding(
              // Mismo padding que en Welcome 1 para consistencia
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOGO ---
                  Image.asset(
                    'assets/images/logo_blue.png',
                    width: 80,
                    height: 80,
                  ),

                  const Spacer(),

                  // --- TEXTOS ---
                  const Text(
                    'Brawl Gym', // Texto según el mockup 2
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Istok Web',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Para poder comenzar a usar la app, favor de presentarse en recepción para registrarte.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- PIE DE PÁGINA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots (Indicadores)
                      Row(
                        children: [
                          // Dot 1: Inactivo (Gris circular)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dot 2: Activo (Azul estirado) - INVERTIDO RESPECTO A WELCOME 1
                          Container(
                            width: 24,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.azul,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),

                      // Botón "Iniciar sesión"
                      FilledButton(
                        onPressed: () {
                          // Navegar al Login
                          Navigator.pushNamed(context, '/login');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.azul,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Borde muy redondeado (Pill shape)
                          ),
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600, // Semi-bold para legibilidad
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
