import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../widgets/vision_card.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../l10n/app_localizations.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context);
    final wellnessProvider = Provider.of<WellnessProvider>(context);

    final correlations = wellnessProvider.analyzeCorrelations();
    final radarData = wellnessProvider.calculateRadarData(cycleProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.tabInsights, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [

          // 1. УМНЫЕ ПАТТЕРНЫ
          if (correlations.isNotEmpty) ...[
            Text(l10n.insightCorrelationTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(l10n.insightCorrelationSub, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 15),

            ...correlations.map((item) => _CorrelationCard(
                factor: item['factor'],
                symptom: item['symptom'],
                percent: item['probability'],
                l10n: l10n
            )),

            const SizedBox(height: 30),
          ],

          // 2. CYCLE DNA (✅ Исправлено: убран aspectRatio)
          _ChartCard(
            title: l10n.insightCycleDNA,
            subtitle: l10n.insightDNASub,
            aspectRatio: null, // 🔥 Важно: разрешаем карточке растягиваться по высоте
            child: _CycleDNAWidget(
              fValues: radarData['follicular']!,
              lValues: radarData['luteal']!,
              l10n: l10n,
            ),
          ),

          const SizedBox(height: 20),

          // 3. РАДАР (Графикам нужен aspectRatio)
          _ChartCard(
            title: l10n.insightBodyBalance,
            subtitle: l10n.insightBodyBalanceSub,
            aspectRatio: 1.2,
            child: _HolographicRadarChart(
                fValues: radarData['follicular']!,
                lValues: radarData['luteal']!,
                l10n: l10n
            ),
          ),

          const SizedBox(height: 20),

          // 4. ВОЛНА
          _ChartCard(
            title: l10n.insightMoodFlow,
            subtitle: l10n.insightMoodFlowSub,
            aspectRatio: 1.6,
            child: _NeonWaveChart(wellness: wellnessProvider),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// --- ВИДЖЕТЫ ---

// ✅ ИСПРАВЛЕННЫЙ _ChartCard
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double? aspectRatio; // 🔥 Сделали nullable

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.aspectRatio = 1.3 // Дефолтное значение, если не передано
  });

  @override
  Widget build(BuildContext context) {
    return VisionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(subtitle, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          // 🔥 Логика: если aspectRatio есть - используем, если null - просто child
          if (aspectRatio != null)
            AspectRatio(aspectRatio: aspectRatio!, child: child)
          else
            child,
        ],
      ),
    );
  }
}

// ... ОСТАЛЬНЫЕ ВИДЖЕТЫ (_CorrelationCard, _CycleDNAWidget, _HolographicRadarChart, _NeonWaveChart, _DNAByt, _WinBadge) ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ (скопируйте их из прошлого ответа) ...
class _CorrelationCard extends StatelessWidget {
  final String factor;
  final String symptom;
  final int percent;
  final AppLocalizations l10n;
  const _CorrelationCard({required this.factor, required this.symptom, required this.percent, required this.l10n});
  @override
  Widget build(BuildContext context) {
    return VisionCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 15),
      color: percent > 70 ? Colors.redAccent.withOpacity(0.05) : Colors.white.withOpacity(0.6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.insights, color: Colors.redAccent),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(style: const TextStyle(color: AppColors.textPrimary, fontSize: 16), children: [const TextSpan(text: "When you log "), TextSpan(text: factor, style: const TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: ", you get "), TextSpan(text: symptom, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)), const TextSpan(text: "...")])),
                const SizedBox(height: 8),
                Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percent / 100, minHeight: 6, backgroundColor: Colors.grey[200], color: percent > 70 ? Colors.red : Colors.orange))), const SizedBox(width: 10), Text("$percent%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))])
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 🔥 WIDGET: CYCLE DNA (Улучшенная версия) ---
class _CycleDNAWidget extends StatelessWidget {
  final List<double> fValues; // [Mood, Energy, Sleep, Libido, Skin]
  final List<double> lValues;
  final AppLocalizations l10n;

  const _CycleDNAWidget({required this.fValues, required this.lValues, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Легенда
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PhaseLegend(label: l10n.lblFollicular, color: Colors.blueAccent),
            Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10)),
            _PhaseLegend(label: l10n.lblLuteal, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 20),

        // Полосы сравнения
        // Индексы: 0:Mood, 1:Energy, 2:Sleep, 3:Libido, 4:Skin
        _DNABar(
          label: l10n.paramEnergy,
          fVal: fValues[1],
          lVal: lValues[1],
          icon: Icons.bolt,
        ),
        _DNABar(
          label: l10n.logMood,
          fVal: fValues[0],
          lVal: lValues[0],
          icon: Icons.mood,
        ),
        _DNABar(
          label: l10n.paramLibido,
          fVal: fValues[3],
          lVal: lValues[3],
          icon: Icons.favorite,
        ),
      ],
    );
  }
}

class _PhaseLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _PhaseLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _DNABar extends StatelessWidget {
  final String label;
  final double fVal;
  final double lVal;
  final IconData icon;

