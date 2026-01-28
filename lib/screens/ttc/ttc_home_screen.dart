import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cycle_model.dart';
import '../../models/personal_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../providers/settings_provider.dart'; // 🔥 Не забудьте этот импорт
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';

import 'widgets/ttc_chart_widget.dart';
import 'widgets/ttc_modals.dart';

// Импорт виджетов
import 'widgets/ttc_gauge_card.dart';
import 'widgets/ttc_calendar_strip.dart';
import 'widgets/ttc_timeline_card.dart';
import 'widgets/ttc_log_card.dart';
import 'widgets/ttc_info_cards.dart';
import 'widgets/ttc_cta_card.dart';
import 'widgets/ttc_quick_actions.dart';
import '../../widgets/mode_switcher.dart'; // 🔥 Импорт переключателя

class TTCHomeScreen extends StatefulWidget {
  const TTCHomeScreen({super.key});

  @override
  State<TTCHomeScreen> createState() => _TTCHomeScreenState();
}

class _TTCHomeScreenState extends State<TTCHomeScreen> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  void _setSelectedDate(DateTime d) {
    final nd = _normalize(d);
    if (_normalize(_selectedDate).isAtSameMomentAs(nd)) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedDate = nd);
  }

  void _openModal(Widget content) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: content,
        ),
      ),
    );
  }

  int _dayInCycleFor(DateTime date, DateTime cycleStart) {
    final d = _normalize(date);
    final s = _normalize(cycleStart);
    final diff = d.difference(s).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  FertilityChance _chanceForDay({
    required int dayInCycle,
    required int ovulationDay,
    required CyclePhase phase,
  }) {
    if (phase == CyclePhase.menstruation && dayInCycle <= 5) {
      return FertilityChance.low;
    }
    if (dayInCycle == ovulationDay || dayInCycle == ovulationDay - 1) {
      return FertilityChance.peak;
    }
    if (dayInCycle >= ovulationDay - 5 && dayInCycle < ovulationDay - 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  double _scoreForChance(FertilityChance c) {
    switch (c) {
      case FertilityChance.low: return 0.18;
      case FertilityChance.high: return 0.65;
      case FertilityChance.peak: return 1.0;
    }
  }

  String _phaseTitle(CyclePhase? phase, AppLocalizations l10n) {
    switch (phase) {
      case CyclePhase.menstruation: return l10n.phaseMenstruation;
      case CyclePhase.follicular: return l10n.phaseFollicular;
      case CyclePhase.ovulation: return l10n.phaseOvulation;
      case CyclePhase.luteal: return l10n.phaseLuteal;
      case CyclePhase.late: return l10n.phaseLate;
      default: return '';
    }
  }

  String _ovulationBadgeText(CycleProvider cycle, AppLocalizations l10n) {
    if (!cycle.isOvulationConfirmed) {
      return l10n.ttcOvulationEstimatedCalendar;
    }
    return l10n.ttcOvulationConfirmedManual;
  }

  TTCCTAData _buildCTAData({
    required AppLocalizations l10n,
    required CyclePhase phase,
    required FertilityChance chance,
    required int dayInCycle,
    required int ovulationDay,
    required int? dpo,
    required SymptomLog log,
  }) {
    final doneBBT = (log.temperature != null && (log.temperature ?? 0) > 0);
    final doneLH = (log.ovulationTest != OvulationTestResult.none);
    final doneSex = log.hadSex;

    String shortBBT() => l10n.ttcShortBBT;
    String shortLH() => l10n.ttcShortLH;
    String shortSex() => l10n.ttcShortSex;

    if (dpo != null && dpo > 0) {
      if (dpo >= 10) {
        return TTCCTAData(
          icon: Icons.science_rounded,
          title: l10n.ttcTestReady,
          body: l10n.ttcCtaTestReadyBody(
            dpo,
            doneBBT ? l10n.ttcMarkDone : l10n.ttcMarkMissing,
            doneLH ? l10n.ttcMarkDone : l10n.ttcMarkMissing,
          ),
          tone: TTCCTATone.strong,
        );
      }
      final left = (10 - dpo).clamp(1, 10);
      return TTCCTAData(
        icon: Icons.hourglass_bottom_rounded,
        title: l10n.ttcTestWait,
        body: l10n.ttcCtaTestWaitBody(dpo, left),
        tone: TTCCTATone.soft,
      );
    }

    if (chance == FertilityChance.peak) {
      return TTCCTAData(
        icon: Icons.auto_awesome_rounded,
        title: l10n.ttcStatusPeak,
        body: l10n.ttcCtaPeakBody,
        tone: TTCCTATone.strong,
      );
    }

    if (chance == FertilityChance.high) {
      final left = (ovulationDay - dayInCycle).clamp(1, 7);
      return TTCCTAData(
        icon: Icons.trending_up_rounded,
        title: l10n.ttcStatusHigh,
        body: l10n.ttcCtaHighBody(left),
        tone: TTCCTATone.medium,
      );
    }

    if (phase == CyclePhase.menstruation) {
      return TTCCTAData(
        icon: Icons.spa_rounded,
        title: l10n.phaseMenstruation,
        body: l10n.ttcCtaMenstruationBody,
        tone: TTCCTATone.soft,
      );
    }

    final missing = <String>[];
    if (!doneBBT) missing.add(shortBBT());
    if (!doneLH) missing.add(shortLH());
    if (!doneSex) missing.add(shortSex());

    final miss = missing.isEmpty
        ? l10n.ttcAllDone
        : l10n.ttcMissingList(missing.take(2).join(', '));

    return TTCCTAData(
      icon: Icons.check_circle_rounded,
      title: l10n.ttcStatusLow,
      body: l10n.ttcCtaLowBody(miss),
      tone: TTCCTATone.soft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycle = context.watch<CycleProvider>();
    final wellness = context.watch<WellnessProvider>();
    final settings = context.watch<SettingsProvider>();

    final selected = _normalize(_selectedDate);
    final today = _normalize(DateTime.now());

    final selectedPhase = cycle.getPhaseForDate(selected) ?? cycle.currentData.phase;
    final dayInCycle = _dayInCycleFor(selected, cycle.currentData.cycleStartDate);
    final ovulationDay = cycle.ovulationDay;

    final chance = _chanceForDay(
      dayInCycle: dayInCycle,
      ovulationDay: ovulationDay,
      phase: selectedPhase,
    );

    String statusTitle;
    switch (chance) {
      case FertilityChance.low: statusTitle = l10n.ttcStatusLow; break;
      case FertilityChance.high: statusTitle = l10n.ttcStatusHigh; break;
      case FertilityChance.peak: statusTitle = l10n.ttcStatusPeak; break;
    }

    final phaseText = _phaseTitle(selectedPhase, l10n);

    // --- ЛОГИКА ФЕРТИЛЬНОСТИ С ЗАЩИТОЙ ---
    double score = _scoreForChance(chance);

    // 1. Проверяем фазу МЕНСТРУАЦИИ
    bool isPeriod = selectedPhase == CyclePhase.menstruation;
    // 2. Считаем "ранним циклом" первые 6 дней
    bool isEarlyCycle = dayInCycle < 6;

    // Защита: Если месячные и начало цикла - принудительно занижаем шанс
    if (isPeriod && isEarlyCycle) {
      score = 0.05;
      statusTitle = l10n.ttcStatusLow;
    }

    final log = wellness.getLogForDate(selected);
    final temps = wellness.getLast14DaysTemps();
    final int? dpo = (dayInCycle > ovulationDay) ? (dayInCycle - ovulationDay) : null;
    final headerDate = DateFormat('d MMMM, EEEE', l10n.localeName).format(selected);

    final ctaData = _buildCTAData(
      l10n: l10n,
      phase: selectedPhase,
      chance: chance,
      dayInCycle: dayInCycle,
      ovulationDay: ovulationDay,
      dpo: dpo,
      log: log,
    );

    final isPeak = !cycle.isCOCEnabled && chance == FertilityChance.peak && !(isPeriod && isEarlyCycle);

    return Scaffold(
      backgroundColor: TTCTheme.background,

      body: Stack(
        children: [
          Positioned(
            top: -120, left: -40, right: -40,
            child: Container(
              height: 410,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.75),
                  radius: 1.15,
                  colors: [
                    TTCTheme.statusPeak.withOpacity(0.22),
                    TTCTheme.statusHigh.withOpacity(0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header (только дата, без переключателя)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.modeTTC,
                              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.1),
                            ),
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: 0.65,
                              child: Text(
                                headerDate,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cycle.isCOCEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.black.withOpacity(0.06)),
                          ),
                          child: Text(
                            l10n.prefCOC,
                            style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),

                TTCCalendarStrip(
                  selectedDate: selected,
                  today: today,
                  onSelect: _setSelectedDate,
                  onJumpToToday: () => _setSelectedDate(today),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 92),
                        children: [

                          // 🔥 ВОТ ОН: Переключатель режимов
                          ModeSwitcher(
                              isTTC: true,
                              isPremium: settings.isPremium,
                              l10n: l10n
                          ),

                          const SizedBox(height: 20),

                          PeakGlowWrapper(
                            enabled: isPeak,
                            controller: _glowController,
                            child: TTCGaugeCard(
                              score: score,
                              centerLabel: phaseText.isNotEmpty ? phaseText : statusTitle,
                              title: statusTitle,
                              subtitle: l10n.lblCycleDay(dayInCycle),
                              dpo: dpo,
                              dpoLabelBuilder: (v) => l10n.ttcDPO(v),
                            ),
                          ),

                          const SizedBox(height: 14),

                          if (!cycle.isCOCEnabled)
                            TTCCTACard(data: ctaData),

                          if (!cycle.isCOCEnabled) const SizedBox(height: 14),

                          if (!cycle.isCOCEnabled)
                            TTCFertilityTimelineCard(
                              selected: selected,
                              cycleStart: cycle.currentData.cycleStartDate,
                              ovulationDay: ovulationDay,
                              getPhaseForDate: cycle.getPhaseForDate,
                              onSelectDate: _setSelectedDate,
                              dayInCycleFor: _dayInCycleFor,
                              chanceForDay: _chanceForDay,
                              l10n: l10n,
                            ),

                          if (!cycle.isCOCEnabled) const SizedBox(height: 14),

                          if (!cycle.isCOCEnabled)
                            TTCInfoCard(
                              title: l10n.ttcOvulationBadgeTitle,
                              value: _ovulationBadgeText(cycle, l10n),
                              icon: Icons.verified_rounded,
                            ),

                          if (!cycle.isCOCEnabled) const SizedBox(height: 14),

                          if (!cycle.isCOCEnabled)
                            TTCStrategyCard(
                              strategy: cycle.ttcStrategy,
                              onChange: (s) => cycle.setTTCStrategy(s),
                            ),

                          if (!cycle.isCOCEnabled) const SizedBox(height: 14),

                          if (dpo != null && dpo > 0) TTCDpoCard(dpo: dpo),

                          if (dpo != null && dpo > 0) const SizedBox(height: 14),

                          TTCQuickLogCard(
                            date: selected,
                            log: log,
                            onBBT: () => _openModal(BBTModal(date: selected)),
                            onTest: () => _openModal(TestModal(date: selected)),
                            onSex: () => _openModal(SexModal(date: selected)),
                            onMucus: () => _openModal(MucusModal(date: selected)),
                          ),

                          const SizedBox(height: 14),

                          TTCChartWidget(temps: temps),

                          const SizedBox(height: 14),

                          TTCTipCard(
                            title: l10n.ttcTipTitle,
                            tip: l10n.ttcTipDefault,
                          ),
                        ],
                      ),

                      if (!cycle.isCOCEnabled)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 12,
                          child: TTCQuickActionsDock(
                            onBBT: () => _openModal(BBTModal(date: selected)),
                            onTest: () => _openModal(TestModal(date: selected)),
                            onSex: () => _openModal(SexModal(date: selected)),
                            onMucus: () => _openModal(MucusModal(date: selected)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}