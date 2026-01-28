import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для вибрации
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart'; // Для дат
import 'dart:ui'; // Для ImageFilter (Blur)
import 'dart:math' as math;

import '../models/cycle_model.dart';
import '../theme/app_theme.dart';

// 🔥 ИЗМЕНЕНИЕ: Переименовали класс
class ClassicTimerWidget extends StatefulWidget {
  final CycleData data;
  final bool isCOC;

  const ClassicTimerWidget({super.key, required this.data, this.isCOC = false});

  @override
  State<ClassicTimerWidget> createState() => ClassicTimerWidgetState();
}

// 🔥 ИЗМЕНЕНИЕ: Переименовали State класс
class ClassicTimerWidgetState extends State<ClassicTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _projectionCtrl;
  late AnimationController _boostCtrl;

  int? _selectedDay;
  bool _isDragging = false;
  bool _isProjectionVisible = false;

  // Флаг для авто-анимации
  bool _isIntroPlaying = false;

  @override
  void initState() {
    super.initState();
    _rotateCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
    _pulseCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    // Контроллер "Астральной проекции"
    _projectionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _boostCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    // ЗАПУСК АВТОМАТИЧЕСКОЙ АНИМАЦИИ
    _runIntroSequence();
  }

  @override
  void didUpdateWidget(covariant ClassicTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool modeChanged = oldWidget.isCOC != widget.isCOC;

    final bool dataChanged =
        oldWidget.data.cycleStartDate != widget.data.cycleStartDate ||
            oldWidget.data.currentDay != widget.data.currentDay ||
            oldWidget.data.totalCycleLength != widget.data.totalCycleLength ||
            oldWidget.data.periodDuration != widget.data.periodDuration ||
            oldWidget.data.phase != widget.data.phase ||
            oldWidget.data.daysUntilNextPeriod != widget.data.daysUntilNextPeriod ||
            oldWidget.data.isFertile != widget.data.isFertile;

    if (modeChanged || dataChanged) {
      _syncWithNewData(resetSelection: modeChanged || oldWidget.data.cycleStartDate != widget.data.cycleStartDate);
    }
  }

  void _syncWithNewData({required bool resetSelection}) {
    if (!mounted) return;

    _isIntroPlaying = false;

    setState(() {
      if (resetSelection) {
        _selectedDay = null;
      }

      if (_selectedDay != null && _selectedDay! > widget.data.totalCycleLength) {
        _selectedDay = null;
      }

      if (_isProjectionVisible) {
        _isProjectionVisible = false;
        _projectionCtrl.value = 0;
      }

      _isDragging = false;
    });
  }

  void _runIntroSequence() async {
    _isIntroPlaying = true;

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted || !_isIntroPlaying) return;

    if (!_isProjectionVisible) {
      _toggleProjection(isAuto: true);
    }

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted || !_isIntroPlaying) return;

    if (_isProjectionVisible && !_isDragging) {
      _toggleProjection(isAuto: true);
    }

    _isIntroPlaying = false;
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _projectionCtrl.dispose();
    _boostCtrl.dispose();
    super.dispose();
  }

  void spinEffect() {
    _boostCtrl.forward(from: 0).then((_) {
      if (mounted) _boostCtrl.reset();
    });
    HapticFeedback.heavyImpact();
  }

  void _handlePan(Offset localPosition, double size) {
    if (_isProjectionVisible) return;

    if (_isIntroPlaying) {
      _isIntroPlaying = false;
    }

    final center = Offset(size / 2, size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = math.atan2(dy, dx);
    angle += math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    final totalDays = widget.data.totalCycleLength;
    int dayIndex = (angle / (2 * math.pi) * totalDays).round();
    if (dayIndex == 0) dayIndex = totalDays;
    if (dayIndex > totalDays) dayIndex = 1;

    if (_selectedDay != dayIndex) {
      setState(() {
        _selectedDay = dayIndex;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _toggleProjection({bool isAuto = false}) {
    if (isAuto) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    setState(() {
      _isProjectionVisible = !_isProjectionVisible;
      if (_isProjectionVisible) {
        _projectionCtrl.forward();
      } else {
        _projectionCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayDay = _selectedDay ?? widget.data.currentDay;

    CyclePhase displayPhase;
    if (_selectedDay == null) {
      displayPhase = widget.data.phase;
    } else {
      final phases = _calculatePhases(widget.data.totalCycleLength);
      displayPhase = _getPhaseForDay(displayDay, phases);
    }

    final displayColor = _getColor(displayPhase, widget.isCOC);
    final displayName = _getName(context, displayPhase, l10n, widget.isCOC);

    final today = DateTime.now();
    final dateOffset = displayDay - widget.data.currentDay;
    final displayDate = today.add(Duration(days: dateOffset));
    final dateString = DateFormat('d MMM').format(displayDate);

    final insights = _getDailyInsights(displayPhase, l10n, widget.isCOC);

    final phasesForDots = _calculatePhases(widget.data.totalCycleLength);

    return SizedBox(
      width: 340,
      height: 340,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --- СЛОЙ 1: ФОН (СПИРОГРАФ) ---
          AnimatedBuilder(
            animation: Listenable.merge([_rotateCtrl, _boostCtrl]),
            builder: (_, __) {
              final double boostCurve =
              Curves.easeOutExpo.transform(_boostCtrl.value);
              final double boostRotation = boostCurve * 4 * math.pi;
              final double totalRotation =
                  (_rotateCtrl.value * 2 * math.pi) + boostRotation;

              return SizedBox(
                width: 340,
                height: 340,
                child: CustomPaint(
                  painter: _SpirographPainter(
                    color: displayColor,
                    rotation: totalRotation,
                  ),
                ),
              );
            },
          ),

          // --- СЛОЙ 2: ТОЧКИ ---
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: _SmartDotsPainter(
                  totalDays: widget.data.totalCycleLength,
                  currentDay: widget.data.currentDay,
                  selectedDay: _selectedDay,
                  pulse: _pulseCtrl.value,
                  phases: phasesForDots,
                  isCOC: widget.isCOC,
                ),
              ),
            ),
          ),

          // --- СЛОЙ ЖЕСТОВ ---
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              setState(() => _isDragging = true);
              _handlePan(details.localPosition, 340);
            },
            onPanUpdate: (details) => _handlePan(details.localPosition, 340),
            onPanEnd: (details) => setState(() => _isDragging = false),
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),

          // --- СЛОЙ 3: КНОПКА ЦЕНТРАЛЬНАЯ ---
          GestureDetector(
            onTap: () => _toggleProjection(isAuto: false),
            child: AnimatedBuilder(
              animation: _projectionCtrl,
              builder: (context, child) {
                return Opacity(
                  opacity: (1.0 - _projectionCtrl.value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1.0 - (_projectionCtrl.value * 0.1),
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.94),
                        boxShadow: [
                          BoxShadow(
                            color: displayColor.withOpacity(0.2),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDay == null
                                ? l10n.dayTitle.toUpperCase()
                                : dateString.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$displayDay",
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w200,
                              color: displayColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: displayColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: displayColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName.toUpperCase(),
                                    style: TextStyle(
                                      color: displayColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.touch_app_rounded,
                                  size: 10,
                                  color: displayColor.withOpacity(0.5),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- СЛОЙ 4: АСТРАЛЬНАЯ ПРОЕКЦИЯ ---
          IgnorePointer(
            ignoring: !_isProjectionVisible,
            child: GestureDetector(
              onTap: () => _toggleProjection(isAuto: false),
              child: AnimatedBuilder(
                animation: _projectionCtrl,
                builder: (context, child) {
                  final curveValue =
                  Curves.easeOutBack.transform(_projectionCtrl.value);
                  final opacityValue = _projectionCtrl.value;

                  if (opacityValue == 0) return const SizedBox();

                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5 * opacityValue,
                      sigmaY: 5 * opacityValue,
                    ),
                    child: Opacity(
                      opacity: opacityValue,
                      child: Transform.scale(
                        scale: 0.5 + (curveValue * 0.5),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.95),
                                Colors.white.withOpacity(0.85),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: displayColor.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                offset: Offset(-5, -5),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayName.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: displayColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    insights['icon'] as IconData,
                                    color: displayColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  insights['title'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Text(
                                    insights['subtitle'] as String,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (!widget.isCOC)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _StatCapsule(
                                        label: l10n.lblEnergy,
                                        level: insights['est'] as int,
                                        color: displayColor,
                                      ),
                                      const SizedBox(width: 6),
                                      _StatCapsule(
                                        label: l10n.lblMood,
                                        level: insights['prg'] as int,
                                        color: displayColor,
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.tapToClose,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDailyInsights(
      CyclePhase phase,
      AppLocalizations l10n,
      bool isCOC,
      ) {
    if (isCOC) {
      if (phase == CyclePhase.menstruation) {
        return {
          'icon': Icons.water_drop_rounded,
          'title': l10n.insightCOCBreakTitle,
          'subtitle': l10n.insightCOCBreakBody,
          'est': 1,
          'prg': 1
        };
      } else {
        return {
          'icon': Icons.shield_rounded,
          'title': l10n.insightCOCActiveTitle,
          'subtitle': l10n.insightCOCActiveBody,
          'est': 2,
          'prg': 2
        };
      }
    }

    switch (phase) {
      case CyclePhase.menstruation:
        return {
          'icon': Icons.nightlight_round,
          'title': l10n.insightMenstruationTitle,
          'subtitle': l10n.insightMenstruationSubtitle,
          'est': 1,
          'prg': 1
        };
      case CyclePhase.follicular:
        return {
          'icon': Icons.wb_sunny_rounded,
          'title': l10n.insightFollicularTitle,
          'subtitle': l10n.insightFollicularSubtitle,
          'est': 3,
          'prg': 2
        };
      case CyclePhase.ovulation:
        return {
          'icon': Icons.favorite_rounded,
          'title': l10n.insightOvulationTitle,
          'subtitle': l10n.insightOvulationSubtitle,
          'est': 3,
          'prg': 3
        };
      case CyclePhase.luteal:
        return {
          'icon': Icons.spa_rounded,
          'title': l10n.insightLutealTitle,
          'subtitle': l10n.insightLutealSubtitle,
          'est': 2,
          'prg': 2
        };
      case CyclePhase.late:
        return {
          'icon': Icons.medical_services_rounded,
          'title': l10n.insightLateTitle,
          'subtitle': l10n.insightLateSubtitle,
          'est': 1,
          'prg': 1
        };
    }
  }

  List<int> _calculatePhases(int total) {
    final mEnd = widget.data.periodDuration;
    final fEnd = (total / 2).floor() - 2;
    final oEnd = (total / 2).floor() + 3;
    return [mEnd, fEnd, oEnd];
  }

  CyclePhase _getPhaseForDay(int day, List<int> p) {
    if (day <= p[0]) return CyclePhase.menstruation;
    if (widget.isCOC) return CyclePhase.follicular;
    if (day <= p[1]) return CyclePhase.follicular;
    if (day <= p[2]) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  Color _getColor(CyclePhase phase, bool isCOC) {
    if (isCOC) {
      return phase == CyclePhase.menstruation
          ? Colors.redAccent
          : Colors.tealAccent.shade400;
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

  String _getName(
      BuildContext context,
      CyclePhase phase,
      AppLocalizations l10n,
      bool isCOC,
      ) {
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

class _StatCapsule extends StatelessWidget {
  final String label;
  final int level;
  final Color color;

  const _StatCapsule({
    required this.label,
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Row(
            children: List.generate(
              3,
                  (index) => Container(
                margin: const EdgeInsets.only(left: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < level ? color : color.withOpacity(0.2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SpirographPainter extends CustomPainter {
  final Color color;
  final double rotation;
  _SpirographPainter({required this.color, required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    double R = radius;
    double r = radius * 0.4;
    double d = radius * 0.7;

    final path = Path();

    for (double t = 0; t < 20 * math.pi; t += 0.05) {
      double x = (R - r) * math.cos(t + rotation) +
          d * math.cos(((R - r) / r) * t + rotation);
      double y = (R - r) * math.sin(t + rotation) -
          d * math.sin(((R - r) / r) * t + rotation);
      if (t == 0) {
        path.moveTo(center.dx + x, center.dy + y);
      } else {
        path.lineTo(center.dx + x, center.dy + y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SmartDotsPainter extends CustomPainter {
  final int totalDays;
  final int currentDay;
  final int? selectedDay;
  final double pulse;
  final List<int> phases;
  final bool isCOC;

  _SmartDotsPainter({
    required this.totalDays,
    required this.currentDay,
    required this.selectedDay,
    required this.pulse,
    required this.phases,
    required this.isCOC,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    for (int i = 0; i < totalDays; i++) {
      int dayNum = i + 1;
      Color dotColor;
      bool isFertile = false;

      if (isCOC) {
        if (dayNum <= phases[0]) {
          dotColor = AppColors.menstruation;
        } else {
          dotColor = AppColors.follicular;
        }
      } else {
        if (dayNum <= phases[0]) {
          dotColor = AppColors.menstruation;
        } else if (dayNum <= phases[1]) {
          dotColor = AppColors.follicular;
        } else if (dayNum <= phases[2]) {
          dotColor = AppColors.ovulation;
          isFertile = true;
        } else {
          dotColor = AppColors.luteal;
        }
      }

      final angle = (2 * math.pi / totalDays) * i - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (isFertile && !isCOC) {
        canvas.drawCircle(
          Offset(x, y),
          6,
          Paint()
            ..color = AppColors.ovulation.withOpacity(0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }

      if (selectedDay == dayNum) {
        canvas.drawCircle(Offset(x, y), 10, Paint()..color = dotColor);
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
        continue;
      }

      if (currentDay == dayNum && selectedDay == null) {
        canvas.drawCircle(
          Offset(x, y),
          12 + (pulse * 3),
          Paint()
            ..color = dotColor.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(Offset(x, y), 6, Paint()..color = dotColor);
        canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
        continue;
      }

      bool isPast = dayNum < currentDay;
      final paint = Paint()..color = isPast ? dotColor.withOpacity(0.3) : dotColor;

      canvas.drawCircle(
        Offset(x, y),
        (isFertile && !isCOC) ? 5.0 : 4.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}