import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/app_colors.dart';

class BusynessChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const BusynessChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Calcular máximo valor (BLINDADO)
    double maxY = 0;
    for (var item in data) {
      // Convertimos a double sin importar si viene como int o string
      double val = double.tryParse(item['count'].toString()) ?? 0.0;
      if (val > maxY) maxY = val;
    }
    maxY = maxY < 10 ? 10 : maxY + 5;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
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
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                borderData: FlBorderData(
                  show: true,
                  border: const Border(bottom: BorderSide(color: AppColors.grisBajito, width: 1)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.grisBajito.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
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
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int hour = value.toInt();
                        if (hour == 6 || hour == 10 || hour == 14 || hour == 18 || hour == 22) {
                          String text = hour > 12 ? '${hour - 12}pm' : '${hour}am';
                          if (hour == 12) text = '12pm';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: const TextStyle(color: AppColors.grisOscuro, fontSize: 11, fontWeight: FontWeight.w600)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                // AQUÍ ESTÁ LA MAGIA: Mapeo seguro de datos
                barGroups: data.map((item) {
                  int x = int.tryParse(item['hour'].toString()) ?? 0;
                  double y = double.tryParse(item['count'].toString()) ?? 0.0;
                  
                  Color barColor = AppColors.azul;
                  if (y < 5) barColor = AppColors.success; 
                  else if (y > 15) barColor = AppColors.error; 

                  return BarChartGroupData(
                    x: x,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        color: barColor,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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