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
      final mem = data['membresia'];
      
      List<Map<String, dynamic>> list = [];

      // 1. Notificación de Alerta (Vencimiento)
      if (mem != null && mem['tipo_alerta'] != 'none') {
        String type = mem['tipo_alerta']; // expired, urgent, warning
        String title = '';
        String time = 'Ahora';

        if (type == 'expired') title = '¡Membresía Vencida!';
        else if (type == 'urgent') title = 'Renovación Urgente';
        else if (type == 'warning') title = 'Recordatorio de Pago';

        list.add({
          'type': type,
          'title': title,
          'message': mem['mensaje_alerta'],
          'time': time,
          'isRead': false, // Siempre aparece como no leída para llamar la atención
        });
      }

      // 2. Notificación Informativa (Fechas)
      if (mem != null && mem['inicio'] != '--') {
         list.add({
          'type': 'info_payment',
          'title': 'Detalles de tu Plan',
          'message': 'Plan: ${mem['nombre']}\nPagado el: ${mem['inicio']}\nVence el: ${mem['fin']}',
          'time': 'Info',
          'isRead': true,
        });
      }

      // 3. Relleno
      list.add({'type': 'welcome', 'title': 'Bienvenido', 'message': 'Sistema de notificaciones activo.', 'time': 'Hoy', 'isRead': true});

      if (mounted) setState(() { notifications = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Istok Web', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20)),
      ),
      // RefreshIndicator para que puedas deslizar y actualizar después de cambiar la BD
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.azul,
        child: _loading 
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty 
            ? const Center(child: Text("Sin notificaciones"))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (ctx, i) => const Divider(height: 20, color: Colors.transparent),
                itemBuilder: (ctx, i) => _NotificationItem(data: notifications[i]),
              ),
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
    IconData icon; Color color; Color bg;

    switch (data['type']) {
      case 'expired': // ROJO
        icon = Icons.block_rounded; color = AppColors.error; bg = AppColors.errorLight; break;
      case 'urgent': // NARANJA
        icon = Icons.timer_rounded; color = const Color(0xFFFF6B00); bg = const Color(0xFFFFF7ED); break;
      case 'warning': // AMARILLO
        icon = Icons.warning_amber_rounded; color = AppColors.warning; bg = const Color(0xFFFEF3C7); break;
      case 'info_payment': // AZUL
        icon = Icons.receipt_long_rounded; color = AppColors.azul; bg = const Color(0xFFEFF6FF); break;
      default: 
        icon = Icons.notifications_none_rounded; color = AppColors.grisOscuro; bg = AppColors.grisBajito;
    }

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : bg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grisBajito),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40, 
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['title'], style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 15, color: Colors.black87)),
                    Text(data['time'], style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(data['message'], style: const TextStyle(fontSize: 13, color: AppColors.grisOscuro, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}