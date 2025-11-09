import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  // Colores de la app
  static const brandBlue = Color(0xFF0460D9);
  static const greyDark = Color(0xFF727272);
  static const greyBg = Color(0xFFF1F1F1);
  static const greyInactive = Color(0xFFD9D9D9);

  Widget _svg(String path, {bool active = false, double size = 30}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        active ? brandBlue : greyDark,
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
            backgroundImage: AssetImage('assets/images/avatar-default.jpg'),
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
                    color: brandBlue,
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

  /// Crea un solo item del calendario (ej. "Lun" y "15")
  Widget _buildDayItem({
    required String day,
    required int date,
    required bool attended,
  }) {
    // Define los colores basados en si asistió o no
    final bgColor = attended ? brandBlue : greyInactive;
    final textColor = attended ? Colors.white : greyDark;

    return Column(
      children: [
        // Texto del día (Lun, Mar...)
        Text(
          day,
          style: const TextStyle(
            color: greyDark,
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
    // Datos de ejemplo (puedes reemplazar esto con datos reales)
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
      // Usamos padding horizontal de 16 para alinear con las tarjetas
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
    // Valor de ejemplo del aforo (puedes cambiarlo dinámicamente)
    const double currentCapacity = 65; // Porcentaje de ocupación

    return Container(
      // 1. Altura fija para la tarjeta, para uniformidad
      height: 190,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: greyBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16), // Añadimos padding interno
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarjeta
          const Text(
            'Ocupación Actual',
            style: TextStyle(
              color: greyDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          // --- ¡CAMBIO AQUÍ! ---
          // Aumentamos el espacio para "bajar" el gráfico
          const SizedBox(height: 24), // <-- Antes era 8
          // 2. Expanded para crear el "lienzo" para nuestro Stack
          Expanded(
            // 3. Stack nos permite encimar el gráfico y el texto
            child: Stack(
              alignment: Alignment.center, // Centra los hijos
              children: [
                // --- HIJO 1: EL GRÁFICO (SIN TEXTO) ---
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      showLabels: false, // No mostrar labels
                      showTicks: false, // No mostrar ticks
                      startAngle: 180, // Semicírculo
                      endAngle: 0,
                      radiusFactor: 1.5, // Tu ajuste
                      axisLineStyle: AxisLineStyle(
                        thickness: 22,
                        color: greyInactive,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: currentCapacity,
                          width: 22, // Mismo grosor
                          color: brandBlue,
                          enableAnimation: true,
                          cornerStyle: CornerStyle.bothCurve,
                        ),
                      ],
                    ),
                  ],
                ),

                // --- HIJO 2: EL TEXTO (CON ALIGN) ---
                Align(
                  alignment: Alignment(0.0, -0.2), // Tu ajuste
                  child: Text(
                    '${currentCapacity.toInt()}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: brandBlue,
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

  // buildBody
  Widget _buildBody() {
    // <-- RENOMBRADO (antes _cards)
    final placeholders = List.generate(4, (_) => _card());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        // AÑADIMOS EL CALENDARIO AL INICIO DE LA LISTA
        _weekCalendar(),
        const SizedBox(height: 20), // Un espacio
        // Ocupación actual
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
        color: greyBg,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // Bottom pill con Container + Row (centrado perfecto)
  Widget _bottomNav() {
    return Padding(
      // Mantenemos tu padding para el efecto "flotante"
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        // 1. Reemplazamos BottomAppBar por un Container
        child: Container(
          height: 64, // 2. Le damos una altura fija (ej. 64)
          color: greyBg, // El color de fondo
          child: Row(
            // 3. La Row ahora se centrará verticalmente dentro de los 64px
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
