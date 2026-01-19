import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/cycle_model.dart';
import '../../l10n/app_localizations.dart';

/// BloomTimerWidget — Premium Apple-style “Bloom” timer
/// ✅ Light / airy / iOS feel (no dark panels)
/// ✅ Lush, blooming petals (2 layers) — “fluffy flower” vibe
/// ✅ Bloom intensity is tied to cycle phase (bud -> peak at ovulation -> soften)
/// ✅ Accent color follows CyclePhase (phase.color extension)
/// ✅ Subtle progress ring + center glass chip (safe for long localized strings)
class BloomTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const BloomTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<BloomTimerWidget> createState() => _BloomTimerWidgetState();
}

class _BloomTimerWidgetState extends State<BloomTimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9800),
    )..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  double _cycleProgress01(CycleData data) {
    final total = (data.totalCycleLength <= 1 ? 2 : data.totalCycleLength);
    final day = data.currentDay.clamp(1, total);
    return ((day - 1) / (total - 1)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final accent = _softenAccent(widget.data.phase.color);
    final progress = _cycleProgress01(widget.data);
    final phaseLabel = _getPhaseName(widget.data.phase, l10n, widget.isCOC);

    return LayoutBuilder(
      builder: (context, c) {
        final maxSide = math.min(
          c.maxWidth.isFinite ? c.maxWidth : 340.0,
          c.maxHeight.isFinite ? c.maxHeight : 340.0,
        );
        final size = maxSide.clamp(260.0, 440.0);

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _loop,
            builder: (_, __) {
              final t = _loop.value;

              final breath = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
              final breathK = Curves.easeInOut.transform(breath);

              final bloomK = _bloomByPhase(widget.data.phase, progress);
              final intensity = (0.62 + 0.38 * bloomK) * (0.93 + 0.07 * breathK);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Polished ring + progress
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _BloomRingPainter(
                        accent: accent,
                        t: t,
                        progress01: progress,
                        intensity: intensity,
                      ),
                    ),
                  ),

                  // LAYER 1: outer lush petals (bigger)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _PetalBloomPainter(
                        t: t,
                        accent: accent,
                        petals: 14,
                        bloom01: bloomK,
                        breathe01: breathK,
                        layerScale: 1.0,
                        angleOffset: 0.0,
                      ),
                    ),
                  ),

                  // LAYER 2: inner petals (adds volume, very premium)
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _PetalBloomPainter(
                        t: t + 0.12,
                        accent: _mix(accent, Colors.white, 0.12),
                        petals: 12,
                        bloom01: (bloomK * 0.90).clamp(0.0, 1.0),
                        breathe01: breathK,
                        layerScale: 0.78,
                        angleOffset: math.pi / 14,
                      ),
                    ),
                  ),

                  // Micro sparkles (very subtle)
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.11 + 0.09 * (1.0 - bloomK),
                      child: CustomPaint(
                        size: Size.square(size),
                        painter: _MicroSparklePainter(t: t),
                      ),
                    ),
                  ),

                  // Center glass
                  _CenterGlass(
                    size: size,
                    accent: accent,
                    dayText: "${widget.data.currentDay}",
                    dayLabel: l10n.dayTitle.toUpperCase(),
                    phaseLabel: phaseLabel.toUpperCase(),
                    progress01: progress,
                    pulse01: breathK,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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

// ============================ Visual helpers ============================

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;

/// iOS-friendly accent: brighter & slightly cooler
Color _softenAccent(Color c) {
  final bright = _mix(c, Colors.white, 0.38);
  final cool = _mix(bright, const Color(0xFFBFD6FF), 0.10);
  return cool;
}

/// Base curve: smooth mid-cycle lift, gentle exhale near end.
double _bloomCurve(double p) {
  final mid = Curves.easeInOutCubic.transform(p);
  final end = (p - 0.86).clamp(0.0, 1.0) / 0.14;
  final exhale = Curves.easeOutCubic.transform(end);
  return (mid * (1.0 - 0.14 * exhale)).clamp(0.0, 1.0);
}

/// Phase-aware bloom:
/// menstruation = bud, follicular = rising, ovulation = peak, luteal/late = soften
double _bloomByPhase(CyclePhase phase, double progress) {
  final base = _bloomCurve(progress);

  switch (phase) {
    case CyclePhase.menstruation:
      return (0.12 + base * 0.42).clamp(0.0, 1.0);
    case CyclePhase.follicular:
      return (0.22 + base * 0.78).clamp(0.0, 1.0);
    case CyclePhase.ovulation:
      return (0.92 + base * 0.08).clamp(0.0, 1.0);
    case CyclePhase.luteal:
      return (0.55 + base * 0.40).clamp(0.0, 1.0);
    case CyclePhase.late:
      return (0.45 + base * 0.35).clamp(0.0, 1.0);
  }
}

// ============================ Outer ring ============================

class _BloomRingPainter extends CustomPainter {
  final Color accent;
  final double t;
  final double progress01;
  final double intensity;

  const _BloomRingPainter({
    required this.accent,
    required this.t,
    required this.progress01,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = (math.min(size.width, size.height) / 2) - 18;
    final rect = Rect.fromCircle(center: c, radius: r);

    // Track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withOpacity(0.045);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, track);

    // Progress
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = _mix(accent, Colors.white, 0.10).withOpacity(0.88);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress01.clamp(0.0, 1.0),
      false,
      prog,
    );

    // Polished sheen sweep
    final rot = (t * math.pi * 2) - math.pi / 3;
    final sweep = SweepGradient(
      startAngle: rot,
      endAngle: rot + math.pi * 2,
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.28 * intensity),
        _mix(accent, Colors.white, 0.62).withOpacity(0.18 * intensity),
        Colors.transparent,
      ],
      stops: const [0.00, 0.12, 0.22, 0.35],
    );

    final sheen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(rect, 0, math.pi * 2, false, sheen);

    // End dot
    final endA = (-math.pi / 2) + math.pi * 2 * progress01.clamp(0.0, 1.0);
    final endP = Offset(c.dx + r * math.cos(endA), c.dy + r * math.sin(endA));

    final dotGlow = Paint()
      ..color = accent.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(endP, 7.0, dotGlow);

    final dot = Paint()..color = _mix(accent, Colors.white, 0.12).withOpacity(0.95);
    canvas.drawCircle(endP, 2.8, dot);
  }

  @override
  bool shouldRepaint(covariant _BloomRingPainter old) {
    return old.accent != accent ||
        old.t != t ||
        old.progress01 != progress01 ||
        old.intensity != intensity;
  }
}