  const _DNABar({
    required this.label,
    required this.fVal,
    required this.lVal,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Считаем пропорции для полоски (сумма = 100%)
    double total = fVal + lVal;
    if (total == 0) total = 1; // Защита от деления на 0

    final double fPercent = fVal / total;
    final double lPercent = lVal / total;

    // 2. Кто побеждает?
    bool fWins = fVal >= lVal;
    double diffPercent = ((fVal - lVal).abs() / ((fVal + lVal) / 2)) * 100;

    // Текст вывода (Например: "Higher in Follicular (+15%)")
    String resultText = diffPercent < 5
        ? "Equal balance"
        : "${fWins ? "Higher" : "Higher"} in ${fWins ? "Follicular" : "Luteal"} (+${diffPercent.toInt()}%)";

    Color winnerColor = fWins ? Colors.blueAccent : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и Иконка
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              const Spacer(),
              // Маленький вывод справа
              Text(
                  resultText,
                  style: TextStyle(fontSize: 10, color: winnerColor, fontWeight: FontWeight.w600)
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 📊 ВИЗУАЛЬНАЯ ПОЛОСА (Battle Bar)
          SizedBox(
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  // Синяя часть (Фолликулярная)
                  Flexible(
                    flex: (fPercent * 100).toInt(),
                    child: Container(color: Colors.blueAccent.withOpacity(fWins ? 1.0 : 0.4)),
                  ),
                  // Разделитель (белая черта)
                  Container(width: 2, color: Colors.white),
                  // Розовая часть (Лютеиновая)
                  Flexible(
                    flex: (lPercent * 100).toInt(),
                    child: Container(color: AppColors.primary.withOpacity(!fWins ? 1.0 : 0.4)),
                  ),
                ],
              ),
            ),
          ),

          // Подписи цифр снизу (опционально, для точности)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fVal.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: fWins ? Colors.blueAccent : Colors.grey)),
                Text(lVal.toStringAsFixed(1), style: TextStyle(fontSize: 10, color: !fWins ? AppColors.primary : Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
class _DNAByt extends StatelessWidget {
  final String label; final double fVal; final double lVal; final IconData icon;
  const _DNAByt({required this.label, required this.fVal, required this.lVal, required this.icon});
  @override
  Widget build(BuildContext context) {
    bool fWins = fVal >= lVal;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Expanded(child: Align(alignment: Alignment.centerLeft, child: fWins ? _WinBadge(val: fVal, color: Colors.blueAccent) : Text(fVal.toStringAsFixed(1), style: const TextStyle(color: Colors.grey)))), SizedBox(width: 100, child: Column(children: [Icon(icon, size: 16, color: AppColors.textSecondary), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))])), Expanded(child: Align(alignment: Alignment.centerRight, child: !fWins ? _WinBadge(val: lVal, color: AppColors.primary) : Text(lVal.toStringAsFixed(1), style: const TextStyle(color: Colors.grey))))]),
    );
  }
}

class _WinBadge extends StatelessWidget {
  final double val; final Color color;
  const _WinBadge({required this.val, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(val.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: color)));
  }
}

class _HolographicRadarChart extends StatelessWidget {
  final List<double> fValues; final List<double> lValues; final AppLocalizations l10n;
  const _HolographicRadarChart({required this.fValues, required this.lValues, required this.l10n});
  @override
  Widget build(BuildContext context) {
    final fEntries = fValues.map((v) => RadarEntry(value: v)).toList();
    final lEntries = lValues.map((v) => RadarEntry(value: v)).toList();
    return RadarChart(RadarChartData(radarTouchData: RadarTouchData(enabled: false), tickCount: 1, borderData: FlBorderData(show: false), gridBorderData: BorderSide(color: AppColors.textSecondary.withOpacity(0.1), width: 1), titlePositionPercentageOffset: 0.1, titleTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold), getTitle: (index, angle) { switch (index) { case 0: return RadarChartTitle(text: l10n.logMood); case 1: return RadarChartTitle(text: l10n.paramEnergy); case 2: return RadarChartTitle(text: l10n.logSleep); case 3: return RadarChartTitle(text: l10n.paramLibido); case 4: return RadarChartTitle(text: l10n.paramSkin); default: return const RadarChartTitle(text: ''); } }, dataSets: [RadarDataSet(fillColor: Colors.blueAccent.withOpacity(0.25), borderColor: Colors.blueAccent, entryRadius: 2, dataEntries: fEntries, borderWidth: 2), RadarDataSet(fillColor: AppColors.primary.withOpacity(0.25), borderColor: AppColors.primary, entryRadius: 2, dataEntries: lEntries, borderWidth: 2)]));
  }
}

class _NeonWaveChart extends StatelessWidget {
  final WellnessProvider wellness;
  const _NeonWaveChart({required this.wellness});
  @override
  Widget build(BuildContext context) {
    final moodValues = wellness.calculateWaveData();
    List<FlSpot> spots = [];
    for (int i = 0; i < moodValues.length; i++) { spots.add(FlSpot(i.toDouble(), moodValues[i])); }
    return LineChart(LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false), minY: 1, maxY: 5.5, lineBarsData: [LineChartBarData(spots: spots, isCurved: true, curveSmoothness: 0.5, gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent, Colors.orangeAccent]), barWidth: 4, isStrokeCapRound: true, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.purpleAccent.withOpacity(0.25), Colors.transparent])))]));
  }
}