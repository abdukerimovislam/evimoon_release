import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/cycle_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Premium подписочный таймер: градиентное кольцо + glow + тики + glass UI.
/// Без пакетов. Код готов к вставке.
class MinimalTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const MinimalTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<MinimalTimerWidget> createState() => _MinimalTimerWidgetState();
}

class _MinimalTimerWidgetState extends State<MinimalTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final AnimationController _breathCtrl;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final total = widget.data.totalCycleLength <= 0 ? 1 : widget.data.totalCycleLength;
    final rawProgress = widget.data.currentDay / total;
    final progress = rawProgress.clamp(0.0, 1.0);

    final baseColor = _getPhaseColor(widget.data.phase, widget.isCOC);
    final phaseName = _getPhaseName(widget.data.phase, l10n, widget.isCOC);

    final style = _PremiumTimerStyle.fromPhaseColor(baseColor);

    // Размеры: адаптивно под родителя, но с безопасным минимумом/максимумом.
    return LayoutBuilder(
      builder: (context, c) {
        final maxSide = math.min(c.maxWidth.isFinite ? c.maxWidth : 320.0,
            c.maxHeight.isFinite ? c.maxHeight : 320.0);
        final size = maxSide.clamp(260.0, 340.0);

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_introCtrl, _breathCtrl]),
            builder: (context, _) {
              final introT = Curves.easeOutCubic.transform(_introCtrl.value);
              final breath = _breathCtrl.value;

              // Плавное появление прогресса + лёгкий "breathing" glow.
              final animatedProgress = progress * introT;
              final glowStrength = lerpDouble(
                style.glowMin,
                style.glowMax,
                Curves.easeInOut.transform(breath),
              ) ??
                  style.glowMin;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Внешнее мягкое свечение (подписочный “luxury” акцент)
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.9 * introT,
                      child: _SoftGlow(
                        color: style.glowColor,
                        intensity: glowStrength,
                        radius: size * 0.47,
                      ),
                    ),
                  ),

                  // Основное кольцо (фон + тики + прогресс градиентом)
                  CustomPaint(
                    size: Size.square(size),
                    painter: _PremiumRingPainter(
                      progress: animatedProgress,
                      baseColor: baseColor,
                      style: style,
                      // Прогресс визуально "свернут" как в часах: старт сверху.
                      startAngle: -math.pi / 2,
                    ),
                  ),

                  // Внутренний контент (число + DAY + chip фазы)
                  _InnerContent(
                    day: widget.data.currentDay,
                    dayLabel: l10n.dayTitle.toUpperCase(),
                    phaseLabel: phaseName.toUpperCase(),
                    accent: baseColor,
                    style: style,
                    introT: introT,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ====== Цвета и названия фаз (оставил твою логику, но вынес в private) ======

  Color _getPhaseColor(CyclePhase phase, bool isCOC) {
    if (isCOC) {
      return phase == CyclePhase.menstruation
          ? AppColors.menstruation
          : AppColors.follicular;
    }
    switch (phase) {
      case CyclePhase.menstruation:
        return AppColors.menstruation;
      case CyclePhase.follicular:
        return AppColors.follicular;
      case CyclePhase.ovulation:
        return AppColors.ovulation;
      case CyclePhase.luteal:
        return AppColors.luteal;
      case CyclePhase.late:
        return Colors.redAccent;
    }
  }

  String _getPhaseName(CyclePhase phase, AppLocalizations l10n, bool isCOC) {
    if (isCOC) {
      return phase == CyclePhase.menstruation
          ? l10n.cocBreakPhase
          : l10n.cocActivePhase;
    }
    switch (phase) {
      case CyclePhase.menstruation:
        return l10n.phaseMenstruation;
      case CyclePhase.follicular:
        return l10n.phaseFollicular;
      case CyclePhase.ovulation:
        return l10n.phaseOvulation;
      case CyclePhase.luteal:
        return l10n.phaseLuteal;
      case CyclePhase.late:
        return l10n.phaseLate;
    }
  }
}

// ======================== STYLE (все настройки в одном месте) ========================

class _PremiumTimerStyle {
  final double ringStroke; // Толщина кольца
  final double bgStroke; // Толщина фоновой подложки
  final double tickStroke; // Толщина тиков
  final double tickLength; // Длина тиков
  final int tickCount; // Кол-во тиков
  final double capRadius; // Скругление в конце прогресса

  final double innerPadding; // Внутренний отступ под контент
  final double glassBlur; // Blur для glass
  final double glassOpacity; // Прозрачность стекла

  final double glowMin; // Мин. сила свечения
  final double glowMax; // Макс. сила свечения
  final Color glowColor;

  final Color bgRingColor; // Базовый фон кольца (очень мягкий)
  final Color tickColor; // Тики

  final List<Color> gradientColors; // Градиент прогресса
  final List<double> gradientStops;

  const _PremiumTimerStyle({
    required this.ringStroke,
    required this.bgStroke,
    required this.tickStroke,
    required this.tickLength,
    required this.tickCount,
    required this.capRadius,
    required this.innerPadding,
    required this.glassBlur,
    required this.glassOpacity,
    required this.glowMin,
    required this.glowMax,
    required this.glowColor,
    required this.bgRingColor,
    required this.tickColor,
    required this.gradientColors,
    required this.gradientStops,
  });

