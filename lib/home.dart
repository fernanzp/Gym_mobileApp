import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
                onPressed: () {},
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
        ? AppColors.azul
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

  /// Tarjeta con el gráfico de ocupación actual
  Widget _currentCapacityCard() {
    const double currentCapacity = 65; // Porcentaje de ocupación

    return Container(
      height: 190,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grisBajito, // Fondo de la tarjeta
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ocupación Actual',
            style: TextStyle(
              color: AppColors.grisOscuro,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
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
                      radiusFactor: 1.5,
                      axisLineStyle: const AxisLineStyle(
                        thickness: 22,
                        color: Colors
                            .white, // Fondo del track en blanco para contraste sobre grisBajito
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: const <GaugePointer>[
                        RangePointer(
                          value: currentCapacity,
                          width: 22,
                          color: AppColors.azul, // Medidor en azul
                          enableAnimation: true,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                      ],
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment(0.0, -0.2),
                  child: Text(
                    '${currentCapacity}%', // Convertimos a entero visualmente si quieres .toInt()
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azul,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final placeholders = List.generate(4, (_) => _card());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _weekCalendar(),
        const SizedBox(height: 20),
        _currentCapacityCard(),
        const SizedBox(height: 0),
        ...placeholders,
      ],
    );
  }

  Widget _card() {
    return Container(
      height: 92,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.grisBajito,
        borderRadius: BorderRadius.circular(16),
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
          color: AppColors.grisBajito, // Fondo del nav
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _buildBody(),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
