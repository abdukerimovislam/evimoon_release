import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';
import '../../models/cycle_model.dart';
import '../../models/personal_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';

import 'widgets/ttc_chart_widget.dart';
import 'widgets/ttc_modals.dart';

class TTCHomeScreen extends StatefulWidget {
  const TTCHomeScreen({super.key});

  @override
  State<TTCHomeScreen> createState() => _TTCHomeScreenState();
}

class _TTCHomeScreenState extends State<TTCHomeScreen> {

  void _openModal(Widget content) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, barrierColor: Colors.black.withOpacity(0.2), builder: (context) => content);
  }

  String? _getTestValue(OvulationTestResult r, AppLocalizations l) {
    if (r == OvulationTestResult.positive) return l.valPositive;
    if (r == OvulationTestResult.peak) return l.valPeak;
    if (r == OvulationTestResult.negative) return l.valNegative;
    return null;
  }

  String? _getMucusValue(CervicalMucusType t, AppLocalizations l) {
    if (t == CervicalMucusType.none) return null;
    return l.valMucusLogged;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final wellness = context.watch<WellnessProvider>();
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final todayLog = wellness.getLogForDate(now);
    final data = cycle.currentData;
    final temps = wellness.getLast14DaysTemps();

    double fertilityScore = 0.15;
    String statusText = l10n.ttcChanceLow;

    if (cycle.conceptionChance == FertilityChance.high) {
      fertilityScore = 0.65;
      statusText = l10n.ttcChanceHigh;
    }
    if (cycle.conceptionChance == FertilityChance.peak) {
      fertilityScore = 1.0;
      statusText = l10n.ttcChancePeak;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              _buildCalendarStrip(now),

              const SizedBox(height: 20),

              // 🔥 ПЕРЕКЛЮЧАТЕЛЬ ЗДЕСЬ ТОЖЕ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ModeSwitcher(isTTC: true), // Виджет ниже
              ),

              const SizedBox(height: 30),

              _buildMainGauge(fertilityScore, data.currentDay, statusText, l10n),

              const SizedBox(height: 40),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _Tile(
                    icon: Icons.thermostat_rounded,
                    title: l10n.lblTemp,
                    value: (todayLog.temperature != null && todayLog.temperature! > 0) ? l10n.valMeasured(todayLog.temperature!) : null,
                    color: TTCTheme.cardBBT,
                    onTap: () => _openModal(BBTModal(date: now)),
                  ),
                  _Tile(
                    icon: Icons.water_drop_outlined,
                    title: l10n.lblTest,
                    value: _getTestValue(todayLog.ovulationTest, l10n),
                    color: TTCTheme.cardTest,
                    onTap: () => _openModal(TestModal(date: now)),
                  ),
                  _Tile(
                    icon: Icons.favorite_rounded,
                    title: l10n.lblSex,
                    value: todayLog.hadSex ? l10n.valSexYes : null,
                    color: TTCTheme.cardSex,
                    onTap: () => _openModal(SexModal(date: now)),
                  ),
                  _Tile(
                    icon: Icons.spa_outlined,
                    title: l10n.lblMucus,
                    value: _getMucusValue(todayLog.mucus, l10n),
                    color: Colors.blueAccent,
                    onTap: () => _openModal(MucusModal(date: now)),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              TTCChartWidget(temps: temps),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(DateTime now) {
    final start = now.subtract(const Duration(days: 6));
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final date = start.add(Duration(days: index));
          final isToday = index == 6;
          return Container(
            width: 42,
            decoration: BoxDecoration(color: isToday ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(14), border: isToday ? null : Border.all(color: Colors.grey.withOpacity(0.1))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('E').format(date).substring(0, 1), style: TextStyle(fontSize: 10, color: isToday ? Colors.white60 : Colors.grey)), Text(date.day.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black87))]),
          );
        }),
      ),
    );
  }

  Widget _buildMainGauge(double score, int day, String status, AppLocalizations l10n) {
    return Column(children: [SizedBox(height: 220, width: 300, child: CustomPaint(painter: _ArcPainter(score: score), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 30), Text("${(score * 100).toInt()}%", style: GoogleFonts.manrope(fontSize: 60, fontWeight: FontWeight.w300, color: AppColors.textPrimary, height: 1)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.textPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), child: Text(l10n.ttcCycleDay(day).toUpperCase(), style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1.0)))])),), Transform.translate(offset: const Offset(0, -10), child: Text(status, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)))]);
  }
}

// Дубликат виджета переключателя (чтобы не было импортов через весь проект)
class _ModeSwitcher extends StatelessWidget {
  final bool isTTC;
  const _ModeSwitcher({required this.isTTC});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { if (isTTC) { HapticFeedback.selectionClick(); context.read<CycleProvider>().setTTCMode(false); } },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(color: !isTTC ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: !isTTC ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : []),
                alignment: Alignment.center,
                child: Text("Track Cycle", style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: !isTTC ? Colors.black : Colors.grey, fontSize: 14)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () { if (!isTTC) { HapticFeedback.selectionClick(); context.read<CycleProvider>().setTTCMode(true); } },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(color: isTTC ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: isTTC ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : []),
                alignment: Alignment.center,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Get Pregnant", style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: isTTC ? AppColors.primary : Colors.grey, fontSize: 14)), if (isTTC) ...[const SizedBox(width: 4), const Icon(Icons.auto_awesome, size: 14, color: Colors.amber)]]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Дубликаты плиток и пейнтера (для автономности файла)
class _Tile extends StatelessWidget {
  final IconData icon; final String title; final String? value; final Color color; final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, this.value, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: hasValue ? color : Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: hasValue ? color.withOpacity(0.4) : Colors.black.withOpacity(0.03), blurRadius: hasValue ? 20 : 15, offset: const Offset(0, 8))], border: hasValue ? null : Border.all(color: Colors.grey.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: hasValue ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: hasValue ? Colors.white : color, size: 22)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: hasValue ? Colors.white.withOpacity(0.8) : Colors.grey)), const SizedBox(height: 4), AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(value ?? "—", key: ValueKey(value), style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: hasValue ? Colors.white : AppColors.textPrimary)))] )])));
  }
}

class _ArcPainter extends CustomPainter {
  final double score; _ArcPainter({required this.score});
  @override void paint(Canvas canvas, Size size) { final center = Offset(size.width / 2, size.height * 0.75); final radius = size.width * 0.42; const startAngle = -math.pi * 1.25; const sweepAngle = math.pi * 1.5; final bgPaint = Paint()..color = Colors.grey[200]!..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = 16; canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint); final gradient = SweepGradient(startAngle: startAngle, endAngle: startAngle + sweepAngle, colors: const [Color(0xFFFFE0B2), TTCTheme.primaryGold, Color(0xFFFF6F00)], stops: const [0.0, 0.5, 1.0], transform: GradientRotation(startAngle - 0.2)); final activePaint = Paint()..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = 16; canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * score, false, activePaint); }
  @override bool shouldRepaint(covariant _ArcPainter oldDelegate) => oldDelegate.score != score;
}