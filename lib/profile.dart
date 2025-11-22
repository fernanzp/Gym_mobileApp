import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // El índice para el BottomNav es 2 (Perfil)
  int index = 2;

  // Helper para SVGs (mismo que en Home)
  Widget _svg(String path, {bool active = false, double size = 30}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        active ? AppColors.azul : AppColors.grisOscuro,
        BlendMode.srcIn,
      ),
    );
  }

  Widget _bottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 64,
          color: AppColors.grisBajito,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  // Navegar al Home y reemplazar la ruta actual para no apilar
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: _svg('assets/icons/home.svg', active: index == 0),
                tooltip: 'Inicio',
              ),
              IconButton(
                onPressed: () {
                  setState(() => index = 1);
                  // Aquí iría la navegación a Calendario si existiera
                },
                icon: _svg('assets/icons/calendar.svg', active: index == 1),
                tooltip: 'Calendario',
              ),
              IconButton(
                onPressed: () => setState(() => index = 2),
                icon: _svg('assets/icons/user.svg', active: index == 2),
                tooltip: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Datos simulados (esto vendría de tu API/Session)
    const String userName = "Luis Fernando2 Otaku";
    const String userEmail = "lmendoza69@gimeahí.cum";
    const String planName = "Plan Mensual";
    const String startDate = "21/11/2025";
    const String endDate = "21/12/2025";
    const bool isActive = true; // Cambiar a false para probar el color rojo

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40), // Espacio superior
            // --- FOTO DE PERFIL ---
            Center(
              child: CircleAvatar(
                radius: 60, // Tamaño grande (120px diámetro)
                backgroundColor: AppColors.grisBajito, // Fondo si no hay imagen
                backgroundImage: const AssetImage(
                  'assets/images/avatar-default.jpg',
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- NOMBRE Y CORREO ---
            const Text(
              userName,
              style: TextStyle(
                fontFamily: 'Istok Web',
                fontSize: 24, // Tamaño grande como en el mockup
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              userEmail,
              style: TextStyle(
                fontFamily: 'Istok Web',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 48), // Espacio antes de la sección
            // --- SECCIÓN "TU MEMBRESÍA" ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tú Membresía',
                    style: TextStyle(
                      fontFamily: 'Istok Web',
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // Semi-bold
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TARJETA DE DETALLES ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(
                          0xFFE5E7EB,
                        ), // Gris muy suave para el borde
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila Superior: Plan + Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              planName,
                              style: const TextStyle(
                                fontFamily: 'Istok Web',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            // Badge de Estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.activeBg
                                    : AppColors.expiredBg,
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Pill shape
                              ),
                              child: Text(
                                isActive ? 'Activo' : 'Vencido',
                                style: TextStyle(
                                  fontFamily: 'Istok Web',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppColors.activeText
                                      : AppColors.expiredText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Fecha de Inicio
                        Row(
                          children: [
                            // CAMBIO: Usamos _svg con el calendario
                            _svg('assets/icons/calendar.svg', size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Válido desde: $startDate',
                              style: const TextStyle(
                                fontFamily: 'Istok Web',
                                fontSize: 15,
                                color: AppColors.grisOscuro,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Fecha de Fin
                        Row(
                          children: [
                            // CAMBIO: Usamos _svg con el calendario
                            _svg('assets/icons/calendar.svg', size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Válido hasta: $endDate',
                              style: const TextStyle(
                                fontFamily: 'Istok Web',
                                fontSize: 15,
                                color: AppColors.grisOscuro,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
