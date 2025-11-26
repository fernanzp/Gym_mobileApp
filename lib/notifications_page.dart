import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de prueba (Dummy Data)
    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'payment_success',
        'title': 'Pago Exitoso',
        'message':
            'Tu mensualidad del plan "Plan Mensual" ha sido procesada correctamente.',
        'time': 'Hace 2 min',
        'isRead': false,
      },
      {
        'type': 'access_alert',
        'title': 'Intento de Acceso',
        'message': 'Se registró tu huella en el torniquete de entrada.',
        'time': 'Hace 1 hora',
        'isRead': false,
      },
      {
        'type': 'promo',
        'title': '¡Trae a un amigo!',
        'message':
            'Este fin de semana, invita a un amigo a entrenar totalmente gratis.',
        'time': 'Ayer',
        'isRead': true,
      },
      {
        'type': 'payment_due',
        'title': 'Recordatorio de Pago',
        'message':
            'Tu membresía está próxima a vencer en 3 días. Renueva para evitar interrupciones.',
        'time': 'Hace 2 días',
        'isRead': true,
      },
      {
        'type': 'info',
        'title': 'Mantenimiento',
        'message':
            'El área de regaderas estará cerrada por mantenimiento el día de mañana de 10am a 12pm.',
        'time': 'Hace 1 semana',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: 'Istok Web',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          // Botón opcional para "Marcar todo como leído"
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.playlist_add_check_rounded,
              color: AppColors.azul,
            ),
            tooltip: 'Marcar todo como leído',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppColors.grisBajito,
          indent: 70, // Deja espacio para el icono
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return _NotificationItem(data: item);
        },
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

    // Lógica visual según el tipo de notificación
    IconData iconData;
    Color iconColor;
    Color iconBg;

    switch (data['type']) {
      case 'payment_success':
        iconData = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
        iconBg = AppColors.successLight;
        break;
      case 'payment_due':
        iconData = Icons.credit_card_off_rounded;
        iconColor = AppColors.error;
        iconBg = AppColors.errorLight;
        break;
      case 'access_alert':
        iconData = Icons.fingerprint_rounded;
        iconColor = AppColors.azul;
        iconBg = const Color(0xFFE0F2FE); // Azul muy claro
        break;
      case 'promo':
        iconData = Icons.star_outline_rounded;
        iconColor = AppColors.warning;
        iconBg = const Color(0xFFFEF3C7); // Amarillo claro
        break;
      default:
        iconData = Icons.notifications_none_rounded;
        iconColor = AppColors.grisOscuro;
        iconBg = AppColors.grisBajito;
    }

    return Container(
      color: isRead
          ? Colors.white
          : AppColors.azul.withOpacity(0.04), // Fondo sutil si no se ha leído
      child: InkWell(
        onTap: () {}, // Aquí iría la lógica para abrir el detalle
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono Circular
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),

              // Contenido de Texto
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
                            fontWeight: isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          data['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isRead
                                ? AppColors.grisMedio
                                : AppColors.azul,
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['message'],
                      style: const TextStyle(
                        fontFamily: 'Istok Web',
                        fontSize: 14,
                        color: AppColors.grisOscuro,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Punto azul si no está leído
              if (!isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.azul,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
