import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';
import '../../../models/personal_model.dart';
import '../../../models/cycle_model.dart';
import '../../../providers/wellness_provider.dart';
import '../../../providers/cycle_provider.dart'; // Нужно для подтверждения овуляции

// --- ГЛАССМОРФИЗМ ОБЕРТКА (Blur) ---
class _GlassModalWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;

  const _GlassModalWrapper({
    required this.title,
    required this.child,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Эффект стекла
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Почти непрозрачный белый для читаемости
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.5))),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор шторки
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),

              Text(
                title,
                style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              child, // Контент

              if (onSave != null) ...[
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      l10n.btnSave,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// --- 1. ТЕМПЕРАТУРА (РУЛЕТКА / WHEEL) ---
class BBTModal extends StatefulWidget {
  final DateTime date;
  const BBTModal({super.key, required this.date});

  @override
  State<BBTModal> createState() => _BBTModalState();
}

class _BBTModalState extends State<BBTModal> {
  late FixedExtentScrollController _controller;
  double _selectedTemp = 36.6;
  final double _minTemp = 35.0;

  @override
  void initState() {
    super.initState();
    final log = context.read<WellnessProvider>().getLogForDate(widget.date);
    if (log.temperature != null && log.temperature! > 0) {
      _selectedTemp = log.temperature!;
    }
    // Вычисляем индекс: (36.6 - 35.0) * 10 = 16
    int initialItem = ((_selectedTemp - _minTemp) * 10).round();
    _controller = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final provider = context.read<WellnessProvider>();
    final log = provider.getLogForDate(widget.date);
    provider.saveLog(log.copyWith(temperature: _selectedTemp));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _GlassModalWrapper(
      title: l10n.titleInputBBT,
      onSave: _save,
      child: SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Фон активного элемента
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Рулетка
            ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 45,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              diameterRatio: 1.2,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedTemp = _minTemp + (index / 10);
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 71, // (42.0 - 35.0) * 10 + 1 запас
                builder: (context, index) {
                  final value = _minTemp + (index / 10);
                  final isSelected = value.toStringAsFixed(1) == _selectedTemp.toStringAsFixed(1);
                  return Center(
                    child: Text(
                      "${value.toStringAsFixed(1)}°C",
                      style: GoogleFonts.manrope(
                        fontSize: isSelected ? 28 : 22,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : Colors.grey[400],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. ТЕСТ ЛГ ---
class TestModal extends StatelessWidget {
  final DateTime date;
  const TestModal({super.key, required this.date});

  void _save(BuildContext context, OvulationTestResult result) {
    // 1. Сохраняем в велнес
    final provider = context.read<WellnessProvider>();
    final log = provider.getLogForDate(date);
    provider.saveLog(log.copyWith(ovulationTest: result));

    // 2. 🔥 Если тест положительный — обновляем цикл
    if (result == OvulationTestResult.positive || result == OvulationTestResult.peak) {
      // Предполагаем овуляцию завтра
      final estimatedOvulation = date.add(const Duration(days: 1));
      context.read<CycleProvider>().confirmOvulation(estimatedOvulation);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("LH Peak recorded! Cycle updated."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          )
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.read<WellnessProvider>().getLogForDate(date).ovulationTest;

    return _GlassModalWrapper(
      title: l10n.titleInputTest,
      child: Column(
        children: [
          _SelectableCard(
            label: l10n.chipNegative,
            isSelected: current == OvulationTestResult.negative,
            color: Colors.grey,
            onTap: () => _save(context, OvulationTestResult.negative),
          ),
          const SizedBox(height: 12),
          _SelectableCard(
            label: l10n.chipPositive,
            isSelected: current == OvulationTestResult.positive,
            color: TTCTheme.statusTest,
            icon: CupertinoIcons.add,
            onTap: () => _save(context, OvulationTestResult.positive),
          ),
          const SizedBox(height: 12),
          _SelectableCard(
            label: l10n.chipPeak,
            isSelected: current == OvulationTestResult.peak,
            color: Colors.purpleAccent,
            icon: CupertinoIcons.flame_fill,
            onTap: () => _save(context, OvulationTestResult.peak),
          ),
          if (current != OvulationTestResult.none) ...[
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _save(context, OvulationTestResult.none),
              child: const Text("Reset", style: TextStyle(color: Colors.grey)),
            )
          ]
        ],
      ),
    );
  }
}

// --- 3. СЕКС ---
class SexModal extends StatelessWidget {
  final DateTime date;
  const SexModal({super.key, required this.date});

  void _save(BuildContext context, bool hadSex) {
    final provider = context.read<WellnessProvider>();
    final log = provider.getLogForDate(date);
    provider.saveLog(log.copyWith(hadSex: hadSex));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.read<WellnessProvider>().getLogForDate(date).hadSex;

    return _GlassModalWrapper(
      title: l10n.titleInputSex,
      child: Row(
        children: [
          Expanded(
            child: _SelectableCard(
              label: l10n.labelSexNo,
              isSelected: !current,
              color: Colors.grey,
              height: 100,
              icon: CupertinoIcons.xmark,
              onTap: () => _save(context, false),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SelectableCard(
              label: l10n.labelSexYes,
              isSelected: current,
              color: TTCTheme.cardSex,
              height: 100,
              icon: CupertinoIcons.heart_fill,
              onTap: () => _save(context, true),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 4. ВЫДЕЛЕНИЯ ---
class MucusModal extends StatelessWidget {
  final DateTime date;
  const MucusModal({super.key, required this.date});

  void _save(BuildContext context, CervicalMucusType type) {
    final provider = context.read<WellnessProvider>();
    final log = provider.getLogForDate(date);
    provider.saveLog(log.copyWith(mucus: type));
    Navigator.pop(context);
  }

  String _name(CervicalMucusType t, AppLocalizations l) {
    switch(t) {
      case CervicalMucusType.dry: return l.mucusDry;
      case CervicalMucusType.sticky: return l.mucusSticky;
      case CervicalMucusType.creamy: return l.mucusCreamy;
      case CervicalMucusType.watery: return l.mucusWatery;
      case CervicalMucusType.eggWhite: return l.mucusEggWhite;
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final current = context.read<WellnessProvider>().getLogForDate(date).mucus;

    return _GlassModalWrapper(
      title: l10n.titleInputMucus,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: CervicalMucusType.values.where((e) => e != CervicalMucusType.none).map((type) {
          final isSelected = current == type;
          return GestureDetector(
            onTap: () => _save(context, type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Text(
                _name(type, l10n),
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --- UI Helper: Карточка выбора ---
class _SelectableCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;

  const _SelectableCard({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.icon,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.2),
              width: isSelected ? 0 : 1
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}