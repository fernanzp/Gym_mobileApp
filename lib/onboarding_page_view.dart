import 'package:flutter/material.dart';
import 'theme/app_colors.dart'; // Tus colores personalizados
import 'onboarding_data.dart';  // Los datos que creamos en el paso anterior

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el deslizamiento para actualizar los puntos (dots)
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          final item = onboardingData[index];
          final isLastPage = index == onboardingData.length - 1;

          return Stack(
            children: [
              // 1. IMAGEN DE FONDO
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(item.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // 2. DEGRADADO (Sombra oscura para que se lean las letras)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                      Colors.black
                    ],
                    stops: const [0.4, 0.6, 0.85, 1.0],
                  ),
                ),
              ),

              // 3. CONTENIDO (Textos y Botones)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo_blue.png', // Asegúrate de tener este asset
                        width: 80,
                        height: 80,
                      ),
                      
                      const Spacer(),
                      
                      // Título
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Istok Web',
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtítulo
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // --- PIE DE PÁGINA (Puntos y Botón) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Indicadores (Bolitas)
                          Row(
                            children: List.generate(
                              onboardingData.length,
                              (dotIndex) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 8,
                                width: _currentPage == dotIndex ? 24 : 8, // La activa es más larga
                                decoration: BoxDecoration(
                                  color: _currentPage == dotIndex ? AppColors.azul : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          // Botón de Acción
                          isLastPage
                              ? FilledButton(
                                  onPressed: () {
                                    // AL TERMINAR: Navegar al Login
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.azul,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  ),
                                  child: const Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                )
                              : FloatingActionButton(
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                  backgroundColor: AppColors.azul,
                                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}