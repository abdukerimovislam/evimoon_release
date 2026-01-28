import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart'; // Если используется для TTC
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../l10n/app_localizations.dart';

// 🧬 PARALLAX BACKGROUND
class ParallaxBackground extends StatelessWidget {
  final double offset;
  final bool isDark;

  const ParallaxBackground({super.key, required this.offset, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(offset, -1.0),
          end: Alignment(-offset, 1.0),
          colors: isDark ? [
            const Color(0xFF2D1E40),
            const Color(0xFF1A237E),
            const Color(0xFF311B92),
          ] : [
            const Color(0xFFFEE1E8),
            const Color(0xFFE3F2FD),
            const Color(0xFFF3E5F5),
          ],
        ),
      ),
    );
  }
}

// 🔥 HOLOGRAPHIC DAY CELL
class HoloDayCell extends StatelessWidget {
  final DateTime date;
  final CycleProvider provider;
  final bool isSelected;
  final bool isToday;
  final DateTime currentCycleStart;

  const HoloDayCell({
    super.key,
    required this.date,
    required this.provider,
    required this.isSelected,
    required this.currentCycleStart,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем фазу
    final phase = provider.getPhaseForDate(date);

    // Проверка на "замороженные" дни (до начала текущего отслеживания)
    // Можно убрать, если хотите показывать историю полностью
    bool isFrozen = false;
    // bool isFrozen = date.isBefore(DateTime(currentCycleStart.year, currentCycleStart.month, currentCycleStart.day));

    Color baseColor = Colors.transparent;
    Color glowColor = Colors.transparent;
    bool isCOCActive = false;

    // ЛОГИКА ЦВЕТОВ
    if (phase != null) {
      if (provider.isCOCEnabled) {
        if (phase == CyclePhase.follicular) {
          isCOCActive = true;
          baseColor = isFrozen ? Colors.cyan.withOpacity(0.3) : AppColors.follicular;
        } else {
          baseColor = AppColors.menstruation;
        }
      } else {
        if (isFrozen) {
          baseColor = Colors.cyan.withOpacity(0.15);
        } else {
          switch (phase) {
            case CyclePhase.menstruation: baseColor = AppColors.menstruation; break;
            case CyclePhase.follicular: baseColor = AppColors.follicular; break;
            case CyclePhase.ovulation: baseColor = AppColors.ovulation; break;
            case CyclePhase.luteal: baseColor = AppColors.luteal; break;
            default: baseColor = Colors.grey;
          }
        }
      }
    }

    if (isSelected) {
      glowColor = baseColor == Colors.transparent ? AppColors.primary : baseColor;
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Соединительные линии для КОК (таблеток)
        if (isCOCActive) ...[
          if (date.weekday != DateTime.monday)
            Positioned(left: -4, child: _buildLink(baseColor)),
          if (date.weekday != DateTime.sunday)
            Positioned(right: -4, child: _buildLink(baseColor)),
        ],

        // Основной кружок дня
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: baseColor != Colors.transparent
                ? baseColor.withOpacity(isSelected ? 0.6 : (isFrozen ? 0.2 : 0.15))
                : (isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent),
            border: isSelected
                ? Border.all(color: glowColor, width: 2)
                : (isToday ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1) : null),
            boxShadow: isSelected
                ? [BoxShadow(color: glowColor.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)]
                : (isCOCActive && !isFrozen ? [BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 5)] : []),
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: GoogleFonts.inter(
              color: isFrozen ? AppColors.textSecondary : AppColors.textPrimary,
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLink(Color color) {
    return Container(
        width: 10, height: 2,
        decoration: BoxDecoration(
            color: color.withOpacity(0.6),
            boxShadow: [BoxShadow(color: color, blurRadius: 4)]
        )
    );
  }
}

// 💡 NEON MARKER
class NeonMarker extends StatelessWidget {
  final Color color;
  final bool isGlow;
  const NeonMarker({super.key, required this.color, this.isGlow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isGlow ? 6 : 4,
      height: isGlow ? 6 : 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: isGlow ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 6, spreadRadius: 2)] : [],
      ),
    );
  }
}

// 🗺️ LEGEND (ОБНОВЛЕННАЯ PREMIUM ВЕРСИЯ)
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          // 🩸 Месячные
          _LegendItem(
            color: AppColors.menstruation,
            label: l10n.legendPeriod,
          ),

          // 🔮 Прогноз
          _LegendItem(
            color: AppColors.menstruation.withOpacity(0.3),
            label: l10n.legendPredictedPeriod,
            isBordered: true,
          ),

          // 🌸 Фертильность
          _LegendItem(
            color: AppColors.ovulation,
            label: l10n.legendFertile,
          ),

          // 🥚 Овуляция (Кольцо)
          _LegendItem(
            color: Colors.transparent,
            borderColor: AppColors.ovulation,
            label: l10n.legendOvulation,
            isRing: true,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isBordered;
  final bool isRing;
  final Color? borderColor;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isBordered = false,
    this.isRing = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRing ? Colors.transparent : color,
            border: isRing
                ? Border.all(color: borderColor ?? color, width: 2)
                : (isBordered ? Border.all(color: color.withOpacity(1.0), width: 1) : null),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}