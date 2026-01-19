import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../l10n/app_localizations.dart';

// Импорт виджетов
import 'insights/widgets/dna_comparison.dart';
import 'insights/widgets/liquid_mood_chart.dart';
import 'insights/widgets/neural_radar.dart';

// 🔥 Импорт фона (как в календаре/логе)
import 'calendar/calendar_visuals.dart'; // Берем ParallaxBackground отсюда

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Для параллакса фона
  final ScrollController _scrollController = ScrollController();
  double _bgOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Простой эффект параллакса при скролле
    setState(() {
      _bgOffset = (_scrollController.offset / 1000).clamp(-1.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context);
    final wellnessProvider = Provider.of<WellnessProvider>(context);

    final radarData = wellnessProvider.calculateRadarData(cycleProvider);
    final fValues = radarData['follicular'] ?? [0,0,0,0,0];
    final lValues = radarData['luteal'] ?? [0,0,0,0,0];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
            l10n.tabInsights,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.textPrimary)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // 1. ЖИВОЙ ФОН
          ParallaxBackground(offset: _bgOffset, isDark: false),

          // 2. КОНТЕНТ
          SafeArea(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. NEURAL RADAR (Баланс)
                NeuralRadarChart(
                  fValues: fValues,
                  lValues: lValues,
                  l10n: l10n,
                ),

                const SizedBox(height: 20),

                // 2. LIQUID MOOD (Настроение)
                LiquidMoodChart(
                  wellness: wellnessProvider,
                  l10n: l10n,
                ),

                const SizedBox(height: 20),

                // 3. DNA HELIX (Сравнение фаз)
                DnaComparisonCard(
                  fValues: fValues,
                  lValues: lValues,
                  l10n: l10n,
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}