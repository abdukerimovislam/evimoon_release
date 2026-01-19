import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';

class TTCFertilityRing extends StatefulWidget {
  final double progress; // От 0.0 до 1.0 (например, день 14/28 = 0.5)
  final Color glowColor;
  final String mainText;
  final String subText;

  const TTCFertilityRing({
    super.key,
    required this.progress, // Передадим сюда (currentDay / cycleLength)
    required this.glowColor,
    required this.mainText,
    required this.subText
  });

  @override
  State<TTCFertilityRing> createState() => _TTCFertilityRingState();
}

class _TTCFertilityRingState extends State<TTCFertilityRing> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _progressAnimation;
  late AnimationController _progressController;

  final List<_Particle> _particles = [];
  final int _particleCount = 15;

  @override
  void initState() {
    super.initState();

    // 1. Анимация пульсации круга (Дыхание)
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4)
    )..repeat(reverse: true);

    // 2. Анимация частиц
    _particleController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10)
    )..repeat();

    // 3. Анимация заполнения прогресса при старте
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic)
    );

    _progressController.forward();
    _initParticles();
  }

  void _initParticles() {
    final rng = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 3 + 1,
        speed: rng.nextDouble() * 0.5 + 0.2,
        angle: rng.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  void didUpdateWidget(TTCFertilityRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: widget.progress
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // СЛОЙ 1: Задний фон (Стекло)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1), // Очень легкое стекло
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.2 + (_pulseController.value * 0.15)),
                      blurRadius: 40 + (_pulseController.value * 20),
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),

          // СЛОЙ 2: Частицы внутри (Gold Dust)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(220, 220), // Частицы только внутри
                painter: _ParticlePainter(
                    particles: _particles,
                    animValue: _particleController.value,
                    color: widget.glowColor
                ),
              );
            },
          ),

          // СЛОЙ 3: Прогресс бар (CustomPainter)
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: _GradientArcPainter(
                  progress: _progressAnimation.value,
                  glowColor: widget.glowColor,
                  trackColor: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),

          // СЛОЙ 4: Текст по центру
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  CupertinoIcons.sparkles,
                  color: widget.glowColor,
                  size: 32
              ),
              const SizedBox(height: 12),
              Text(
                widget.mainText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 10)
                    ]
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.glowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.subText.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- PAINTERS (РИСОВАЛЬЩИКИ) ---

class _GradientArcPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  final Color trackColor;

  _GradientArcPainter({
    required this.progress,
    required this.glowColor,
    required this.trackColor
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10; // Отступ от края
    final strokeWidth = 18.0;

    // 1. Рисуем ТРЕК (фон)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Рисуем ПРОГРЕСС (Градиент)
    // Поворачиваем канвас на -90 градусов, чтобы старт был сверху (12 часов)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);

    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Градиент: от прозрачного цвета к яркому
    final gradient = SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2 * progress,
        colors: [
          glowColor.withOpacity(0.1), // Хвост
          glowColor, // Голова
        ],
        stops: const [0.0, 1.0],
        tileMode: TileMode.clamp // Важно для неполного круга
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Тень под прогрессом (Glow effect)
    final shadowPaint = Paint()
      ..color = glowColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15); // Размытие

    // Рисуем тень
    canvas.drawArc(rect, 0, math.pi * 2 * progress, false, shadowPaint);
    // Рисуем саму дугу
    canvas.drawArc(rect, 0, math.pi * 2 * progress, false, progressPaint);

    // 3. Рисуем "ГОЛОВУ" (Knob) - Белая точка на конце
    if (progress > 0) {
      final angle = math.pi * 2 * progress;
      final knobX = radius * math.cos(angle);
      final knobY = radius * math.sin(angle);

      final knobPaint = Paint()..color = Colors.white;
      // Тень от точки
      canvas.drawCircle(Offset(knobX, knobY), 8, shadowPaint..strokeWidth=0..style=PaintingStyle.fill);
      // Сама точка
      canvas.drawCircle(Offset(knobX, knobY), 6, knobPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GradientArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowColor != glowColor;
  }
}

// --- ЧАСТИЦЫ ---
class _Particle {
  double x, y, size, speed, angle;
  _Particle({required this.x, required this.y, required this.size, required this.speed, required this.angle});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animValue;
  final Color color;

  _ParticlePainter({required this.particles, required this.animValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.4);
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      // Двигаем частицы по кругу или хаотично
      // Простая симуляция движения вверх и чуть в стороны
      double dy = (p.y - (animValue * p.speed)) % 1.0;
      double dx = p.x + (math.sin(animValue * 2 * math.pi + p.angle) * 0.05);

      final offset = Offset(
          dx * size.width,
          dy * size.height
      );

      // Рисуем только если внутри круга (простая маска по дистанции)
      if ((offset - center).distance < size.width / 2) {
        // Мерцание размера
        double pulseSize = p.size + (math.sin(animValue * 10 + p.angle) * 1);
        canvas.drawCircle(offset, pulseSize > 0 ? pulseSize : 0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true; // Всегда перерисовываем анимацию
}