  factory _PremiumTimerStyle.fromPhaseColor(Color phase) {
    // Мягкая настройка “премиум” под твой AppTheme.
    // Подложку/тики делаем едва заметными.
    final bg = phase.withOpacity(0.10);
    final tick = AppColors.textSecondary.withOpacity(0.20);

    // Градиент: “дорого” выглядит, когда есть 3-4 тона одной гаммы.
    // Если цвет уже яркий — добавляем светлую “искру” и более темный хвост.
    final c1 = _mix(phase, Colors.white, 0.32);
    final c2 = _mix(phase, Colors.white, 0.12);
    final c3 = phase;
    final c4 = _mix(phase, Colors.black, 0.18);

    return _PremiumTimerStyle(
      ringStroke: 14,
      bgStroke: 14,
      tickStroke: 2,
      tickLength: 8,
      tickCount: 40,
      capRadius: 7,
      innerPadding: 34,
      glassBlur: 14,
      glassOpacity: 0.38,
      glowMin: 0.12,
      glowMax: 0.32,
      glowColor: phase.withOpacity(0.85),
      bgRingColor: bg,
      tickColor: tick,
      gradientColors: [c1, c2, c3, c4],
      gradientStops: const [0.0, 0.35, 0.72, 1.0],
    );
  }
}

Color _mix(Color a, Color b, double t) {
  return Color.lerp(a, b, t) ?? a;
}

// ======================== PAINTER: кольцо + тики + прогресс ========================

class _PremiumRingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color baseColor;
  final _PremiumTimerStyle style;
  final double startAngle;

  _PremiumRingPainter({
    required this.progress,
    required this.baseColor,
    required this.style,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - 10;

    final ringRect = Rect.fromCircle(center: center, radius: radius);

    // 1) Подложка
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.bgStroke
      ..strokeCap = StrokeCap.round
      ..color = style.bgRingColor;

    canvas.drawArc(ringRect, 0, math.pi * 2, false, bgPaint);

    // 2) Тики (делаем “дорогую” шкалу)
    _drawTicks(canvas, center, radius);

    // 3) Прогресс: градиент по дуге + мягкий хайлайт.
    if (progress > 0) {
      final sweep = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + (math.pi * 2),
        colors: style.gradientColors,
        stops: style.gradientStops,
        transform: GradientRotation(0),
      );

      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.ringStroke
        ..strokeCap = StrokeCap.round
        ..shader = sweep.createShader(ringRect);

      final sweepAngle = (math.pi * 2) * progress;
      canvas.drawArc(ringRect, startAngle, sweepAngle, false, progressPaint);

      // 4) “Cap glow” в конце прогресса — очень премиально смотрится.
      final endAngle = startAngle + sweepAngle;
      final capPos = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final capGlow = Paint()
        ..color = baseColor.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(capPos, style.capRadius + 3, capGlow);

      final cap = Paint()..color = _mix(baseColor, Colors.white, 0.18);
      canvas.drawCircle(capPos, style.capRadius, cap);
    }
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.tickStroke
      ..strokeCap = StrokeCap.round
      ..color = style.tickColor;

    final innerR = radius - (style.bgStroke / 2) - 10;
    final outerR = innerR + style.tickLength;

    for (int i = 0; i < style.tickCount; i++) {
      final t = i / style.tickCount;
      final a = startAngle + (math.pi * 2) * t;

      // Каждый 5-й тик — чуть длиннее и заметнее (визуальная “дороговизна”).
      final isMajor = i % 5 == 0;
      final len = isMajor ? style.tickLength * 1.55 : style.tickLength;

      final r1 = innerR;
      final r2 = innerR + len;

      final p1 = Offset(center.dx + r1 * math.cos(a), center.dy + r1 * math.sin(a));
      final p2 = Offset(center.dx + r2 * math.cos(a), center.dy + r2 * math.sin(a));

      tickPaint.color = isMajor
          ? style.tickColor.withOpacity(0.30)
          : style.tickColor.withOpacity(0.18);

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.style != style ||
        oldDelegate.startAngle != startAngle;
  }
}

// ======================== UI: inner content ========================

class _InnerContent extends StatelessWidget {
  final int day;
  final String dayLabel;
  final String phaseLabel;
  final Color accent;
  final _PremiumTimerStyle style;
  final double introT;

  const _InnerContent({
    required this.day,
    required this.dayLabel,
    required this.phaseLabel,
    required this.accent,
    required this.style,
    required this.introT,
  });

  @override
  Widget build(BuildContext context) {
    final scale = lerpDouble(0.98, 1.0, introT) ?? 1.0;
    final opacity = introT;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: EdgeInsets.all(style.innerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Число дня — крупно и “воздушно”
              Text(
                "$day",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 8),

              // DAY label — аккуратный трекинг
              Text(
                dayLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3.6,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              // Glass chip для фазы (премиальный “pill”)
              _GlassChip(
                label: phaseLabel,
                accent: accent,
                blur: style.glassBlur,
                opacity: style.glassOpacity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final Color accent;
  final double blur;
  final double opacity;

  const _GlassChip({
    required this.label,
    required this.accent,
    required this.blur,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final border = accent.withOpacity(0.35);
    final glow = accent.withOpacity(0.18);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            spreadRadius: 1,
            color: glow,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(opacity),
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // маленькая “живая” точка индикатора
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _mix(accent, Colors.white, 0.10),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: accent.withOpacity(0.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================== Soft Glow widget ========================

class _SoftGlow extends StatelessWidget {
  final Color color;
  final double intensity; // 0..1
  final double radius;

  const _SoftGlow({
    required this.color,
    required this.intensity,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final blur = lerpDouble(18, 34, intensity) ?? 24;
    final spread = lerpDouble(2, 8, intensity) ?? 4;
    final alpha = lerpDouble(0.10, 0.26, intensity) ?? 0.16;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(alpha),
            blurRadius: blur,
            spreadRadius: spread,
          ),
          BoxShadow(
            color: color.withOpacity(alpha * 0.7),
            blurRadius: blur * 1.4,
            spreadRadius: spread * 0.5,
          ),
        ],
      ),
    );
  }
}
