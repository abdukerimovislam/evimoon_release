import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/cycle_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// OrbitTimerWidget — Premium Apple-style “Orbit” timer (EviMoon)
/// ✅ Light / airy / iOS feel (works on light gradient backgrounds)
/// ✅ Planet position = cycle progress (day / total)
/// ✅ Polished glass center + subtle orbit sheen + tiny sparkles
/// ✅ Accent follows phase.color (softened for iOS look)
/// ✅ Safe layout (no overflows on small screens)
class OrbitTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const OrbitTimerWidget({
    super.key,
    required this.data,
    this.isCOC = false,
  });

  @override
  State<OrbitTimerWidget> createState() => _OrbitTimerWidgetState();
}

class _OrbitTimerWidgetState extends State<OrbitTimerWidget>
    with TickerProviderStateMixin {
  late final AnimationController _loop;
  late final AnimationController _progressCtrl;

  late Animation<double> _progressAnim;
  double _prevProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8600),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _prevProgress = _cycleProgress01(widget.data);
    _progressAnim = Tween<double>(begin: _prevProgress, end: _prevProgress).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubic),
    );
    _progressCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant OrbitTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final next = _cycleProgress01(widget.data);
    if ((next - _prevProgress).abs() > 0.0001) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: next,
      ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubic));

      _progressCtrl
        ..value = 0
        ..forward();

      _prevProgress = next;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _progressCtrl.dispose();
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
    final progress = _progressAnim;

    final phaseLabel = _getPhaseName(widget.data.phase, l10n, widget.isCOC).toUpperCase();

    return LayoutBuilder(
      builder: (context, c) {
        final maxSide = math.min(
          c.maxWidth.isFinite ? c.maxWidth : 340.0,
          c.maxHeight.isFinite ? c.maxHeight : 340.0,
        );
        final size = maxSide.clamp(260.0, 420.0);

        return SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_loop, _progressCtrl]),
            builder: (_, __) {
              final t = _loop.value;
              final p = progress.value;

              final breath = (math.sin(t * math.pi * 2) * 0.5 + 0.5);
              final breathK = Curves.easeInOut.transform(breath);

              final orbitR = size * 0.36;
              final innerR = size * 0.25;
              final outerR = size * 0.43;

              // Planet angle: day progress (start at top)
              final baseAngle = (p * 2 * math.pi) - (math.pi / 2);

              // Slight orbit precession (premium motion, not "spinner")
              final precession = math.sin(t * math.pi * 2) * 0.06;
              final angle = baseAngle + precession;

              final planetPos = Offset(
                orbitR * math.cos(angle),
                orbitR * math.sin(angle),
              );

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Orbits + sheen + subtle particles
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _OrbitSystemPainter(
                        t: t,
                        accent: accent,
                        orbitR: orbitR,
                        innerR: innerR,
                        outerR: outerR,
                        progress01: p,
                      ),
                    ),
                  ),

                  // Planet (glass orb)
                  Transform.translate(
                    offset: planetPos,
                    child: _PlanetOrb(
                      size: size,
                      accent: accent,
                      pulse01: breathK,
                    ),
                  ),

                  // Center star (glass)
                  _CenterStar(
                    size: size,
                    accent: accent,
                    day: widget.data.currentDay,
                    dayLabel: l10n.dayTitle.toUpperCase(),
                    phaseLabel: phaseLabel,
                    progress01: p,
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

// ============================ Visual helpers ============================

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;

/// iOS-friendly accent: brighter & slightly cooler, works on light backgrounds.
Color _softenAccent(Color c) {
  final bright = _mix(c, Colors.white, 0.38);
  final cool = _mix(bright, const Color(0xFFBFD6FF), 0.10);
  return cool;
}

// ============================ Orbits painter ============================

class _OrbitSystemPainter extends CustomPainter {
  final double t;
  final Color accent;
  final double orbitR;
  final double innerR;
  final double outerR;
  final double progress01;

  const _OrbitSystemPainter({
    required this.t,
    required this.accent,
    required this.orbitR,
    required this.innerR,
    required this.outerR,
    required this.progress01,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);

    // Base orbit strokes (super subtle)
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = Colors.black.withOpacity(0.045);

    canvas.drawCircle(c, innerR, basePaint);
    canvas.drawCircle(c, orbitR, basePaint..color = Colors.black.withOpacity(0.055));
    canvas.drawCircle(c, outerR, basePaint..color = Colors.black.withOpacity(0.040));

    // Sheen sweep around main orbit (polished glass vibe)
    final rect = Rect.fromCircle(center: c, radius: orbitR);
    final rot = (t * math.pi * 2) - math.pi / 3;

    final sweep = SweepGradient(
      startAngle: rot,
      endAngle: rot + math.pi * 2,
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.34),
        _mix(accent, Colors.white, 0.60).withOpacity(0.20),
        Colors.transparent,
      ],
      stops: const [0.00, 0.14, 0.26, 0.38],
    );

    final sheen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(rect, 0, math.pi * 2, false, sheen);

    // Progress arc on orbit (thin, premium)
    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = _mix(accent, Colors.white, 0.08).withOpacity(0.78);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      (math.pi * 2) * progress01.clamp(0.0, 1.0),
      false,
      prog,
    );

    // Micro sparkles (few, subtle)
    _drawSparkles(canvas, size, c);
  }

  void _drawSparkles(Canvas canvas, Size size, Offset c) {
    final r = math.min(size.width, size.height) / 2;

    void sparkle(double phase, double radius, double alpha) {
      final a = (-math.pi / 2) + (math.pi * 2) * (t * 0.35 + phase);
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));

      final glow = Paint()
        ..color = Colors.white.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(p, 3.0, glow);

      final core = Paint()..color = Colors.white.withOpacity((alpha * 1.25).clamp(0.0, 1.0));
      canvas.drawCircle(p, 1.1, core);
    }

    sparkle(0.12, r * 0.72, 0.10);
    sparkle(0.58, r * 0.62, 0.07);
  }

  @override
  bool shouldRepaint(covariant _OrbitSystemPainter old) {
    return old.t != t ||
        old.accent != accent ||
        old.orbitR != orbitR ||
        old.innerR != innerR ||
        old.outerR != outerR ||
        old.progress01 != progress01;
  }
}

