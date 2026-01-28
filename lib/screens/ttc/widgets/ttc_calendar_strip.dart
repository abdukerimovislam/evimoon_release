import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class TTCCalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onJumpToToday;

  const TTCCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.today,
    required this.onSelect,
    required this.onJumpToToday,
  });

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedToday = _normalize(today);
    final normalizedSelected = _normalize(selectedDate);

    // 7 дней назад ... сегодня
    final items = List.generate(7, (i) => normalizedToday.subtract(Duration(days: 6 - i)));

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final date = items[index];
            final isSelected = date.isAtSameMomentAs(normalizedSelected);
            final isToday = date.isAtSameMomentAs(normalizedToday);

            final bg = isSelected ? AppColors.primary : Colors.white;
            final border = isSelected ? Colors.transparent : Colors.black.withOpacity(0.06);
            final topTextColor = isSelected ? Colors.white : AppColors.textSecondary;
            final mainTextColor = isSelected ? Colors.white : AppColors.textPrimary;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelect(date),
              onLongPress: isToday ? onJumpToToday : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.10 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 14,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat('EEE', l10n.localeName).format(date).toUpperCase(),
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: topTextColor,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 22,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            date.day.toString(),
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: mainTextColor,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 4,
                      child: AnimatedOpacity(
                        opacity: isToday ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 4,
                            width: 18,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}