import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

class Welcome1Page extends StatelessWidget {
  const Welcome1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Asegúrate de que la extensión coincida con tu archivo (.png o .jpg)
                image: AssetImage('assets/images/welcome_bg1.png'),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOGO (Aumentado de tamaño) ---
                  Image.asset(
                    'assets/images/logo_blue.png',
                    width: 80, // Aumentado para que destaque
                    height: 80,
                  ),

                  const Spacer(),

                  // --- TEXTOS ---
                  const Text(
                    'Flow Gym',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Istok Web',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bienvenido a nuestra comunidad fitness. Un espacio acogedor donde somos más que un gimnasio: somos una familia que te impulsa a crecer.',
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
                      // Dots
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.azul,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      // Botón
                      Material(
                        color: AppColors.azul,
                        shape: const CircleBorder(),
                        elevation: 4,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 28,
                            ),
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
