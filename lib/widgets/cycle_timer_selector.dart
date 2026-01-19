import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cycle_model.dart';
import '../providers/settings_provider.dart';
import '../models/timer_design.dart';

// Импорты таймеров
import 'cycle_timer_widget.dart'; // Classic
import 'timers/minimal_timer_widget.dart'; // Minimal
import 'timers/lunar_timer_widget.dart';
import 'timers/bloom_timer_widget.dart';
import 'timers/liquid_timer_widget.dart';
import 'timers/orbit_timer_widget.dart';
import 'timers/zen_timer_widget.dart';

class CycleTimerSelector extends StatelessWidget {
  final CycleData data;
  final bool isCOC;

  const CycleTimerSelector({
    super.key,
    required this.data,
    this.isCOC = false
  });

  @override
  Widget build(BuildContext context) {
    final currentDesign = context.select<SettingsProvider, TimerDesign>(
            (s) => s.currentDesign
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInBack,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildSelectedTimer(currentDesign),
    );
  }

  Widget _buildSelectedTimer(TimerDesign design) {
    // Используем Minimal как заглушку для пока не созданных таймеров
    switch (design) {
      case TimerDesign.classic:
        return ClassicTimerWidget(key: const ValueKey('classic'), data: data, isCOC: isCOC);

      case TimerDesign.minimal:
        return MinimalTimerWidget(key: const ValueKey('minimal'), data: data, isCOC: isCOC);

      case TimerDesign.lunar:
      // return LunarTimerWidget(key: const ValueKey('lunar'), data: data, isCOC: isCOC);
        return LunarTimerWidget(key: const ValueKey('lunar_stub'), data: data, isCOC: isCOC); // Заглушка

      case TimerDesign.bloom:
      // return BloomTimerWidget(key: const ValueKey('bloom'), data: data, isCOC: isCOC);
        return BloomTimerWidget(key: const ValueKey('bloom_stub'), data: data, isCOC: isCOC); // Заглушка

      case TimerDesign.liquid:
      // return LiquidTimerWidget(key: const ValueKey('liquid'), data: data, isCOC: isCOC);
        return LiquidTimerWidget(key: const ValueKey('liquid_stub'), data: data, isCOC: isCOC); // Заглушка

      case TimerDesign.orbit:
      // return OrbitTimerWidget(key: const ValueKey('orbit'), data: data, isCOC: isCOC);
        return OrbitTimerWidget(key: const ValueKey('orbit_stub'), data: data, isCOC: isCOC); // Заглушка

      case TimerDesign.zen:
      // return ZenTimerWidget(key: const ValueKey('zen'), data: data, isCOC: isCOC);
        return ZenTimerWidget(key: const ValueKey('zen_stub'), data: data, isCOC: isCOC); // Заглушка
    }
  }
}