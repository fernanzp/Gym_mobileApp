import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'notifications_page.dart';
import 'calendar_page.dart';

import 'theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  // Helper para SVGs usando los colores de la App
  Widget _svg(String path, {bool active = false, double size = 30}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        // Usamos AppColors.azul para activo, AppColors.grisOscuro para inactivo
        active ? AppColors.azul : AppColors.grisOscuro,
        BlendMode.srcIn,
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            // Asegúrate de tener esta imagen en tus assets o usa un color de fondo temporal
            backgroundImage: AssetImage('assets/images/avatar-default.jpg'),
            backgroundColor: AppColors.grisBajito,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hola, Charlie',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Mar, 16 Sep',
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Campana con punto azul
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  // Aquí iría tu navegación a notificaciones
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                },
                icon: _svg('assets/icons/bell.svg', size: 24),
                tooltip: 'Notificaciones',
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.azul, // Azul corporativo
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Crea un solo item del calendario
  Widget _buildDayItem({
    required String day,
    required int date,
    required bool attended,
  }) {
    // Define los colores usando AppColors
    final bgColor = attended
        ? AppColors.activeText
        : AppColors.grisBajito; // Usamos gris bajito para inactivo
    // Si está activo texto blanco, si no, gris oscuro
    final textColor = attended ? Colors.white : AppColors.grisOscuro;

    return Column(
      children: [
        // Texto del día (Lun, Mar...)
        Text(
          day,
          style: const TextStyle(
            color: AppColors.grisOscuro,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Círculo con la fecha
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              date.toString(),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekCalendar() {
    // Datos de ejemplo
    final List<Map<String, dynamic>> weekData = [
      {'day': 'Lun', 'date': 15, 'attended': true},
      {'day': 'Mar', 'date': 16, 'attended': false},
      {'day': 'Mie', 'date': 17, 'attended': true},
      {'day': 'Jue', 'date': 18, 'attended': false},
      {'day': 'Vie', 'date': 19, 'attended': false},
      {'day': 'Sab', 'date': 20, 'attended': false},
      {'day': 'Dom', 'date': 21, 'attended': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekData.map((data) {
          return _buildDayItem(
            day: data['day'],
            date: data['date'],
            attended: data['attended'],
          );
        }).toList(),
      ),
    );
  }

  /// Tarjeta con el gráfico de ocupación actual (CORREGIDO y AJUSTADO)
  Widget _currentCapacityCard() {
    const double currentCapacity = 65; // Porcentaje de ocupación

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título afuera
        const Text(
          'Ocupación Actual',
          style: TextStyle(
            fontFamily: 'Istok Web',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Contenedor de la Card
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          padding: const EdgeInsets.all(16),
          // Usamos Center para centrar vertical y horizontalmente el contenido
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      showLabels: false,
                      showTicks: false,
                      startAngle: 180,
                      endAngle: 0,
                      radiusFactor: 0.9, // Reducido el factor de radio
                      axisLineStyle: const AxisLineStyle(
                        thickness:
                            15, // Reducido el grosor para que sea más chico
                        color: Colors.white,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: const <GaugePointer>[
                        RangePointer(
                          value: currentCapacity,
                          width: 15, // Reducido el ancho del puntero
                          color: AppColors.azul,
                          enableAnimation: true,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: const Alignment(
                    0.0,
                    0.1,
                  ), // Ajustada la posición del texto
                  child: Text(
                    '${currentCapacity.toInt()}%',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azul,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de Membresía
  Widget _membershipSection() {
    const String planName = 'Plan Mensual';
    const bool isActive = true;
    const String startDate = '16 Sep 2025';
    const String endDate = '16 Oct 2025';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tú Membresía',
          style: TextStyle(
            fontFamily: 'Istok Web',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.activeBg
                          : AppColors.expiredBg,
                      borderRadius: BorderRadius.circular(20),
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
              Row(
                children: [
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
              Row(
                children: [
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
    );
  }

  Widget _buildBody() {
    switch (index) {
      case 0:
        // ÍNDICE 0: El contenido original del Home
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            _weekCalendar(),
            const SizedBox(height: 20),
            _currentCapacityCard(),
            const SizedBox(height: 24),
            _membershipSection(),
          ],
        );
      case 1:
        // ÍNDICE 1: La nueva página de Calendario
        return const CalendarPage();
      case 2:
        // ÍNDICE 2: Perfil (Placeholder)
        return const Center(child: Text("Perfil en construcción"));
      default:
        return Container();
    }
  }

  Widget _bottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => setState(() => index = 0),
              icon: _svg('assets/icons/home.svg', active: index == 0),
              tooltip: 'Inicio',
            ),
            IconButton(
              onPressed: () => setState(() => index = 1),
              icon: _svg('assets/icons/calendar.svg', active: index == 1),
              tooltip: 'Calendario',
            ),

            // 🔥 AQUÍ ESTÁ EL CAMBIO: PopupMenuButton en lugar de IconButton simple
            PopupMenuButton<String>(
              // Icono de la tuerca. Usamos color grisOscuro siempre o azul si estuviera activo (opcional)
              icon: _svg('assets/icons/gear.svg', active: false),
              tooltip: 'Configuración',
              color: Colors.white,
              surfaceTintColor: Colors.white,
              // Offset negativo para que el menú salga hacia ARRIBA de la barra
              offset: const Offset(0, -60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                // Opción: Cerrar Sesión
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: AppColors.error, // Texto rojo
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'logout') {
                  // Lógica de logout
                  print("Cerrando sesión desde la barra inferior...");
                  // Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // CONDICIÓN: Si el index es 0 (Home), muestra _appBar(). Si no, null (ocúltalo).
      appBar: index == 0 ? _appBar() : null,
      body: _buildBody(),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
