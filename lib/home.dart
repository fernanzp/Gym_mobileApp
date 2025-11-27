import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_colors.dart';
import 'core/api.dart';
import 'calendar_page.dart';
import 'notifications_page.dart';
import 'main.dart'; // Para reiniciar app al salir

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; 
  final Api _api = Api();

  // --- VARIABLES DASHBOARD ---
  double currentCapacity = 0.0;
  int peopleCount = 0;
  String userName = "Cargando...";
  String todayDateStr = "";
  bool isLoadingAforo = true;
  Timer? _timer;
  
  // --- VARIABLES MEMBRESÍA ---
  List<String> attendanceDates = [];
  String planName = "--";
  String planStart = "--";
  String planEnd = "--";
  DateTime? membershipStartDate; // Fecha real de inicio para lógica de colores
  bool isPlanActive = false;

  // --- VARIABLES ESTADÍSTICAS (Horas) ---
  List<String> peakHours = [];
  List<String> quietHours = [];

  @override
  void initState() {
    super.initState();
    
    // 1. Configurar fecha en español
    initializeDateFormatting('es_ES', null).then((_) {
      if(mounted) {
        setState(() {
          todayDateStr = toBeginningOfSentenceCase(DateFormat('E, d MMM', 'es_ES').format(DateTime.now()))!;
        });
      }
    });
    
    // 2. Cargas Iniciales
    _fetchData();
    
    // 3. Timer de 5 segundos para actualizar todo en tiempo real
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _refreshAforoOnly();
        _cargarPerfil(); 
        // No cargamos estadísticas cada 5s porque eso cambia poco, ahorramos recursos
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetchData() {
    _cargarHeader();
    _refreshAforoOnly();
    _cargarPerfil();
    _cargarEstadisticas();
  }

  // --- CONEXIONES API ---

  Future<void> _refreshAforoOnly() async {
    try {
      final data = await _api.getAforo();
      if (mounted) setState(() {
        peopleCount = data['cantidad'];
        currentCapacity = double.parse(data['porcentaje'].toString());
        isLoadingAforo = false;
      });
    } catch (_) {}
  }

  Future<void> _cargarHeader() async {
    try {
      final data = await _api.getHeaderData();
      if (mounted) setState(() => userName = (data['nombre'] ?? "Usuario").split(" ")[0]);
    } catch (_) {}
  }

  Future<void> _cargarPerfil() async {
    try {
      final data = await _api.getUserProfile();
      if(mounted) setState(() {
        attendanceDates = List<String>.from(data['asistencias']);
        final plan = data['membresia'];
        
        planName = plan['nombre'];
        planStart = plan['inicio'];
        planEnd = plan['fin'];
        isPlanActive = plan['activo'];

        if (plan['inicio_raw'] != null) {
          membershipStartDate = DateTime.parse(plan['inicio_raw']);
        }
      });
    } catch (_) {}
  }

  Future<void> _cargarEstadisticas() async {
    try {
      final data = await _api.getBusynessStats();
      if (mounted) {
        setState(() {
          peakHours = List<String>.from(data['peak']);
          quietHours = List<String>.from(data['quiet']);
        });
      }
    } catch (_) {}
  }

  void _logout() async {
    // Limpiar caché de imágenes
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    await _api.logout();
    
    if (mounted) {
      setState(() {
        userName = "";
        peopleCount = 0;
        attendanceDates = [];
      });
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  // --- COMPONENTES UI: CALENDARIO SEMANAL ---

  Widget _weekCalendar() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<DateTime> weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Esta Semana", style: TextStyle(fontFamily: 'Istok Web', fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((date) => _buildDayItem(date)).toList(),
        ),
      ],
    );
  }

  Widget _buildDayItem(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateCheck = DateTime(date.year, date.month, date.day);
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    bool attended = attendanceDates.contains(dateStr);
    bool isPast = dateCheck.isBefore(today);
    bool isToday = dateCheck.isAtSameMomentAs(today);

    // Lógica: Gris si es antes de la fecha de inscripción
    bool isBeforeMembership = true; 
    if (membershipStartDate != null) {
        final startNormal = DateTime(membershipStartDate!.year, membershipStartDate!.month, membershipStartDate!.day);
        isBeforeMembership = dateCheck.isBefore(startNormal);
    }

    Color bgColor = AppColors.grisBajito;
    Color textColor = AppColors.grisOscuro;
    BoxBorder? border;

    if (attended) {
      bgColor = AppColors.success; 
      textColor = Colors.white;
    } else if (isPast) {
      if (isBeforeMembership) {
         bgColor = AppColors.grisBajito; // Gris (Antes de inscribirse)
      } else {
         bgColor = AppColors.error; // Rojo (Faltó)
         textColor = Colors.white;
      }
    }

    if (isToday) {
      border = Border.all(color: AppColors.azul, width: 2);
      if (!attended && (!isPast || isBeforeMembership)) textColor = AppColors.azul;
    }

    String dayName = toBeginningOfSentenceCase(DateFormat('E', 'es_ES').format(date))!.replaceAll('.', '');

    return Column(
      children: [
        Text(dayName, style: TextStyle(
          color: isToday ? AppColors.azul : AppColors.grisOscuro, 
          fontSize: 12, 
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w500
        )),
        const SizedBox(height: 8),
        Container(
          width: 35, height: 35,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: border),
          child: Center(
            child: Text(
              "${date.day}", 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)
            ),
          ),
        ),
      ],
    );
  }

  // --- TARJETA AFORO ---

  Widget _currentCapacityCard() {
    return Container(
      height: 190,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Ocupación Actual', style: TextStyle(fontFamily: 'Istok Web', fontSize: 18, fontWeight: FontWeight.w600)),
            Text("$peopleCount Personas", style: const TextStyle(color: AppColors.azul, fontWeight: FontWeight.bold))
          ]),
          Expanded(child: Stack(alignment: Alignment.center, children: [
            SfRadialGauge(axes: <RadialAxis>[RadialAxis(minimum: 0, maximum: 100, showLabels: false, showTicks: false, startAngle: 180, endAngle: 0, radiusFactor: 0.9, axisLineStyle: const AxisLineStyle(thickness: 15, color: AppColors.grisBajito), pointers: <GaugePointer>[RangePointer(value: currentCapacity, width: 15, color: AppColors.azul, enableAnimation: true)])]),
            Align(alignment: const Alignment(0.0, 0.1), child: Text('${currentCapacity.toInt()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.azul)))
          ]))
        ],
      ),
    );
  }

  // --- TARJETA MEMBRESÍA ---

  Widget _membershipSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(planName, style: const TextStyle(fontFamily: 'Istok Web', fontSize: 18, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: isPlanActive ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(20)),
              child: Text(isPlanActive ? 'Activo' : 'Vencido', style: TextStyle(fontFamily: 'Istok Web', fontSize: 14, fontWeight: FontWeight.w600, color: isPlanActive ? AppColors.activeText : AppColors.expiredText)),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
             const Icon(Icons.payment, size: 20, color: AppColors.grisOscuro),
             const SizedBox(width: 12),
             Text('Pagado el: $planStart', style: const TextStyle(fontFamily: 'Istok Web', fontSize: 15, color: AppColors.grisOscuro)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
             const Icon(Icons.event_busy, size: 20, color: AppColors.grisOscuro),
             const SizedBox(width: 12),
             Text('Vence el: $planEnd', style: const TextStyle(fontFamily: 'Istok Web', fontSize: 15, color: AppColors.grisOscuro)),
          ]),
        ],
      ),
    );
  }

  // --- NUEVA SECCIÓN: ESTADÍSTICAS DE HORAS ---

  Widget _busynessSection() {
    if (peakHours.isEmpty && quietHours.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mejor momento para asistir hoy al gimnasio", style: TextStyle(fontFamily: 'Istok Web', fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.local_fire_department_rounded, color: AppColors.error, size: 20), const SizedBox(width: 6), const Text("Concurrido", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error))]),
                    const SizedBox(height: 8),
                    ...peakHours.map((h) => Text(h, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.spa_rounded, color: AppColors.success, size: 20), const SizedBox(width: 6), const Text("Ausentado", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))]),
                    const SizedBox(height: 8),
                    ...quietHours.map((h) => Text(h, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      title: Row(children: [
        const CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/avatar-default.jpg')),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hola, $userName', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
          Text(todayDateStr, style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ]),
      ]),
      actions: [
        IconButton(
          icon: SvgPicture.asset('assets/icons/bell.svg', width: 24, colorFilter: const ColorFilter.mode(AppColors.grisOscuro, BlendMode.srcIn)),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // --- NAVEGACIÓN ---

  Widget _getScreen() {
    if (_currentIndex == 0) return _buildDashboard();
    if (_currentIndex == 1) return const CalendarPage(); 
    return _buildProfileView();
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _weekCalendar(),
        const SizedBox(height: 20),
        _currentCapacityCard(),
        const SizedBox(height: 24),
        _membershipSection(),
        const SizedBox(height: 24),
        _busynessSection(), // Nueva sección
      ],
    );
  }

  Widget _buildProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/avatar-default.jpg')),
          const SizedBox(height: 20),
          Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentIndex == 0 ? _appBar() : null, // AppBar solo en Home
      body: _getScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 64, color: AppColors.grisBajito,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: () => setState(() => _currentIndex = 0), icon: SvgPicture.asset('assets/icons/home.svg', width: 30, colorFilter: ColorFilter.mode(_currentIndex == 0 ? AppColors.azul : AppColors.grisOscuro, BlendMode.srcIn))),
                IconButton(onPressed: () => setState(() => _currentIndex = 1), icon: SvgPicture.asset('assets/icons/calendar.svg', width: 30, colorFilter: ColorFilter.mode(_currentIndex == 1 ? AppColors.azul : AppColors.grisOscuro, BlendMode.srcIn))),
                IconButton(onPressed: () => setState(() => _currentIndex = 2), icon: SvgPicture.asset('assets/icons/user.svg', width: 30, colorFilter: ColorFilter.mode(_currentIndex == 2 ? AppColors.azul : AppColors.grisOscuro, BlendMode.srcIn))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}