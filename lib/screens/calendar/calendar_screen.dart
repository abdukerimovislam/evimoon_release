import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../l10n/app_localizations.dart';

// Импорты наших модулей
import '../calendar/calendar_visuals.dart';
import '../calendar/calendar_2d_view.dart';
import '../calendar/time_tunnel_painter.dart';
import '../calendar/calendar_day_details.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  // 2D Calendar State
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _bgOffset = 0.0;

  // 3D Time Tunnel State
  bool _isTimeTunnelMode = false;
  double _tunnelScrollOffset = 0.0;
  late AnimationController _tunnelResetController;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _tunnelResetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _tunnelResetController.dispose();
    super.dispose();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _bgOffset += 0.2;
      if (_bgOffset > 1.0) _bgOffset = -1.0;
    });
  }

  void _resetTunnelToToday() {
    _tunnelResetController.reset();
    final startOffset = _tunnelScrollOffset;
    Animation<double> animation = Tween<double>(begin: startOffset, end: 0.0).animate(CurvedAnimation(parent: _tunnelResetController, curve: Curves.easeOutBack));
    animation.addListener(() {
      setState(() {
        _tunnelScrollOffset = animation.value;
        _updateActiveFocus();
      });
    });
    _tunnelResetController.forward();
  }

  // Active Focus Logic (Авто-выбор дня в 3D)
  void _updateActiveFocus() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final int daysShift = _tunnelScrollOffset.round();
    final newSelectedDay = normalizedToday.add(Duration(days: daysShift));

    if (!isSameDay(_selectedDay, newSelectedDay)) {
      setState(() {
        _selectedDay = newSelectedDay;
        _focusedDay = newSelectedDay;
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final wellnessProvider = Provider.of<WellnessProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final currentCycleStart = cycleProvider.currentData.cycleStartDate;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isTimeTunnelMode ? "TIME TUNNEL" : l10n.tabCalendar,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1.0),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Icon(_isTimeTunnelMode ? CupertinoIcons.grid : CupertinoIcons.timelapse, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _isTimeTunnelMode = !_isTimeTunnelMode;
                if (_isTimeTunnelMode) {
                  _tunnelScrollOffset = 0.0;
                  _selectedDay = DateTime.now();
                }
              });
            },
          ),
          if (_isTimeTunnelMode)
            IconButton(icon: const Icon(Icons.today_rounded, color: AppColors.textPrimary), onPressed: _resetTunnelToToday)
        ],
      ),
      body: Stack(
        children: [
          // 🔥 ИСПРАВЛЕНО: Фон теперь всегда светлый (isDark: false), даже в режиме туннеля
          ParallaxBackground(offset: _bgOffset, isDark: false),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation.drive(Tween(begin: 0.9, end: 1.0)), child: child)),
              child: _isTimeTunnelMode
              // 🔮 3D VIEW
                  ? _buildTimeTunnelView(context, cycleProvider, wellnessProvider, currentCycleStart)
              // 📅 2D VIEW
                  : Column(
                key: const ValueKey('classic'),
                children: [
                  Calendar2DView(
                    l10n: l10n,
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    cycleProvider: cycleProvider,
                    wellnessProvider: wellnessProvider,
                    currentCycleStart: currentCycleStart,
                    onDaySelected: (selected, focused) => setState(() { _selectedDay = selected; _focusedDay = focused; }),
                    onFormatChanged: (format) { if (_calendarFormat != format) setState(() => _calendarFormat = format); },
                    onPageChanged: _onPageChanged,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: CalendarLegend()),
                  Expanded(child: CalendarDayDetails(date: _selectedDay!, cycle: cycleProvider, wellness: wellnessProvider)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTunnelView(BuildContext context, CycleProvider cycle, WellnessProvider wellness, DateTime currentCycleStart) {
    return KeyedSubtree(
      key: const ValueKey('tunnel'),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  // Чувствительность скролла
                  _tunnelScrollOffset -= details.delta.dy * 0.015;
                  _updateActiveFocus();
                });
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                  borderRadius: BorderRadius.circular(30),
                  // Легкий градиент для "объема", но прозрачный
                  gradient: RadialGradient(
                      colors: [Colors.transparent, AppColors.primary.withOpacity(0.1)],
                      stops: const [0.6, 1.0]
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CustomPaint(
                    painter: TimeTunnelPainter(
                      scrollOffset: _tunnelScrollOffset,
                      provider: cycle,
                      wellnessProvider: wellness,
                      selectedDay: _selectedDay!,
                      currentCycleStart: currentCycleStart,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          // HUD Панель
          Expanded(flex: 2, child: CalendarDayDetails(date: _selectedDay!, cycle: cycle, wellness: wellness)),
        ],
      ),
    );
  }
}