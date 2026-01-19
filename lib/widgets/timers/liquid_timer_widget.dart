import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/cycle_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Premium Liquid Timer (Subscription-grade)
/// - Glass capsule ring + subtle inner shadow (works on LIGHT gradient backgrounds)
/// - Dual-layer waves (parallax) + soft foam highlight
/// - Gradient liquid + glow that follows phase color
/// - Smooth percentage + day label + phase chip
/// - No packages, ready to paste
class LiquidTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const LiquidTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<LiquidTimerWidget> createState() => _LiquidTimerWidgetState();
}

class _LiquidTimerWidgetState extends State<LiquidTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _introCtrl;
  late final AnimationController _fillCtrl;

  late Animation<double> _fillAnim;
  double _prevFill = 0.0;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _prevFill = _calcFill(widget.data);
    _fillAnim = Tween<double>(begin: _prevFill, end: _prevFill).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOutCubic),
    );
    _fillCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant LiquidTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _calcFill(widget.data);
    if ((next - _prevFill).abs() > 0.0001) {
      _fillAnim = Tween<double>(begin: _fillAnim.value, end: next).animate(
        CurvedAnimation(parent: _fillCtrl, curve: Curves.easeInOutCubic),
      );
      _fillCtrl
        ..value = 0
        ..forward();
      _prevFill = next;
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _introCtrl.dispose();
    _fillCtrl.dispose();
    super.dispose();
  }

  double _calcFill(CycleData data) {
    final total = data.totalCycleLength <= 0 ? 1 : data.totalCycleLength;
    return (data.currentDay / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final phaseColor = _getPhaseColor(widget.data.phase, widget.isCOC);
    final phaseName = _getPhaseName(widget.data.phase, l10n, widget.isCOC);

    return LayoutBuilder(
      builder: (context, c) {
        final maxSide = math.min(
          c.maxWidth.isFinite ? c.maxWidth : 320.0,
          c.maxHeight.isFinite ? c.maxHeight : 320.0,
        );
        final size = maxSide.clamp(260.0, 360.0);

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_waveCtrl, _introCtrl, _fillCtrl]),
            builder: (_, __) {
              final introT = Curves.easeOutCubic.transform(_introCtrl.value);
              final t = _waveCtrl.value;
              final fill = _fillAnim.value;

              // make liquid color feel premium: slightly cooler + glassy highlight
              final liquid = _LiquidPalette.fromPhase(phaseColor);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow (subtle, works on light backgrounds)
                  IgnorePointer(
                    child: Opacity(
                      opacity: introT,
                      child: _SoftGlow(
                        color: liquid.glowColor,
                        intensity: 0.14 + 0.10 * math.sin(t * math.pi * 2) * 0.5,
                        radius: size * 0.45,
                      ),
                    ),
                  ),

                  // Glass container with liquid inside
                  ClipOval(
                    child: Stack(
                      children: [
                        // Very subtle glass wash (transparent)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(-0.25, -0.35),
                                radius: 1.0,
                                colors: [
                                  Colors.white.withOpacity(0.30),
                                  Colors.white.withOpacity(0.06),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Liquid (dual waves + gradient)
                        Positioned.fill(
                          child: Transform.scale(
                            scale: lerpDouble(0.985, 1.0, introT) ?? 1.0,
                            child: CustomPaint(
                              painter: _PremiumLiquidPainter(
                                t: t,
                                fill: fill,
                                palette: liquid,
                              ),
                            ),
                          ),
                        ),

                        // Inner shadow (adds depth on light background)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _InnerShadowPainter(
                              strength: 0.18,
                            ),
                          ),
                        ),

                        // Specular highlight streak (glass)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.65,
                              child: CustomPaint(
                                painter: _GlassHighlightPainter(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ring stroke + subtle ticks to make it feel "premium"
                  IgnorePointer(
                    child: Opacity(
                      opacity: introT,
                      child: CustomPaint(
                        size: Size.square(size),
                        painter: _PremiumRingChromePainter(
                          accent: phaseColor,
                        ),
                      ),
                    ),
                  ),

                  // Text + chip
                  _LiquidOverlay(
                    percent: (fill * 100).round(),
                    dayLabel: l10n.dayTitle.toUpperCase(),
                    phaseLabel: phaseName.toUpperCase(),
                    accent: phaseColor,
                    fill: fill,
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

// ========================== Overlay UI ==========================

class _LiquidOverlay extends StatelessWidget {
  final int percent;
  final String dayLabel;
  final String phaseLabel;
  final Color accent;
  final double fill;
  final double introT;

  const _LiquidOverlay({
    required this.percent,
    required this.dayLabel,
    required this.phaseLabel,
    required this.accent,
    required this.fill,
    required this.introT,
  });

  @override
  Widget build(BuildContext context) {
    // Adaptive text color: on top of “deep liquid” use white, otherwise dark
    final onLiquid = fill > 0.52;
    final primary = onLiquid ? Colors.white.withOpacity(0.95) : const Color(0xFF0B1020);
    final secondary = onLiquid ? Colors.white.withOpacity(0.72) : const Color(0xFF0B1020).withOpacity(0.55);

    final scale = lerpDouble(0.985, 1.0, introT) ?? 1.0;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: introT,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$percent%",
              style: TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: primary,
                shadows: [
                  Shadow(
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    color: onLiquid ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
                color: secondary,
              ),
            ),
            const SizedBox(height: 16),
            _LightGlassChip(label: phaseLabel, accent: accent, onLiquid: onLiquid),
          ],
        ),
      ),
    );
  }
}

class _LightGlassChip extends StatelessWidget {
  final String label;
  final Color accent;
  final bool onLiquid;

  const _LightGlassChip({
    required this.label,
    required this.accent,
    required this.onLiquid,
  });

  @override
  Widget build(BuildContext context) {
    final bg = onLiquid ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.38);
    final border = onLiquid ? Colors.white.withOpacity(0.22) : Colors.white.withOpacity(0.65);
    final textColor = onLiquid ? Colors.white.withOpacity(0.92) : const Color(0xFF0B1020);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
            color: accent.withOpacity(0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _mix(accent, Colors.white, 0.22),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: accent.withOpacity(0.18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: textColor,
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

// ========================== Liquid painting ==========================

class _LiquidPalette {
  final Color deep;
  final Color mid;
  final Color light;
  final Color foam;
  final Color glowColor;

  const _LiquidPalette({
    required this.deep,
    required this.mid,
    required this.light,
    required this.foam,
    required this.glowColor,
  });

  factory _LiquidPalette.fromPhase(Color phase) {
    // Premium: slightly cooler & more “inky” than raw phase color
    final deep = _mix(phase, const Color(0xFF0A1630), 0.45);
    final mid = _mix(phase, const Color(0xFF244A8F), 0.20);
    final light = _mix(phase, Colors.white, 0.22);
    final foam = _mix(phase, Colors.white, 0.55).withOpacity(0.95);
    final glow = _mix(phase, Colors.white, 0.20);
    return _LiquidPalette(deep: deep, mid: mid, light: light, foam: foam, glowColor: glow);
  }
}

class _PremiumLiquidPainter extends CustomPainter {
  final double t; // 0..1
  final double fill; // 0..1
  final _LiquidPalette palette;

  _PremiumLiquidPainter({
    required this.t,
    required this.fill,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Liquid gradient background inside fill area
    final fillTop = size.height * (1 - fill);
    final fillRect = Rect.fromLTWH(0, fillTop, size.width, size.height - fillTop);

    // base liquid gradient (vertical)
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.light.withOpacity(0.92),
          palette.mid.withOpacity(0.92),
          palette.deep.withOpacity(0.92),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(fillRect);

    // Draw waves path (back wave then front wave)
    final back = _wavePath(
      size,
      baseY: fillTop,
      amplitude: 8.5,
      wavelength: 1.15,
      phase: (t * 2 * math.pi) * 0.85,
      verticalBias: 0.0,
    );

    final front = _wavePath(
      size,
      baseY: fillTop,
      amplitude: 12.0,
      wavelength: 1.0,
      phase: (t * 2 * math.pi) * 1.15,
      verticalBias: 2.0,
    );

    // Clip to liquid area (everything below wave)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, fillTop, size.width, size.height - fillTop));

    // Back wave (slightly darker)
    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.mid.withOpacity(0.70),
          palette.deep.withOpacity(0.86),
        ],
      ).createShader(fillRect);

    canvas.drawPath(back, backPaint);

    // Main liquid body
    canvas.drawRect(fillRect, liquidPaint);

    // Front wave (adds depth)
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.light.withOpacity(0.78),
          palette.mid.withOpacity(0.86),
          palette.deep.withOpacity(0.92),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(fillRect);

    canvas.drawPath(front, frontPaint);

    // Foam highlight along front wave
    final foamPaint = Paint()
      ..color = palette.foam.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final foamPath = _foamPathAlongWave(
      size,
      baseY: fillTop,
      amplitude: 12.0,
      wavelength: 1.0,
      phase: (t * 2 * math.pi) * 1.15,
      verticalBias: 2.0,
    );
    canvas.drawPath(foamPath, foamPaint);

    canvas.restore();

    // Subtle top meniscus shine (when fill is low, keep it very soft)
    final shineOpacity = (0.10 + fill * 0.16).clamp(0.0, 0.22);
    final shine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(shineOpacity),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, shine);
  }

  Path _wavePath(
      Size size, {
        required double baseY,
        required double amplitude,
        required double wavelength,
        required double phase,
        required double verticalBias,
      }) {
    final path = Path();
    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      final nx = x / size.width;
      final y = baseY +
          math.sin((nx * 2 * math.pi * wavelength) + phase) * amplitude +
          verticalBias;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  Path _foamPathAlongWave(
      Size size, {
        required double baseY,
        required double amplitude,
        required double wavelength,
        required double phase,
        required double verticalBias,
      }) {
    // Thin stroke-like path near the wave crest
    final path = Path();
    bool started = false;

    for (double x = 0; x <= size.width; x += 2) {
      final nx = x / size.width;
      final y = baseY +
          math.sin((nx * 2 * math.pi * wavelength) + phase) * amplitude +
          verticalBias;

      final crestY = y - 2.5; // slight up offset
      if (!started) {
        path.moveTo(x, crestY);
        started = true;
      } else {
        path.lineTo(x, crestY);
      }
    }

    // Give it a bit of thickness by closing a tiny strip
    for (double x = size.width; x >= 0; x -= 2) {
      final nx = x / size.width;
      final y = baseY +
          math.sin((nx * 2 * math.pi * wavelength) + phase) * amplitude +
          verticalBias;
      path.lineTo(x, y + 1.0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PremiumLiquidPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.fill != fill || oldDelegate.palette != palette;
  }
}

// ========================== Glass / depth painters ==========================

class _InnerShadowPainter extends CustomPainter {
  final double strength;

  _InnerShadowPainter({required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.2),
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.10 * strength),
          Colors.black.withOpacity(0.18 * strength),
        ],
        stops: const [0.62, 0.86, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) => oldDelegate.strength != strength;
}

class _GlassHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.08)
      ..quadraticBezierTo(size.width * 0.46, size.height * 0.02, size.width * 0.70, size.height * 0.18)
      ..quadraticBezierTo(size.width * 0.52, size.height * 0.22, size.width * 0.35, size.height * 0.30)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.24, size.width * 0.18, size.height * 0.08)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.32),
          Colors.white.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassHighlightPainter oldDelegate) => false;
}

class _PremiumRingChromePainter extends CustomPainter {
  final Color accent;

  _PremiumRingChromePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - 2;

    // Outer chrome ring (subtle, light background friendly)
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withOpacity(0.55);

    canvas.drawCircle(center, radius, outer);

    // Inner ring soft shadow
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.08);

    canvas.drawCircle(center, radius - 6, inner);

    // Accent micro-glow
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = accent.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(center, radius - 2, glow);
  }

  @override
  bool shouldRepaint(covariant _PremiumRingChromePainter oldDelegate) => oldDelegate.accent != accent;
}

// ========================== Soft glow widget ==========================

class _SoftGlow extends StatelessWidget {
  final Color color;
  final double intensity; // ~0..1
  final double radius;

  const _SoftGlow({
    required this.color,
    required this.intensity,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final blur = lerpDouble(16, 32, intensity.clamp(0.0, 1.0)) ?? 22;
    final spread = lerpDouble(2, 8, intensity.clamp(0.0, 1.0)) ?? 4;
    final alpha = lerpDouble(0.06, 0.18, intensity.clamp(0.0, 1.0)) ?? 0.10;

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
            color: color.withOpacity(alpha * 0.60),
            blurRadius: blur * 1.5,
            spreadRadius: spread * 0.6,
          ),
        ],
      ),
    );
  }
}

// ========================== Color helper ==========================

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
