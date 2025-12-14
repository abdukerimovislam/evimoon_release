import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui; // Для ImageFilter
import '../models/cycle_model.dart';

class MeshCycleBackground extends StatefulWidget {
  final CyclePhase phase;
  final Widget child;

  const MeshCycleBackground({
    super.key,
    required this.phase,
    required this.child,
  });

  @override
  State<MeshCycleBackground> createState() => _MeshCycleBackgroundState();
}

class _MeshCycleBackgroundState extends State<MeshCycleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Наборы цветов для каждой фазы: [Фон, Пятно 1, Пятно 2]
  List<Color> _getPhaseColors(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
      // Спокойный красный/розовый (Уют)
        return [
          const Color(0xFFFFF0F5), // LavenderBlush
          const Color(0xFFFFC1E3), // Pink
          const Color(0xFFFFB7B2), // Light Salmon
        ];
      case CyclePhase.follicular:
      // Свежий, Энергичный (Teal/Lilac) - Подходит и для КОК (Active)
        return [
          const Color(0xFFF3E5F5), // Purple 50
          const Color(0xFFB2DFDB), // Teal 100
          const Color(0xFFE1BEE7), // Purple 100
        ];
      case CyclePhase.ovulation:
      // Яркий, Привлекательный (Персик/Роза)
        return [
          const Color(0xFFFFF3E0), // Orange 50
          const Color(0xFFFFCCBC), // Deep Orange 100
          const Color(0xFFF8BBD0), // Pink 100
        ];
      case CyclePhase.luteal:
      // Успокаивающий (Мята/Лаванда)
        return [
          const Color(0xFFF1F8E9), // Light Green 50
          const Color(0xFFD1C4E9), // Deep Purple 100
          const Color(0xFFC5E1A5), // Light Green 200
        ];
      case CyclePhase.late:
      // Нейтральный серый (Неопределенность)
        return [
          const Color(0xFFFAFAFA), // Grey 50
          const Color(0xFFCFD8DC), // Blue Grey 100
          const Color(0xFFE0E0E0), // Grey 300
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    // Очень медленная анимация (дыхание) - 10 секунд цикл
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getPhaseColors(widget.phase);

    return Stack(
      children: [
        // 1. Базовый цвет фона (плавная смена)
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(color: colors[0]),
        ),

        // 2. Движущиеся пятна (Blobs)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // Сложная траектория движения (Лиссажу)
            final dx1 = sin(t * 2 * pi) * 0.3;
            final dy1 = cos(t * 2 * pi) * 0.2;

            final dx2 = cos(t * 2 * pi) * 0.3;
            final dy2 = sin(t * 2 * pi) * -0.2;

            return Stack(
              children: [
                // Пятно 1 (Верхний левый угол -> Центр)
                Align(
                  alignment: Alignment(-0.8 + dx1, -0.6 + dy1),
                  child: _BlurBlob(color: colors[1], size: 400),
                ),

                // Пятно 2 (Нижний правый угол -> Центр)
                Align(
                  alignment: Alignment(0.8 + dx2, 0.6 + dy2),
                  child: _BlurBlob(color: colors[2], size: 350),
                ),

                // Пятно 3 (Слабое по центру для глубины)
                Align(
                  alignment: Alignment(dx2, dy1),
                  child: _BlurBlob(color: colors[1].withOpacity(0.4), size: 250),
                ),
              ],
            );
          },
        ),

        // 3. Super Glass Blur (Размывает пятна в градиент)
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0), // Сильный блюр!
          child: Container(color: Colors.transparent),
        ),

        // 4. Контент приложения
        widget.child,
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    // Используем AnimatedContainer для плавной смены цвета при смене фазы
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}