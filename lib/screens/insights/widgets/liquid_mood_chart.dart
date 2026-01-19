import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/wellness_provider.dart';
import '../../../l10n/app_localizations.dart';

class LiquidMoodChart extends StatelessWidget {
  final WellnessProvider wellness;
  final AppLocalizations l10n;

  const LiquidMoodChart({super.key, required this.wellness, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final moodValues = wellness.calculateWaveData();
    List<FlSpot> spots = [];
    for (int i = 0; i < moodValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), moodValues[i]));
    }

    final List<Color> gradientColors = [Colors.purpleAccent, Colors.blueAccent, Colors.tealAccent];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.insightMoodFlow, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(l10n.insightMoodFlowSub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (moodValues.length - 1).toDouble(),
                minY: 1,
                maxY: 5.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.45,
                    gradient: LinearGradient(colors: gradientColors),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: gradientColors.map((color) => color.withOpacity(0.2)).toList())),
                  ),
                ],
                lineTouchData: LineTouchData(
                  // 🔥 ИСПРАВЛЕНО: tooltipBgColor вместо getTooltipColor
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white.withOpacity(0.9),
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          _getMoodEmoji(barSpot.y),
                          const TextStyle(fontSize: 24),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: AppColors.primary, strokeWidth: 2, dashArray: [4, 4]),
                        FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.white, strokeWidth: 3, strokeColor: AppColors.primary)),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(double val) {
    if (val >= 4.5) return "🤩";
    if (val >= 3.5) return "🙂";
    if (val >= 2.5) return "😐";
    if (val >= 1.5) return "😟";
    return "😭";
  }
}