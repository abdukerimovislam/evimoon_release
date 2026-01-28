import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';

class TTCGaugeCard extends StatelessWidget {
  final double score; // 0..1
  final String centerLabel;
  final String title;
  final String subtitle;
  final int? dpo;
  final String Function(int) dpoLabelBuilder;

  const TTCGaugeCard({
    super.key,
    required this.score,
    required this.centerLabel,
    required this.title,
    required this.subtitle,
    required this.dpo,
    required this.dpoLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 224,
            width: 224,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Рисуем арку с сердцем
                CustomPaint(
                  size: const Size(224, 224),
                  painter: _ArcPainter(
                    score: clamped,
                    gradientColors: TTCTheme.gradientColors,
                    emptyColor: const Color(0xFFEEE5DC),
                  ),
                ),
                // Текст в центре
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        centerLabel,
                        key: ValueKey(centerLabel),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        title,
                        key: ValueKey(title),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(text: subtitle),
              if (dpo != null && dpo! > 0) _Chip(text: dpoLabelBuilder(dpo!)),
            ],
          ),
        ],
      ),
    );
  }
}

class PeakGlowWrapper extends StatelessWidget {
  final bool enabled;
  final AnimationController controller;
  final Widget child;

  const PeakGlowWrapper({
    super.key,
    required this.enabled,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final glow = 0.08 + (t * 0.10);
        final scale = 1.0 + (t * 0.010);

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: TTCTheme.statusPeak.withOpacity(glow),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: RepaintBoundary(child: child),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.textPrimary.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double score;
  final List<Color> gradientColors;
  final Color emptyColor;

  _ArcPainter({
    required this.score,
    required this.gradientColors,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.60); // Чуть сместил центр
    final radius = size.width * 0.40;
    const startAngle = -math.pi * 1.2;
    const sweepAngle = math.pi * 1.4;

    // 1. Фон арки
    final bgPaint = Paint()
      ..color = emptyColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, bgPaint);

    // 2. Активная дуга (Градиент)
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors,
      stops: const [0.0, 0.6, 1.0],
      transform: GradientRotation(startAngle - 0.2),
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * score,
      false,
      activePaint,
    );

    // 3. Сердце на конце (вместо круга)
    if (score > 0.02) {
      final endAngle = startAngle + (sweepAngle * score);

      // Координаты центра сердца
      final knobCenter = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      _drawHeart(canvas, knobCenter, 10.0, AppColors.surface);
    }
  }

  // Метод для рисования сердца
  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();

    // Рисуем сердце относительно (0,0), потом сдвигаем
    // Ширина ~ 2*size, высота ~ 2*size
    path.moveTo(0, size * 0.25);
    path.cubicTo(
        size, -size * 0.5, // control point 1
        size * 1.8, size * 0.6, // control point 2
        0, size * 1.6 // end point (bottom tip)
    );
    path.cubicTo(
        -size * 1.8, size * 0.6,
        -size, -size * 0.5,
        0, size * 0.25
    );

    path.close();

    canvas.save();
    canvas.translate(center.dx, center.dy - size * 0.6); // Центрируем визуально

    // Тень
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Само сердце (белое с обводкой в цвет темы)
    canvas.drawPath(path, Paint()..color = color);

    // Тонкая цветная обводка для красоты
    canvas.drawPath(
        path,
        Paint()
          ..color = gradientColors.last.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.emptyColor != emptyColor;
  }
}