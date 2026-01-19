import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';

class TimeTunnelPainter extends CustomPainter {
  final double scrollOffset;
  final CycleProvider provider;
  final WellnessProvider wellnessProvider;
  final DateTime selectedDay;
  final DateTime currentCycleStart;

  TimeTunnelPainter({
    required this.scrollOffset,
    required this.provider,
    required this.wellnessProvider,
    required this.selectedDay,
    required this.currentCycleStart,
  });

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // 🔥 ИСПРАВЛЕННАЯ ЛОГИКА ЦВЕТА
  Color _getPhaseColor(DateTime date) {
    // Нормализуем "Сегодня" для корректного сравнения
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Получаем данные от провайдера
    CyclePhase? phase = provider.getPhaseForDate(date);

    // Проверка: это история?
    bool isFrozen = date.isBefore(DateTime(currentCycleStart.year, currentCycleStart.month, currentCycleStart.day));
    // Проверка: это будущее?
    bool isFuture = date.isAfter(today);

    // 2. УДАЛЕНО CyclePhase.none
    // Логика: Если фазы нет (null) ИЛИ (фаза "Задержка" и мы смотрим в будущее) -> СЧИТАЕМ ПРОГНОЗ
    if (!isFrozen && (phase == null || (phase == CyclePhase.late && isFuture))) {
      phase = _predictFuturePhase(date);
    }

    // Если после всех попыток фаза неизвестна - серый
    if (phase == null) return Colors.grey.withOpacity(0.3);

    // 3. Возвращаем цвет
    if (provider.isCOCEnabled) {
      // КОК Режим
      if (phase == CyclePhase.follicular || phase == CyclePhase.ovulation || phase == CyclePhase.luteal) {
        return isFrozen ? Colors.cyan.withOpacity(0.5) : AppColors.follicular;
      } else {
        return AppColors.menstruation;
      }
    } else {
      // Обычный режим
      if (isFrozen) return Colors.cyan.withOpacity(0.3); // История - лед

      switch (phase) {
        case CyclePhase.menstruation: return AppColors.menstruation;
        case CyclePhase.follicular: return AppColors.follicular;
        case CyclePhase.ovulation: return AppColors.ovulation;
        case CyclePhase.luteal: return AppColors.luteal;
        default: return Colors.grey.withOpacity(0.3);
      }
    }
  }

  // 🧮 Математика прогноза (Бесконечный цикл)
  CyclePhase _predictFuturePhase(DateTime date) {
    int daysFromStart = date.difference(currentCycleStart).inDays;

    if (daysFromStart < 0) return CyclePhase.late;

    int cycleLen = provider.cycleLength > 0 ? provider.cycleLength : 28;
    int periodLen = provider.periodDuration;

    int dayInCycle = daysFromStart % cycleLen;
    int ovulationDay = cycleLen - 14;

    if (dayInCycle < periodLen) {
      return CyclePhase.menstruation;
    } else if (dayInCycle < ovulationDay - 5) {
      return CyclePhase.follicular;
    } else if (dayInCycle <= ovulationDay) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    const int range = 90;
    final double baseRadius = size.width * 0.35;
    const double depthStep = 50.0;

    List<int> indices = [];
    for (int i = range; i >= 1; i--) indices.add(i);
    for (int i = -range; i <= -1; i++) indices.add(i);
    indices.add(0);

    for (int i in indices) {
      final currentDate = normalizedToday.add(Duration(days: i + scrollOffset.toInt()));

      bool isPrediction = currentDate.difference(currentCycleStart).inDays > provider.cycleLength;

      final double fractionalOffset = scrollOffset - scrollOffset.truncate();

      double timePos = i - fractionalOffset;
      double angle = timePos * 0.4;
      double z = timePos * depthStep;

      const double focalLength = 600.0;
      if (z + focalLength < 10) continue;

      double scale = focalLength / (focalLength + z);
      double x3d = baseRadius * math.cos(angle);
      double y3d = baseRadius * math.sin(angle);

      double x2d = center.dx + x3d * scale;
      double y2d = center.dy + y3d * scale;
      double cellSize = 40 * scale;

      if (cellSize < 3 || x2d < -50 || x2d > size.width + 50 || y2d < -50 || y2d > size.height + 50) continue;

      final isSelected = _isSameDay(currentDate, selectedDay);
      final isTodayDate = _isSameDay(currentDate, normalizedToday);

      final phaseColor = _getPhaseColor(currentDate);

      double opacity = (scale * 1.5).clamp(0.1, 1.0);
      if (z > 0) opacity = (1.0 - z / (range * depthStep / 2)).clamp(0.0, 1.0);

      if (isPrediction && !isSelected) {
        opacity *= 0.85;
      }

      final paint = Paint()
        ..color = phaseColor.withOpacity(opacity * (isSelected ? 0.9 : 0.6))
        ..style = PaintingStyle.fill;

      if (isSelected) {
        canvas.drawCircle(Offset(x2d, y2d), cellSize * 0.7, Paint()..color = phaseColor.withOpacity(0.4 * opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
      }

      canvas.drawCircle(Offset(x2d, y2d), cellSize / 2, paint);

      if (isSelected || isTodayDate) {
        final borderPaint = Paint()
          ..color = (isSelected ? AppColors.primary : AppColors.textPrimary).withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 * scale : 1.5 * scale;
        canvas.drawCircle(Offset(x2d, y2d), cellSize / 2, borderPaint);
      } else if (isPrediction) {
        final predBorder = Paint()
          ..color = Colors.white.withOpacity(0.4 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 * scale;
        canvas.drawCircle(Offset(x2d, y2d), cellSize / 2, predBorder);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${currentDate.day}',
          style: GoogleFonts.inter(
            color: (isTodayDate || isSelected ? AppColors.textPrimary : AppColors.textSecondary).withOpacity(opacity),
            fontSize: 16 * scale,
            fontWeight: isTodayDate || isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x2d - textPainter.width / 2, y2d - textPainter.height / 2));

      if (currentDate.day == 1 && scale > 0.4) {
        final monthPainter = TextPainter(
          text: TextSpan(
            text: DateFormat.MMM().format(currentDate).toUpperCase(),
            style: GoogleFonts.inter(color: AppColors.textAccent.withOpacity(opacity), fontSize: 12 * scale, fontWeight: FontWeight.bold),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        monthPainter.layout();
        monthPainter.paint(canvas, Offset(x2d - monthPainter.width / 2, y2d - cellSize/2 - monthPainter.height - 5*scale));
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimeTunnelPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset || oldDelegate.selectedDay != selectedDay;
  }
}