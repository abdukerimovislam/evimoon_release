import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../l10n/app_localizations.dart'; // ✅ Импорт локализации

// 🧬 PARALLAX BACKGROUND (Без изменений)
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

// 🔥 HOLOGRAPHIC DAY CELL (Без изменений)
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
    final phase = provider.getPhaseForDate(date);
    bool isFrozen = date.isBefore(DateTime(currentCycleStart.year, currentCycleStart.month, currentCycleStart.day));

    Color baseColor = Colors.transparent;
    Color glowColor = Colors.transparent;
    bool isCOCActive = false;

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
        if (isCOCActive) ...[
          if (date.weekday != DateTime.monday)
            Positioned(left: -4, child: _buildLink(baseColor)),
          if (date.weekday != DateTime.sunday)
            Positioned(right: -4, child: _buildLink(baseColor)),
        ],

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

// 💡 NEON MARKER (Без изменений)
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

// 🗺️ LEGEND (ОБНОВЛЕНО: Использует l10n)
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _item(AppColors.menstruation, l10n.legendPeriod),
        _item(AppColors.follicular, l10n.legendFollicular),
        _item(AppColors.ovulation, l10n.legendOvulation),
        _item(AppColors.luteal, l10n.legendLuteal),
      ],
    );
  }

  Widget _item(Color c, String l) => Row(
      children: [
        Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(0.6), blurRadius: 4)])
        ),
        const SizedBox(width: 4),
        Text(l, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary))
      ]
  );
}