// ============================ Petal bloom (2-layer capable) ============================

class _PetalBloomPainter extends CustomPainter {
  final double t;
  final Color accent;
  final int petals;
  final double bloom01;
  final double breathe01;

  /// Layer tuning
  final double layerScale; // 1.0 outer, <1 inner
  final double angleOffset;

  const _PetalBloomPainter({
    required this.t,
    required this.accent,
    required this.petals,
    required this.bloom01,
    required this.breathe01,
    required this.layerScale,
    required this.angleOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final R0 = math.min(size.width, size.height) / 2;

    final R = R0 * layerScale;

    // No spinner: gentle sway
    final rot = math.sin(t * math.pi * 2) * 0.045;

    // Opening: bud -> lush -> soften (already phase-aware bloom01)
    final open = (0.58 + 0.42 * bloom01) * (0.92 + 0.08 * breathe01);

    // ✅ LARGER petals for “lush bloom”
    final petalLen = lerpDouble(R * 0.52, R * 0.78, open)!;
    final petalWide = lerpDouble(R * 0.22, R * 0.34, open)!;

    final silk1 = _mix(accent, Colors.white, 0.78);
    final silk2 = _mix(accent, Colors.white, 0.92);

    // Layer glow
    final globalGlow = Paint()
      ..color = accent.withOpacity((0.05 + 0.10 * bloom01) * (layerScale == 1.0 ? 1.0 : 0.75))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
    canvas.drawCircle(c, R0 * (0.52 + 0.08 * bloom01) * layerScale, globalGlow);

    for (int i = 0; i < petals; i++) {
      final a = rot + angleOffset + (2 * math.pi / petals) * i;

      // tiny petal wave
      final wave = math.sin((i / petals) * math.pi * 2 + (t * math.pi * 2) * 0.35) * 0.03;

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a + wave);

      final rect = Rect.fromCenter(
        center: Offset(0, -petalLen * 0.60),
        width: petalWide * 1.35,
        height: petalLen * 1.22,
      );

      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          silk2.withOpacity(0.24 + 0.12 * bloom01),
          silk1.withOpacity(0.11 + 0.10 * bloom01),
          Colors.white.withOpacity(0.02),
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(rect);

      final fill = Paint()..shader = shader;

      final path = _petalPath(petalLen: petalLen, petalWide: petalWide);

      final shadow = Paint()
        ..color = Colors.black.withOpacity(0.030 * (layerScale == 1.0 ? 1.0 : 0.80))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.16 + 0.14 * bloom01);

      final innerHi = Paint()
        ..color = Colors.white.withOpacity(0.06 + 0.10 * bloom01)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

      canvas.drawPath(path.shift(const Offset(1.0, 2.2)), shadow);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, edge);
      canvas.drawPath(path.shift(const Offset(-0.7, -1.0)), innerHi);

