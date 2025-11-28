import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_colors.dart';

class BusynessChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BusynessChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Calcular el máximo valor para que la gráfica no se corte
    double maxY = 0;
    for (var item in data) {
      if (item['count'] > maxY) maxY = item['count'].toDouble();
    }
    // Margen superior estético
    maxY = maxY < 10 ? 10 : maxY + 5; 

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 10), // Padding interno
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Afluencia por Hora", 
              style: TextStyle(fontFamily: 'Istok Web', fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                // 2. ALINEACIÓN: spaceAround distribuye las 17 barras uniformemente
                alignment: BarChartAlignment.spaceAround, 
                maxY: maxY,
                
                // Línea base (Eje X)
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.grisBajito, width: 1),
                  ),
                ),
                
                // Cuadrícula sutil horizontal
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5, // Líneas cada 5 personas
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grisBajito.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),

                // Tooltip al tocar
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.grisOscuro,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} personas',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),

                // Títulos (Ejes)
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  
                  // EJE X: Las Horas
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1, // Revisar cada índice
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int hour = value.toInt();
                        
                        // Mostramos etiquetas cada 4 horas para limpieza visual
                        // 6, 10, 14 (2pm), 18 (6pm), 22 (10pm)
                        if (hour == 6 || hour == 10 || hour == 14 || hour == 18 || hour == 22) {
                          String text = hour > 12 ? '${hour - 12}pm' : '${hour}am';
                          if (hour == 12) text = '12pm';
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              text, 
                              style: const TextStyle(
                                color: AppColors.grisOscuro, 
                                fontSize: 11, 
                                fontWeight: FontWeight.w600
                              )
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // 3. BARRAS
                barGroups: data.map((item) {
                  int x = item['hour'];
                  double y = double.parse(item['count'].toString());
                  
                  // Semáforo de colores
                  Color barColor = AppColors.azul; 
                  if (y < 5) barColor = AppColors.success; // Verde (Poco)
                  else if (y > 15) barColor = AppColors.error; // Rojo (Mucho)

                  return BarChartGroupData(
                    x: x,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        color: barColor,
                        width: 14, // <--- BARRA MÁS ANCHA PARA QUE SE VEA MEJOR
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                           show: false, // Fondo desactivado para evitar errores
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}