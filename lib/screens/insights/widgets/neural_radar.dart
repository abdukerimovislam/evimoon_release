import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class NeuralRadarChart extends StatelessWidget {
  final List<double> fValues;
  final List<double> lValues;
  final AppLocalizations l10n;

  const NeuralRadarChart({
    super.key,
    required this.fValues,
    required this.lValues,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final fEntries = fValues.map((v) => RadarEntry(value: v)).toList();
    final lEntries = lValues.map((v) => RadarEntry(value: v)).toList();

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
          Text(l10n.insightBodyBalance, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(l10n.insightBodyBalanceSub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          AspectRatio(
            aspectRatio: 1.3,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                tickCount: 3, // Больше кругов для "эффекта мишени"
                ticksTextStyle: const TextStyle(color: Colors.transparent), // Скрываем цифры сетки
                gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0: return RadarChartTitle(text: l10n.logMood);
                    case 1: return RadarChartTitle(text: l10n.paramEnergy);
                    case 2: return RadarChartTitle(text: l10n.logSleep);
                    case 3: return RadarChartTitle(text: l10n.paramLibido);
                    case 4: return RadarChartTitle(text: l10n.paramSkin);
                    default: return const RadarChartTitle(text: '');
                  }
                },
                dataSets: [
                  // Follicular (Blue Neural Net)
                  RadarDataSet(
                    fillColor: Colors.blueAccent.withOpacity(0.15),
                    borderColor: Colors.blueAccent.withOpacity(0.8),
                    entryRadius: 3,
                    dataEntries: fEntries,
                    borderWidth: 2,
                  ),
                  // Luteal (Purple Neural Net)
                  RadarDataSet(
                    fillColor: Colors.purpleAccent.withOpacity(0.15),
                    borderColor: Colors.purpleAccent.withOpacity(0.8),
                    entryRadius: 3,
                    dataEntries: lEntries,
                    borderWidth: 2,
                  ),
                ],
              ),
            ),
          ),

          // Custom Legend
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.blueAccent, label: l10n.legendFollicular),
              const SizedBox(width: 20),
              _LegendItem(color: Colors.purpleAccent, label: l10n.legendLuteal),
            ],
          )
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))
      ],
    );
  }
}