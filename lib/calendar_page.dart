import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../theme/app_colors.dart';
import '../core/api.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Api _api = Api();
  DateTime _focusedDate = DateTime.now();
  final List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  
  List<String> _attendedDates = []; 
  DateTime? _membershipStart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _api.getUserProfile();
      if (mounted) setState(() {
        _attendedDates = List<String>.from(data['asistencias']);
        final plan = data['membresia'];
        // Parseamos la fecha de inicio
        if (plan['inicio_raw'] != null) {
          _membershipStart = DateTime.parse(plan['inicio_raw']);
        }
        _isLoading = false;
      });
    } catch (_) { if(mounted) setState(() => _isLoading = false); }
  }

  void _changeMonth(int increment) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + increment, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final int firstWeekDay = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday;
    final int emptySlots = firstWeekDay - 1;
    
    initializeDateFormatting('es_ES');
    String monthName = toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'es_ES').format(_focusedDate))!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true, automaticallyImplyLeading: false,
        title: const Text('Historial', style: TextStyle(fontFamily: 'Istok Web', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Padding(padding: const EdgeInsets.all(24.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded, color: AppColors.azul, size: 32)),
            Text(monthName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right_rounded, color: AppColors.azul, size: 32)),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _weekDays.map((d) => SizedBox(width: 40, child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)))).toList())),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 12),
            itemCount: emptySlots + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < emptySlots) return Container();
              final date = DateTime(_focusedDate.year, _focusedDate.month, i - emptySlots + 1);
              return _buildDayCell(date);
            },
          )))
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateCheck = DateTime(date.year, date.month, date.day);
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    bool attended = _attendedDates.contains(dateStr);
    bool isPast = dateCheck.isBefore(today);
    bool isToday = dateCheck.isAtSameMomentAs(today);

    // 🔥 CORRECCIÓN CLAVE: Por defecto asumimos que el día es ANTES de la membresía (Gris)
    bool isBeforeMembership = true; 
    
    if (_membershipStart != null) {
       final startNormal = DateTime(_membershipStart!.year, _membershipStart!.month, _membershipStart!.day);
       isBeforeMembership = dateCheck.isBefore(startNormal);
    }

    Color bgColor = AppColors.grisBajito;
    Color textColor = AppColors.grisOscuro;
    BoxBorder? border;

    if (attended) { 
        bgColor = AppColors.success; // Verde
        textColor = Colors.white; 
    } else if (isPast) { 
        // Si ya pasó...
        if (isBeforeMembership) {
            bgColor = AppColors.grisBajito; // Antes de inscribirse = GRIS
        } else {
            bgColor = AppColors.error; // Ya inscrito y falta = ROJO
            textColor = Colors.white; 
        }
    }

    if (isToday) { 
        border = Border.all(color: AppColors.azul, width: 2); 
        // Si es hoy, no has ido y NO es antes de tu membresía, texto azul
        if (!attended && !isPast) textColor = AppColors.azul; 
    }

    return Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: border), child: Center(child: Text('${date.day}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))));
  }
}