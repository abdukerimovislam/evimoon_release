import 'dart:math' as math;
import 'package:flutter/material.dart';

class RealisticMoon extends StatelessWidget {
  final double size;
  final double progress; // 0.0 (Новолуние) -> 1.0 (Полнолуние)

  const RealisticMoon({
    super.key,
    required this.size,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    // Небольшая корректировка, чтобы луна никогда не исчезала полностью
    // Даже в "новолуние" мы оставим тонкий серп для красоты (мин 0.1)
    final effectiveProgress = progress.clamp(0.15, 1.0);

    return CustomPaint(
      size: Size(size, size),
      painter: _MoonPainter(phase: effectiveProgress),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final double phase; // 0.0 to 1.0

  _MoonPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Рисуем "Теневую" сторону (Едва заметный круг, чтобы луна имела объем)
    final shadowPaint = Paint()
      ..color = const Color(0xFF1A1A2E) // Цвет темной части луны
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, shadowPaint);

    // 2. Рисуем "Светлую" сторону (Освещенная часть)
    // Используем градиент для объема (от белого к серебру)
    final lightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFE0E0E0), Color(0xFFC0C0C0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Математика фазы:
    // Мы рисуем две дуги. Одна - внешний контур, вторая - терминатор (граница света и тени).
    final path = Path();

    // Внешний контур (справа - всегда полуокружность света)
    path.addArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
    );

    // Терминатор (граница тени). Это эллипс, ширина которого меняется.
    // phase 0 -> 1. Преобразуем в -1 (серп) -> 0 (половина) -> 1 (полная)
    // Но для упрощения анимации от серпа до полной:
    // widthFactor меняется от -radius (тонкий серп) до +radius (полная)

    // Интерполируем: 0.0 -> серп, 1.0 -> полная
    double widthFactor = (phase * 2 - 1) * radius;

    // Рисуем вторую половину эллипсом
    // Используем кривые Безье для идеальной формы
    path.arcToPoint(
      Offset(center.dx, center.dy - radius), // Возвращаемся наверх
      radius: Radius.elliptical(widthFactor.abs(), radius),
      rotation: 0,
      largeArc: false,
      clockwise: widthFactor > 0, // Направление зависит от того, больше половины или меньше
    );

    path.close();
    canvas.drawPath(path, lightPaint);

    // 3. Добавляем кратеры (опционально, едва заметные) для текстуры
    if (phase > 0.3) {
      _drawCraters(canvas, center, radius, widthFactor);
    }
  }

  void _drawCraters(Canvas canvas, Offset center, double radius, double widthFactor) {
    final craterPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Пара "кратеров" для реализма
    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy - radius * 0.3), radius * 0.15, craterPaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.1, center.dy + radius * 0.4), radius * 0.1, craterPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy + radius * 0.1), radius * 0.08, craterPaint);
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) => oldDelegate.phase != phase;
}