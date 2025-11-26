import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Fecha focal para controlar qué mes se muestra (Inicia hoy)
  DateTime _focusedDate = DateTime.now();

  // Días de la semana para la cabecera
  final List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  // DATOS DE PRUEBA: Días del mes actual en los que se asistió.
  // En el futuro, esto se llenará con datos de tu API.
  final Set<int> _attendedDays = {
    2,
    5,
    8,
    9,
    12,
    14,
    15,
    16,
    20,
    22,
    23,
    28,
    30,
  };

  // Nombres de meses en español (simple, para no depender de intl por ahora)
  final List<String> _monthNames = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  /// Cambia el mes actual
  void _changeMonth(int increment) {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + increment,
        1,
      );
    });
  }

  /// Calcula cuántos días tiene el mes actual
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Calcula en qué día de la semana cae el día 1 (1=Lunes, 7=Domingo)
  int _getFirstDayOffset(DateTime date) {
    // DateTime usa 1=Lunes...7=Domingo estándar
    return DateTime(date.year, date.month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = _getDaysInMonth(_focusedDate);
    final int firstWeekDay = _getFirstDayOffset(_focusedDate);
    // Ajuste: si el día 1 es Martes (2), necesitamos 1 espacio vacío (Lunes)
    final int emptySlots = firstWeekDay - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar simple, sin botón de atrás porque será una pestaña principal
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Historial de Asistencia',
          style: TextStyle(
            fontFamily: 'Istok Web',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // --- CONTROLES DE NAVEGACIÓN DE MES ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.azul,
                    size: 32,
                  ),
                ),
                Text(
                  '${_monthNames[_focusedDate.month]} ${_focusedDate.year}',
                  style: const TextStyle(
                    fontFamily: 'Istok Web',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.azul,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- CABECERA DE DÍAS (L M M J V S D) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekDays
                  .map(
                    (day) => SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.grisOscuro,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 10),

          // --- GRID DEL CALENDARIO ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 7 días de la semana
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 0,
                ),
                // Total celdas = días vacíos al inicio + días del mes
                itemCount: emptySlots + daysInMonth,
                itemBuilder: (context, index) {
                  // Si estamos en los slots vacíos antes del día 1
                  if (index < emptySlots) {
                    return Container();
                  }

                  // Calcular el número del día real
                  final int dayNumber = index - emptySlots + 1;

                  // Verificar si este día se asistió
                  final bool isAttended = _attendedDays.contains(dayNumber);

                  // Verificar si es hoy (para darle un borde opcional o estilo)
                  final bool isToday =
                      dayNumber == DateTime.now().day &&
                      _focusedDate.month == DateTime.now().month &&
                      _focusedDate.year == DateTime.now().year;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isAttended
                          ? AppColors.activeText
                          : Colors.transparent, // Verde si asistió
                      shape: BoxShape.circle,
                      border: isToday && !isAttended
                          ? Border.all(
                              color: AppColors.azul,
                              width: 2,
                            ) // Borde azul si es hoy y no ha checado
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isAttended
                              ? Colors.white
                              : AppColors.grisOscuro,
                          fontWeight: isAttended || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- FOOTER ESTADÍSTICAS ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.grisBajito,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Asistencias',
                  '${_attendedDays.length}',
                  AppColors.activeText,
                ),
                _buildStatItem(
                  'Ausencias',
                  '${daysInMonth - _attendedDays.length}',
                  AppColors.expiredText,
                ),
                _buildStatItem(
                  'Tasa',
                  '${((_attendedDays.length / daysInMonth) * 100).round()}%',
                  AppColors.azul,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Istok Web',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grisOscuro,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
