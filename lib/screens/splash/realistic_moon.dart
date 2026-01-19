import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class RealisticMoon extends StatelessWidget {
  final double size;
  /// Прогресс фазы от 0.0 (Тонкий серп) до 1.0 (Полнолуние)
  final double progress;

  const RealisticMoon({
    super.key,
    required this.size,
    this.progress = 0.35, // Дефолт (Брендовый серп)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PhaseMoonPainter(progress),
      ),
    );
  }
}

class _PhaseMoonPainter extends CustomPainter {
  final double progress; // 0.0 ... 1.0

  _PhaseMoonPainter(this.progress);

  static const List<List<double>> _craters = [
    [0.65, 0.5, 0.10], [0.60, 0.25, 0.07], [0.70, 0.75, 0.08],
    [0.85, 0.4, 0.06], [0.55, 0.65, 0.05], [0.4, 0.5, 0.09], [0.3, 0.3, 0.06]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. ПУТЬ ПОЛНОЙ ЛУНЫ
    final moonPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    // 2. РАСЧЕТ ТЕНИ (ДИНАМИКА)
    // progress 0.0 -> shadowOffset = -0.55 (наш серп)
    // progress 1.0 -> shadowOffset = -2.0 (тень улетает далеко влево, открывая всю луну)

    // Интерполяция позиции тени
    final double startOffset = -radius * 0.55; // Позиция для серпа
    final double endOffset = -radius * 3.0;    // Позиция для полнолуния (далеко)

    final currentOffset = startOffset + (endOffset - startOffset) * progress;

    final shadowRadius = radius * 1.05;
    final shadowOffsetPos = Offset(currentOffset, 0);

    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center + shadowOffsetPos, radius: shadowRadius));

    // Вычитаем тень (получаем текущую фазу)
    final visiblePath = Path.combine(PathOperation.difference, moonPath, shadowPath);

    // 3. РИСОВАНИЕ
    canvas.save();
    canvas.clipPath(visiblePath);

    // Градиент (меняем центр блика в зависимости от полноты)
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.4 - (progress * 0.4), -0.2), // Блик смещается к центру при полнолунии
        radius: 1.1,
        colors: [Colors.white, const Color(0xFFF0F0F6), const Color(0xFFD0D0E0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Кратеры
    for (var crater in _craters) {
      final cx = crater[0] * size.width;
      final cy = crater[1] * size.height;
      final cr = crater[2] * size.width;

      final craterPaint = Paint()..color = const Color(0xFF9090A0).withOpacity(0.3);
      canvas.drawCircle(Offset(cx, cy), cr, craterPaint);

      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cr * 0.08
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.black.withOpacity(0.15), Colors.white.withOpacity(0.5)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: cr));
      canvas.drawCircle(Offset(cx, cy), cr, rimPaint);
    }

    // Внутренняя тень
    final innerShadowPaint = Paint()
      ..color = const Color(0xFF202040).withOpacity(0.15 * (1 - progress)) // Тень исчезает при полнолунии
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(shadowPath.shift(const Offset(3, 0)), innerShadowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PhaseMoonPainter oldDelegate) => oldDelegate.progress != progress;
}