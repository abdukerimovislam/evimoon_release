import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Импорты (пути правильные, так как файл в widgets/)
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

    double minT = 36.0;
    double maxT = 37.5;

    for (int i = 0; i < temps.length; i++) {
      if (temps[i] != null && temps[i]! > 0) {
        final val = temps[i]!;
        spots.add(FlSpot(i.toDouble(), val));

        if (val < minT) minT = val;
        if (val > maxT) maxT = val;
      }
    }

    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  l10n.ttcChartTitle,
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary
                  )
              ),
              if (spots.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: TTCTheme.cardBBT.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(
                    "${spots.last.y}°",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TTCTheme.cardBBT,
                        fontSize: 12
                    ),
                  ),
                )
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: spots.isEmpty
                ? Center(
                child: Text(
                    l10n.ttcChartPlaceholder,
                    style: TextStyle(color: Colors.grey[400])
                )
            )
                : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey[100],
                      strokeWidth: 1
                  ),
                ),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: minT - 0.2,
                maxY: maxT + 0.2,
                minX: 0,
                maxX: 13,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    // 🔥 ИСПРАВЛЕНИЕ 1: color вместо colors
                    color: TTCTheme.cardBBT,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isLast = index == spots.length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 6 : 4,
                          color: Colors.white,
                          strokeWidth: isLast ? 3 : 2,
                          strokeColor: TTCTheme.cardBBT,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      // 🔥 ИСПРАВЛЕНИЕ 2: gradient вместо colors
                      gradient: LinearGradient(
                        colors: [
                          TTCTheme.cardBBT.withOpacity(0.2),
                          TTCTheme.cardBBT.withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // Параметр для цвета фона тултипа
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "${spot.y}°",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}