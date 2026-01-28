import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Импорты
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';

class TTCChartWidget extends StatelessWidget {
  final List<double?> temps;

  const TTCChartWidget({super.key, required this.temps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<FlSpot> spots = [];

    // Базовые границы
    double minT = 36.0;
    double maxT = 37.0;

    // 1. Преобразуем данные в точки
    for (int i = 0; i < temps.length; i++) {
      if (temps[i] != null && temps[i]! > 0) {
        final val = temps[i]!;
        spots.add(FlSpot(i.toDouble(), val));

        if (val < minT) minT = val;
        if (val > maxT) maxT = val;
      }
    }

    final bool isEmpty = spots.isEmpty;
    final double maxX = temps.isEmpty ? 6.0 : (temps.length - 1).toDouble();

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDAC0A3).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  l10n.ttcChartTitle,
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary
                  )
              ),
              if (spots.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: TTCTheme.cardBBT.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    "${spots.last.y.toStringAsFixed(1)}°",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TTCTheme.cardBBT,
                        fontSize: 14
                    ),
                  ),
                )
            ],
          ),

          const SizedBox(height: 24),

          // График
          Expanded(
            child: isEmpty
                ? Center(
                child: Text(
                    l10n.ttcChartPlaceholder,
                    style: GoogleFonts.manrope(color: Colors.grey[400])
                )
            )
                : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey[100],
                      strokeWidth: 1
                  ),
                ),

                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            "${value.toInt() + 1}",
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                borderData: FlBorderData(show: false),
                minY: minT - 0.3,
                maxY: maxT + 0.3,
                minX: 0,
                maxX: maxX,

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: TTCTheme.cardBBT,
                    barWidth: 3,
                    isStrokeCapRound: true,

                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isLast = index == spots.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 6 : 3,
                          color: Colors.white,
                          strokeWidth: isLast ? 3 : 2,
                          strokeColor: TTCTheme.cardBBT,
                        );
                      },
                    ),

                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          TTCTheme.cardBBT.withOpacity(0.25),
                          TTCTheme.cardBBT.withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],

                // 🔥 ИСПРАВЛЕНИЕ ЗДЕСЬ: Используем tooltipBgColor
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87, // Старый параметр
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "${spot.y.toStringAsFixed(1)}°",
                          GoogleFonts.manrope(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}