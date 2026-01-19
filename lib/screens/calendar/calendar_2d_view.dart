import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_visuals.dart';

class Calendar2DView extends StatelessWidget {
  final AppLocalizations l10n;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final CycleProvider cycleProvider;
  final WellnessProvider wellnessProvider;
  final DateTime currentCycleStart;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const Calendar2DView({
    super.key,
    required this.l10n,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.cycleProvider,
    required this.wellnessProvider,
    required this.currentCycleStart,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, spreadRadius: 0)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TableCalendar(
              locale: l10n.localeName,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              calendarFormat: calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: onDaySelected,
              onFormatChanged: onFormatChanged,
              onPageChanged: onPageChanged,

              // Events
              eventLoader: (day) {
                final log = wellnessProvider.getLogForDate(day);
                List<dynamic> events = [];
                if (wellnessProvider.hasLogForDate(day)) events.add('log');
                if (log.ovulationTest != OvulationTestResult.none) events.add('test');
                return events;
              },

              // Styles
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                weekendStyle: GoogleFonts.inter(color: AppColors.textPrimary.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w600),
              ),
              calendarStyle: const CalendarStyle(outsideDaysVisible: false),

              // Builders
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    final log = wellnessProvider.getLogForDate(date);
                    bool isPeak = log.ovulationTest == OvulationTestResult.peak || log.ovulationTest == OvulationTestResult.positive;
                    bool hasLog = wellnessProvider.hasLogForDate(date);
                    return Positioned(bottom: 6, child: Row(mainAxisSize: MainAxisSize.min, children: [if (hasLog) const NeonMarker(color: Color(0x80333333)), if (isPeak) ...[const SizedBox(width: 2), const NeonMarker(color: TTCTheme.statusTest, isGlow: true)]]));
                  }
                  return null;
                },
                defaultBuilder: (context, day, focusedDay) => HoloDayCell(date: day, provider: cycleProvider, isSelected: false, currentCycleStart: currentCycleStart),
                selectedBuilder: (context, day, focusedDay) => HoloDayCell(date: day, provider: cycleProvider, isSelected: true, currentCycleStart: currentCycleStart),
                todayBuilder: (context, day, focusedDay) => HoloDayCell(date: day, provider: cycleProvider, isSelected: false, isToday: true, currentCycleStart: currentCycleStart),
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary), leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary), rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary)),
            ),
          ),
        ),
      ),
    );
  }
}