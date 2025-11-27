import 'package:flutter/material.dart';

class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

// Lista de contenido para las dos pantallas de bienvenida
const List<OnboardingItem> onboardingData = [
  // Slide 1: GymFlow
  OnboardingItem(
    imagePath: 'assets/images/welcome_bg1.png', 
    title: 'GymFlow',
    subtitle: 'Bienvenido a nuestra comunidad fitness. Un lugar cómodo donde todos somos una familia y nos apoyamos.',
  ),
  // Slide 2: GymFlow
  OnboardingItem(
    imagePath: 'assets/images/welcome_bg2.png', 
    title: 'GymFlow',
    subtitle: 'Para comenzar a usar la app, favor de presentarse en recepción para registrarte.',
  ),
];