import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../core/api.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Api _api = Api();
  List<Map<String, dynamic>> notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _api.getUserProfile();
      final mem = data['membresia']; // Datos que vienen de Laravel
      
      List<Map<String, dynamic>> list = [];

      if (mem != null) {
        int dias = mem['dias_restantes']; // El cálculo que hizo Laravel
        bool activo = mem['activo'];
        String nombrePlan = mem['nombre'];
        String fechaPago = mem['inicio']; // Fecha de inicio (Pago)
        String fechaFin = mem['fin'];     // Fecha de vencimiento

        // --- 1. LÓGICA DE ALERTAS (10, 5 días y Vencida) ---
        
        if (!activo || dias < 0) {
          // CASO: VENCIDA
          list.add({
            'type': 'expired',
            'title': '¡Membresía Vencida!',
            'message': 'Tu $nombrePlan ha expirado. Renueva para seguir entrenando.',
            'time': 'Ahora',
            'isRead': false,
          });
        } 
        else if (dias <= 5) {
          // CASO: URGENTE (5 DÍAS O MENOS)
          list.add({
            'type': 'urgent',
            'title': '¡Quedan $dias días!',
            'message': 'Tu $nombrePlan está por finalizar. ¡No pierdas tu racha!',
            'time': 'Urgente',
            'isRead': false,
          });
        } 
        else if (dias <= 10) {
          // CASO: AVISO (10 DÍAS O MENOS)
          list.add({
            'type': 'warning',
            'title': 'Renovación Próxima',
            'message': 'Te quedan $dias días de tu $nombrePlan. Ve preparándote.',
            'time': 'Aviso',
            'isRead': false,
          });
        }

        // --- 2. NOTIFICACIÓN INFORMATIVA DE PAGO (SIEMPRE VISIBLE) ---
        if (fechaPago != '--') {
          list.add({
            'type': 'info_payment',
            'title': 'Detalles de tu Plan',
            'message': 'Pagado el: $fechaPago\nVence el: $fechaFin',
            'time': 'Info',
            'isRead': true,
          });
        }
      }

      // 3. Notificación de bienvenida (Relleno bonito)
      list.add({
        'type': 'welcome',
        'title': 'Bienvenido a Gym App',
        'message': 'Aquí recibirás tus avisos importantes.',
        'time': 'Hace días',
        'isRead': true,
      });

      if (mounted) {
        setState(() {
          notifications = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontFamily: 'Istok Web', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : notifications.isEmpty 
          ? const Center(child: Text("No tienes notificaciones"))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: notifications.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.grisBajito, indent: 70, endIndent: 16),
              itemBuilder: (ctx, i) => _NotificationItem(data: notifications[i]),
            ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _NotificationItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isRead = data['isRead'];
    IconData icon;
    Color color;
    Color bg;

    // Configuración de colores e iconos según el tipo
    switch (data['type']) {
      case 'expired': // ROJO
        icon = Icons.block_rounded;
        color = AppColors.error;
        bg = AppColors.errorLight;
        break;
      case 'urgent': // NARANJA (5 días)
        icon = Icons.access_time_filled_rounded;
        color = const Color(0xFFFF6B00); // Naranja fuerte
        bg = const Color(0xFFFFF0E0);
        break;
      case 'warning': // AMARILLO (10 días)
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
        bg = const Color(0xFFFEF3C7);
        break;
      case 'info_payment': // AZUL (Información de pago)
        icon = Icons.receipt_long_rounded;
        color = AppColors.azul;
        bg = const Color(0xFFE0F2FE);
        break;
      default: // GRIS (Bienvenida)
        icon = Icons.notifications_none_rounded;
        color = AppColors.grisOscuro;
        bg = AppColors.grisBajito;
    }

    return Container(
      color: isRead ? Colors.white : AppColors.azul.withOpacity(0.04),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono circular
          Container(
            width: 44, 
            height: 44, 
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['title'], 
                      style: TextStyle(
                        fontFamily: 'Istok Web', 
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, 
                        fontSize: 16, 
                        color: Colors.black87
                      )
                    ),
                    Text(
                      data['time'], 
                      style: TextStyle(
                        fontSize: 12, 
                        color: data['type'] == 'expired' ? AppColors.error : AppColors.azul, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['message'], 
                  style: const TextStyle(fontFamily: 'Istok Web', fontSize: 14, color: AppColors.grisOscuro, height: 1.3)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}