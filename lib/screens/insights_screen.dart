import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';

// 🔥 Импорт нового фона
import '../widgets/mesh_background.dart';

// Импорт ваших виджетов графиков
// (Убедитесь, что файлы существуют по этим путям)
import 'insights/widgets/dna_comparison.dart';
import 'insights/widgets/liquid_mood_chart.dart';
import 'insights/widgets/neural_radar.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = context.watch<CycleProvider>();
    final wellnessProvider = context.watch<WellnessProvider>();

    // Подготовка данных для графиков
    final radarData = wellnessProvider.calculateRadarData(cycleProvider);
    final fValues = radarData['follicular'] ?? [0, 0, 0, 0, 0];
    final lValues = radarData['luteal'] ?? [0, 0, 0, 0, 0];

    // 🔥 ИСПОЛЬЗУЕМ MESH BACKGROUND
    return MeshCycleBackground(
      phase: cycleProvider.currentData.phase, // Фон меняет цвет в зависимости от фазы
      child: Scaffold(
        backgroundColor: Colors.transparent, // Важно для прозрачности
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            l10n.tabInsights,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          // Bottom: false, чтобы контент красиво уходил под навигацию снизу
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),

              // 1. NEURAL RADAR (Баланс гормонов/состояния)
              NeuralRadarChart(
                fValues: fValues,
                lValues: lValues,
                l10n: l10n,
              ),

              const SizedBox(height: 24),

              // 2. LIQUID MOOD (График настроения)
              LiquidMoodChart(
                wellness: wellnessProvider,
                l10n: l10n,
              ),

              const SizedBox(height: 24),

              // 3. DNA HELIX (Сравнение симптомов по фазам)
              DnaComparisonCard(
                fValues: fValues,
                lValues: lValues,
                l10n: l10n,
              ),

              // Отступ снизу для навигационной панели
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}