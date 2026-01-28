import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';
import '../../../providers/cycle_provider.dart'; // FertilityChance
import '../../../models/cycle_model.dart'; // CyclePhase

class TTCFertilityTimelineCard extends StatelessWidget {
  final DateTime selected;
  final DateTime cycleStart;
  final int ovulationDay;
  final CyclePhase? Function(DateTime) getPhaseForDate;
  final ValueChanged<DateTime> onSelectDate;
  final int Function(DateTime, DateTime) dayInCycleFor;
  final FertilityChance Function({
  required int dayInCycle,
  required int ovulationDay,
  required CyclePhase phase,
  }) chanceForDay;
  final AppLocalizations l10n;

  const TTCFertilityTimelineCard({
    super.key,
    required this.selected,
    required this.cycleStart,
    required this.ovulationDay,
    required this.getPhaseForDate,
    required this.onSelectDate,
    required this.dayInCycleFor,
    required this.chanceForDay,
    required this.l10n,
  });

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Color _colorForChance(FertilityChance c) {
    switch (c) {
      case FertilityChance.low: return Colors.black.withOpacity(0.14);
      case FertilityChance.high: return TTCTheme.statusHigh.withOpacity(0.55);
      case FertilityChance.peak: return TTCTheme.statusPeak.withOpacity(0.70);
    }
  }

  double _barHeight(FertilityChance c) {
    switch (c) {
      case FertilityChance.low: return 10;
      case FertilityChance.high: return 16;
      case FertilityChance.peak: return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _normalize(selected);
    final dates = List.generate(14, (i) => center.add(Duration(days: i - 6)));

    final titleStyle = GoogleFonts.manrope(
      fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary,
    );
    final hintStyle = GoogleFonts.manrope(
      fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary.withOpacity(0.75), height: 1.2,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.ttcTimelineTitle, style: titleStyle),
              const Spacer(),
              Text(l10n.ttcTimelineOvulationEquals(ovulationDay), style: hintStyle),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final d = _normalize(dates[index]);
                final isSelected = d.isAtSameMomentAs(center);
                final phase = getPhaseForDate(d) ?? CyclePhase.follicular;
                final dayInCycle = dayInCycleFor(d, cycleStart);
                final chance = chanceForDay(
                  dayInCycle: dayInCycle, ovulationDay: ovulationDay, phase: phase,
                );
                final barColor = _colorForChance(chance);
                final barH = _barHeight(chance);

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelectDate(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.primary.withOpacity(0.25) : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final compact = c.maxWidth <= 36 || c.maxHeight <= 52;
                        final topH = compact ? 0.0 : 12.0;
                        final gap1 = compact ? 0.0 : 4.0;
                        const barBoxH = 24.0;
                        const bottomH = 14.0;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!compact) SizedBox(
                              height: topH,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    DateFormat('E', l10n.localeName).format(d).toUpperCase(),
                                    style: GoogleFonts.manrope(
                                      fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!compact) SizedBox(height: gap1),
                            SizedBox(
                              height: barBoxH,
                              child: Align(
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  height: barH,
                                  width: 10,
                                  decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(999)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: bottomH,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    d.day.toString(),
                                    style: GoogleFonts.manrope(
                                      fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 🔥 ИСПРАВЛЕНИЕ: Wrap вместо Row для переноса текста легенды
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: Colors.black.withOpacity(0.18)),
                  const SizedBox(width: 6),
                  Text(l10n.ttcStatusLow, style: hintStyle),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: TTCTheme.statusHigh.withOpacity(0.65)),
                  const SizedBox(width: 6),
                  Text(l10n.ttcStatusHigh, style: hintStyle),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendDot(color: TTCTheme.statusPeak.withOpacity(0.75)),
                  const SizedBox(width: 6),
                  Text(l10n.ttcStatusPeak, style: hintStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
    height: 10, width: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}