      canvas.restore();
    }
  }

  Path _petalPath({required double petalLen, required double petalWide}) {
    // Fluffy teardrop petal
    final w = petalWide;
    final h = petalLen;

    final p = Path();
    p.moveTo(0, 0);
    p.cubicTo(w * 0.86, -h * 0.18, w * 0.78, -h * 0.86, 0, -h);
    p.cubicTo(-w * 0.78, -h * 0.86, -w * 0.86, -h * 0.18, 0, 0);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _PetalBloomPainter old) {
    return old.t != t ||
        old.accent != accent ||
        old.petals != petals ||
        old.bloom01 != bloom01 ||
        old.breathe01 != breathe01 ||
        old.layerScale != layerScale ||
        old.angleOffset != angleOffset;
  }
}

// ============================ Micro sparkles ============================

class _MicroSparklePainter extends CustomPainter {
  final double t;
  const _MicroSparklePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;

    void sparkle(double phase, double radius, double alpha) {
      final a = (-math.pi / 2) + (math.pi * 2) * (t * 0.35 + phase);
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));

      final glow = Paint()
        ..color = Colors.white.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(p, 3.0, glow);

      final core = Paint()
        ..color = Colors.white.withOpacity((alpha * 1.3).clamp(0.0, 1.0));
      canvas.drawCircle(p, 1.1, core);
    }

    sparkle(0.18, r * 0.70, 0.10);
    sparkle(0.61, r * 0.60, 0.07);
  }

  @override
  bool shouldRepaint(covariant _MicroSparklePainter oldDelegate) => oldDelegate.t != t;
}

// ============================ Center glass ============================

class _CenterGlass extends StatelessWidget {
  final double size;
  final Color accent;
  final String dayText;
  final String dayLabel;
  final String phaseLabel;
  final double progress01;
  final double pulse01;

  const _CenterGlass({
    required this.size,
    required this.accent,
    required this.dayText,
    required this.dayLabel,
    required this.phaseLabel,
    required this.progress01,
    required this.pulse01,
  });

  @override
  Widget build(BuildContext context) {
    final core = size * 0.40;

    const primary = Color(0xFF0B1020);
    final secondary = primary.withOpacity(0.56);

    final glowOpacity = (0.10 + 0.10 * pulse01) * (0.65 + 0.35 * progress01);

    final dayFont = core * 0.36;
    final labelFont = core * 0.075;

    return Container(
      width: core,
      height: core,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 18),
            color: Colors.black.withOpacity(0.06),
          ),
          BoxShadow(
            blurRadius: 34,
            color: accent.withOpacity(glowOpacity),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.62),
              border: Border.all(color: Colors.white.withOpacity(0.88), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dayText,
                  style: TextStyle(
                    fontSize: dayFont,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                    height: 0.95,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelFont,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.6,
                    height: 1.0,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 8),
                _PhaseChip(label: phaseLabel, accent: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String label;
  final Color accent;

  const _PhaseChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.55);
    final border = Colors.white.withOpacity(0.85);
    final maxW = math.min(MediaQuery.of(context).size.width, 420.0) * 0.60;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _mix(accent, Colors.white, 0.20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: accent.withOpacity(0.18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Color(0xFF0B1020),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