// ============================ Planet ============================

class _PlanetOrb extends StatelessWidget {
  final double size;
  final Color accent;
  final double pulse01;

  const _PlanetOrb({
    required this.size,
    required this.accent,
    required this.pulse01,
  });

  @override
  Widget build(BuildContext context) {
    final s = size * 0.085; // planet diameter
    final glow = 0.10 + 0.10 * pulse01;

    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            color: accent.withOpacity(glow),
          ),
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 1.1,
                colors: [
                  Colors.white.withOpacity(0.95),
                  _mix(accent, Colors.white, 0.55).withOpacity(0.65),
                  _mix(accent, Colors.white, 0.20).withOpacity(0.35),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
            ),
            child: Align(
              alignment: const Alignment(-0.35, -0.35),
              child: Container(
                width: s * 0.28,
                height: s * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================ Center star (glass) ============================

class _CenterStar extends StatelessWidget {
  final double size;
  final Color accent;
  final int day;
  final String dayLabel;
  final String phaseLabel;
  final double progress01;
  final double pulse01;

  const _CenterStar({
    required this.size,
    required this.accent,
    required this.day,
    required this.dayLabel,
    required this.phaseLabel,
    required this.progress01,
    required this.pulse01,
  });

  @override
  Widget build(BuildContext context) {
    final core = size * 0.36;

    const primary = Color(0xFF0B1020);
    final secondary = primary.withOpacity(0.56);

    final glowOpacity = (0.10 + 0.10 * pulse01) * (0.65 + 0.35 * progress01);

    final dayFont = core * 0.40;
    final labelFont = core * 0.075;

    return Container(
      width: core,
      height: core,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 34,
            color: accent.withOpacity(glowOpacity),
          ),
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 18),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.64),
              border: Border.all(color: Colors.white.withOpacity(0.88), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    fontSize: dayFont,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                    height: 0.95,
                    color: primary,
                    shadows: [
                      Shadow(
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.07),
                      ),
                    ],
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

// ============================ Phase chip ============================

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
