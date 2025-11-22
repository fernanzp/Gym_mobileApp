import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal (Mismos de la Web)
  static const Color azul = Color(0xFF0460D9);
  static const Color azulOscuro = Color(0xFF0248D2);

  // Grises
  static const Color grisOscuro = Color(0xFF727272);
  static const Color grisMedio = Color(0xFFA3A3A3);
  static const Color grisBajito = Color(0xFFF1F1F1); // Fondo de pantallas

  // Estados (Semáforo)
  static const Color success = Color(0xFF10B981); // Emerald-500 aprox
  static const Color error = Color(0xFFEF4444); // Red-500 aprox
  static const Color warning = Color(0xFFF59E0B); // Amber-500 aprox

  // Fondos suaves para badges (similares a los de la web)
  static const Color successLight = Color(0xFFECFDF5); // Emerald-50
  static const Color errorLight = Color(0xFFFEF2F2); // Rose-50

  // --- NUEVOS COLORES PARA PERFIL ---
  // Estado Activo (Verde mockup)
  static const Color activeText = Color(0xFF238F4D);
  static const Color activeBg = Color(0xFFDBFCE7);

  // Estado Vencido (Rojo similar)
  static const Color expiredText = Color(0xFFB91C1C); // Rojo oscuro para texto
  static const Color expiredBg = Color(0xFFFEE2E2); // Rojo muy claro para fondo
}
