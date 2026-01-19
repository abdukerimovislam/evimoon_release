import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/cycle_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// ZenTimerWidget — Premium Apple-style “Zen” timer (EviMoon)
/// ✅ Light / airy / iOS glassmorphism on LIGHT gradient backgrounds
/// ✅ Inside: dense, fast “color hurricane” (vortex) that changes palette by cycle phase
/// ✅ Phase-aware colors (uses phase.color, softened)
/// ✅ Safe layout (no overflow), localized phase/day labels
class ZenTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const ZenTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<ZenTimerWidget> createState() => _ZenTimerWidgetState();
}

class _ZenTimerWidgetState extends State<ZenTimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    // ✅ faster
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
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

    final progress01 = _cycleProgress01(widget.data);
    final palette = _zenPaletteForPhase(widget.data.phase);
    final phaseLabel = _getPhaseName(widget.data.phase, l10n, widget.isCOC).toUpperCase();

    // phase-driven intensity: calm during period, peak in ovulation
    final phaseIntensity = _phaseIntensity(widget.data.phase);

    return LayoutBuilder(
      builder: (context, c) {
        final maxSide = math.min(
          c.maxWidth.isFinite ? c.maxWidth : 340.0,
          c.maxHeight.isFinite ? c.maxHeight : 340.0,
        );
        final size = maxSide.clamp(260.0, 440.0);
        final r = size / 2;

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _loop,
            builder: (_, __) {
              final t = _loop.value;
              final breath = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
              final breathK = Curves.easeInOut.transform(breath);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background blobs (soft)
                  IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(r),
                      child: CustomPaint(
                        size: Size.square(size),
                        painter: _ZenBackdropPainter(
                          t: t,
                          base1: palette.bg1,
                          base2: palette.bg2,
                          base3: palette.bg3,
                        ),
                      ),
                    ),
                  ),

                  // Glass circle with the dense fast vortex inside
                  _ZenGlassVortexCard(
                    size: size,
                    palette: palette,
                    t: t,
                    progress01: progress01,
                    pulse01: breathK,
                    day: widget.data.currentDay,
                    dayLabel: l10n.dayTitle.toUpperCase(),
                    phaseLabel: phaseLabel,
                    vortexIntensity01: phaseIntensity,
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
      return phase == CyclePhase.menstruation ? l10n.cocBreakPhase : l10n.cocActivePhase;
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

// ============================ Phase intensity ============================

double _phaseIntensity(CyclePhase phase) {
  switch (phase) {
    case CyclePhase.menstruation:
      return 0.55; // calmer
    case CyclePhase.follicular:
      return 0.78;
    case CyclePhase.ovulation:
      return 1.00; // peak
    case CyclePhase.luteal:
      return 0.82;
    case CyclePhase.late:
      return 0.70;
  }
}

// ============================ Palette & helpers ============================

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;

/// iOS-friendly accent: brighter & slightly cooler
Color _softenAccent(Color c) {
  final bright = _mix(c, Colors.white, 0.40);
  final cool = _mix(bright, const Color(0xFFBFD6FF), 0.10);
  return cool;
}

class _ZenPalette {
  final Color accent;
  final Color a;
  final Color b;
  final Color c;
  final Color bg1;
  final Color bg2;
  final Color bg3;

  const _ZenPalette({
    required this.accent,
    required this.a,
    required this.b,
    required this.c,
    required this.bg1,
    required this.bg2,
    required this.bg3,
  });
}

_ZenPalette _zenPaletteForPhase(CyclePhase phase) {
  final acc = _softenAccent(phase.color);

  const mistPink = Color(0xFFFFD6E7);
  const mistBlue = Color(0xFFD9E7FF);
  const mistLav = Color(0xFFE9DDFF);
  const mistMint = Color(0xFFD7F6EE);
  const mistPeach = Color(0xFFFFE2CC);

  switch (phase) {
    case CyclePhase.menstruation:
      return _ZenPalette(
        accent: acc,
        a: _mix(acc, mistPink, 0.55),
        b: _mix(acc, mistPeach, 0.62),
        c: _mix(acc, mistLav, 0.50),
        bg1: _mix(acc, mistPink, 0.70),
        bg2: _mix(acc, mistPeach, 0.78),
        bg3: _mix(acc, mistLav, 0.72),
      );
    case CyclePhase.follicular:
      return _ZenPalette(
        accent: acc,
        a: _mix(acc, mistMint, 0.62),
        b: _mix(acc, mistBlue, 0.60),
        c: _mix(acc, mistLav, 0.55),
        bg1: _mix(acc, mistMint, 0.78),
        bg2: _mix(acc, mistBlue, 0.80),
        bg3: _mix(acc, mistLav, 0.78),
      );
    case CyclePhase.ovulation:
      return _ZenPalette(
        accent: acc,
        a: _mix(acc, mistPink, 0.52),
        b: _mix(acc, mistBlue, 0.55),
        c: _mix(acc, mistMint, 0.55),
        bg1: _mix(acc, mistPink, 0.78),
        bg2: _mix(acc, mistBlue, 0.80),
        bg3: _mix(acc, mistMint, 0.80),
      );
    case CyclePhase.luteal:
      return _ZenPalette(
        accent: acc,
        a: _mix(acc, mistLav, 0.62),
        b: _mix(acc, mistBlue, 0.58),
        c: _mix(acc, mistPeach, 0.52),
        bg1: _mix(acc, mistLav, 0.80),
        bg2: _mix(acc, mistBlue, 0.80),
        bg3: _mix(acc, mistPeach, 0.78),
      );
    case CyclePhase.late:
      return _ZenPalette(
        accent: acc,
        a: _mix(acc, mistBlue, 0.66),
        b: _mix(acc, mistLav, 0.64),
        c: _mix(acc, mistPink, 0.50),
        bg1: _mix(acc, mistBlue, 0.82),
        bg2: _mix(acc, mistLav, 0.82),
        bg3: _mix(acc, mistPink, 0.78),
      );
  }
}

// ============================ Backdrop blobs ============================

class _ZenBackdropPainter extends CustomPainter {
  final double t;
  final Color base1;
  final Color base2;
  final Color base3;

  const _ZenBackdropPainter({
    required this.t,
    required this.base1,
    required this.base2,
    required this.base3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final c = size.center(Offset.zero);

    void blob(Offset p, double rad, Color color, double op) {
      final paint = Paint()
        ..color = color.withOpacity(op)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, rad * 0.45);
      canvas.drawCircle(p, rad, paint);
    }

    final dx1 = math.sin(t * math.pi * 2) * r * 0.10;
    final dy1 = math.cos(t * math.pi * 2) * r * 0.08;

    final dx2 = math.cos(t * math.pi * 2 * 0.85 + 1.2) * r * 0.12;
    final dy2 = math.sin(t * math.pi * 2 * 0.85 + 1.2) * r * 0.10;

    final dx3 = math.sin(t * math.pi * 2 * 0.62 + 2.3) * r * 0.09;
    final dy3 = math.cos(t * math.pi * 2 * 0.62 + 2.3) * r * 0.09;

    blob(c.translate(-r * 0.30 + dx1, -r * 0.22 + dy1), r * 0.62, base1, 0.55);
    blob(c.translate(r * 0.28 + dx2, r * 0.18 + dy2), r * 0.74, base2, 0.50);
    blob(c.translate(-r * 0.03 + dx3, r * 0.34 + dy3), r * 0.54, base3, 0.22);

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.95,
        colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
        stops: const [0.72, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, vignette);
  }

  @override
  bool shouldRepaint(covariant _ZenBackdropPainter old) {
    return old.t != t || old.base1 != base1 || old.base2 != base2 || old.base3 != base3;
  }
}

// ============================ Glass card + vortex ============================

class _ZenGlassVortexCard extends StatelessWidget {
  final double size;
  final _ZenPalette palette;
  final double t;
  final double progress01;
  final double pulse01;

  final int day;
  final String dayLabel;
  final String phaseLabel;

  final double vortexIntensity01;

  const _ZenGlassVortexCard({
    required this.size,
    required this.palette,
    required this.t,
    required this.progress01,
    required this.pulse01,
    required this.day,
    required this.dayLabel,
    required this.phaseLabel,
    required this.vortexIntensity01,
  });

  @override
  Widget build(BuildContext context) {
    final r = size / 2;

    final glowOpacity = (0.10 + 0.10 * pulse01) * (0.55 + 0.45 * progress01);

    final dayFont = size * 0.23;
    final labelFont = size * 0.038;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            blurRadius: 46,
            color: palette.accent.withOpacity(glowOpacity),
          ),
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 18),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          children: [
            // ✅ DENSE FAST VORTEX
            CustomPaint(
              size: Size.square(size),
              painter: _ZenVortexPainter(
                t: t,
                a: palette.a,
                b: palette.b,
                c: palette.c,
                intensity01: vortexIntensity01,
              ),
            ),

            // Glass overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white.withOpacity(0.42), width: 1),
                  borderRadius: BorderRadius.circular(r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size.square(size),
                        painter: _ZenInnerRingPainter(
                          accent: palette.accent,
                          progress01: progress01,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size * 0.12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$day",
                            style: TextStyle(
                              fontSize: dayFont,
                              fontWeight: FontWeight.w200,
                              letterSpacing: -1.2,
                              height: 0.95,
                              color: Colors.white.withOpacity(0.96),
                              shadows: [
                                Shadow(
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                  color: Colors.black.withOpacity(0.14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dayLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: labelFont,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.2,
                              color: Colors.white.withOpacity(0.72),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "ZEN MODE",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: labelFont * 0.95,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ZenChip(label: phaseLabel, accent: palette.accent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dense + fast vortex painter:
/// - More ribbons (12 + extra micro layer)
/// - Faster rotation
/// - Slight turbulence
/// - Phase intensity controls opacity/energy
class _ZenVortexPainter extends CustomPainter {
  final double t;
  final Color a;
  final Color b;
  final Color c;
  final double intensity01;

  const _ZenVortexPainter({
    required this.t,
    required this.a,
    required this.b,
    required this.c,
    required this.intensity01,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final R = math.min(size.width, size.height) / 2;

    // Faster rotation (but still smooth)
    final rot = (t * math.pi * 2) * 0.42;

    // Stronger energy with intensity
    final energy = (0.70 + 0.55 * intensity01).clamp(0.6, 1.25);

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withOpacity(0.01));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);
    canvas.translate(-center.dx, -center.dy);

    final ringRect = Rect.fromCircle(center: center, radius: R * 0.94);

    final sweep = SweepGradient(
      colors: [
        a.withOpacity(0.62),
        b.withOpacity(0.62),
        c.withOpacity(0.58),
        a.withOpacity(0.62),
      ],
      stops: const [0.0, 0.34, 0.70, 1.0],
      transform: GradientRotation(-rot * 0.8),
    );

    // Main ribbons (denser)
    for (int i = 0; i < 12; i++) {
      final k = i / 11.0;
      final radius = lerpDouble(R * 0.10, R * 0.88, k)!;

      final wobble = math.sin((t * math.pi * 2 * 1.35) + i * 0.85) * (R * 0.014 * energy);
      final rr = radius + wobble;

      final stroke = lerpDouble(R * 0.17, R * 0.052, k)!;
      final alpha = (0.16 + 0.24 * (1.0 - k)) * (0.82 + 0.28 * intensity01);
      final blur = stroke * (0.52 + 0.18 * intensity01);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = sweep.createShader(ringRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
        ..blendMode = BlendMode.screen
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(alpha.clamp(0.0, 0.55)),
          BlendMode.modulate,
        );

      final start = (-math.pi / 2) + (t * math.pi * 2 * 0.85) + i * 0.18;
      final sweepA = math.pi * (1.55 + 0.28 * math.sin(t * math.pi * 2 * 1.1 + i));
      canvas.drawArc(Rect.fromCircle(center: center, radius: rr), start, sweepA, false, paint);
    }

    // Micro layer (thin threads) — makes it look “dense”
    for (int i = 0; i < 18; i++) {
      final k = i / 17.0;
      final radius = lerpDouble(R * 0.18, R * 0.90, k)!;

      final wobble = math.cos((t * math.pi * 2 * 1.9) + i * 0.7) * (R * 0.010 * energy);
      final rr = radius + wobble;

      final stroke = lerpDouble(R * 0.030, R * 0.010, k)!;
      final alpha = (0.08 + 0.12 * (1.0 - k)) * (0.80 + 0.35 * intensity01);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = sweep.createShader(ringRect)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.9)
        ..blendMode = BlendMode.screen
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(alpha.clamp(0.0, 0.30)),
          BlendMode.modulate,
        );

      final start = (-math.pi / 2) + (t * math.pi * 2 * 1.25) + i * 0.22;
      final sweepA = math.pi * (0.95 + 0.20 * math.sin(t * math.pi * 2 * 1.6 + i));
      canvas.drawArc(Rect.fromCircle(center: center, radius: rr), start, sweepA, false, paint);
    }

    canvas.restore();

    // Center glow (stronger with intensity)
    final centerGlow = Paint()
      ..shader = RadialGradient(
        radius: 1.0,
        colors: [
          Colors.white.withOpacity(0.12 + 0.06 * intensity01),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: R * 0.78))
      ..blendMode = BlendMode.screen;

    canvas.drawCircle(center, R * 0.78, centerGlow);

    // Edge fade (contains chaos)
    final edge = Paint()
      ..shader = RadialGradient(
        radius: 0.98,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.12),
        ],
        stops: const [0.68, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: R));
    canvas.drawCircle(center, R, edge);
  }

  @override
  bool shouldRepaint(covariant _ZenVortexPainter old) {
    return old.t != t ||
        old.a != a ||
        old.b != b ||
        old.c != c ||
        old.intensity01 != intensity01;
  }
}

// ============================ Inner progress ring ============================

class _ZenInnerRingPainter extends CustomPainter {
  final Color accent;
  final double progress01;

  const _ZenInnerRingPainter({required this.accent, required this.progress01});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;

    final rr = r * 0.78;
    final rect = Rect.fromCircle(center: c, radius: rr);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.10);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, track);

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = _mix(accent, Colors.white, 0.15).withOpacity(0.45);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress01.clamp(0.0, 1.0), false, prog);
  }

  @override
  bool shouldRepaint(covariant _ZenInnerRingPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.progress01 != progress01;
  }
}

// ============================ Chip ============================

class _ZenChip extends StatelessWidget {
  final String label;
  final Color accent;

  const _ZenChip({
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = math.min(MediaQuery.of(context).size.width, 420.0) * 0.62;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.60), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _mix(accent, Colors.white, 0.18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: accent.withOpacity(0.22),
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
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Colors.white.withOpacity(0.92),
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
