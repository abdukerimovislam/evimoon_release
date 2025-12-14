import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';
import '../providers/coc_provider.dart';

class PillBlisterCard extends StatelessWidget {
  const PillBlisterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = Provider.of<CycleProvider>(context);
    final coc = Provider.of<COCProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final int currentDay = cycle.currentData.currentDay;
    final int packSize = coc.pillCount;
    const int totalGridSlots = 28;

    final int breakDaysCount = cycle.avgPeriodDuration;
    final int activePillsCount = (packSize == 28) ? (28 - breakDaysCount) : 21;
    final DateTime cycleStart = cycle.currentData.cycleStartDate;

    // 🔥 ИСПРАВЛЕНИЕ: Добавили Padding вокруг всего содержимого
    return Padding(
      padding: const EdgeInsets.all(20.0), // Отступ 20 пикселей от краев стекла
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и статус
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Expanded предотвратит наезд текста друг на друга на узких экранах
                child: Text(
                  packSize == 21 ? l10n.blister21 : l10n.blister28,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentDay > 28 ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentDay > 28
                      ? l10n.blisterOverdue(currentDay)
                      : l10n.blisterDay(currentDay, 28),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: currentDay > 28 ? Colors.red : AppColors.primary
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Сетка Блистера
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final int pillNumber = index + 1;
              final bool isVoid = (packSize == 21 && pillNumber > 21);
              final bool isActiveType = pillNumber <= activePillsCount;
              final bool isCurrentDay = pillNumber == currentDay;
              final DateTime pillDate = cycleStart.add(Duration(days: pillNumber - 1));
              final bool isTaken = coc.isTakenOnDate(pillDate);

              return _PillItem(
                number: pillNumber,
                isActiveType: isActiveType,
                isVoid: isVoid,
                isCurrentDay: isCurrentDay,
                isTaken: isTaken,
                onTap: () {
                  if (isVoid) return;
                  if (pillNumber <= currentDay) {
                    HapticFeedback.mediumImpact();
                    if (isTaken) coc.undoTakePillOnDate(pillDate);
                    else coc.takePillOnDate(pillDate);
                  } else {
                    HapticFeedback.lightImpact();
                  }
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // Легенда
          // Оборачиваем в FittedBox, чтобы легенда сжималась на очень маленьких экранах, а не ломалась
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.teal, label: l10n.legendTaken),
                const SizedBox(width: 15),
                _LegendItem(color: AppColors.primary, label: l10n.legendActive),
                if (packSize == 28) ...[
                  const SizedBox(width: 15),
                  _LegendItem(color: Colors.redAccent, label: l10n.legendPlacebo),
                ] else ...[
                  const SizedBox(width: 15),
                  _LegendItem(color: Colors.grey, label: l10n.legendBreak),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ... _PillItem и _LegendItem остаются без изменений (они у тебя уже хорошие) ...

class _PillItem extends StatelessWidget {
  final int number;
  final bool isActiveType;
  final bool isVoid;
  final bool isCurrentDay;
  final bool isTaken;
  final VoidCallback onTap;

  const _PillItem({
    required this.number,
    required this.isActiveType,
    required this.isVoid,
    required this.isCurrentDay,
    required this.isTaken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isVoid) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.05),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: isCurrentDay
            ? const Icon(Icons.pause_circle_outline, size: 18, color: Colors.grey)
            : null,
      );
    }

    Gradient? gradient;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.grey;
    List<BoxShadow> shadows = [];
    Widget? icon;

    if (isTaken) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isActiveType
            ? [Colors.tealAccent.shade400, Colors.teal]
            : [Colors.redAccent.shade100, Colors.redAccent],
      );
      shadows = [
        BoxShadow(color: (isActiveType ? Colors.teal : Colors.redAccent).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))
      ];
      icon = const Icon(Icons.check, size: 18, color: Colors.white);

    } else {
      if (isActiveType) {
        if (isCurrentDay) {
          gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.primary.withOpacity(0.1)],
          );
          borderColor = AppColors.primary;
          textColor = AppColors.primary;
          shadows = [
            BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)
          ];
        } else {
          gradient = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withOpacity(0.9), Colors.grey.withOpacity(0.1)],
          );
          borderColor = AppColors.primary.withOpacity(0.3);
          textColor = AppColors.primary.withOpacity(0.6);
        }
      } else {
        if (isCurrentDay) {
          borderColor = Colors.redAccent;
          textColor = Colors.redAccent;
          gradient = LinearGradient(colors: [Colors.white, Colors.red.withOpacity(0.05)]);
        } else {
          borderColor = Colors.red.withOpacity(0.2);
          textColor = Colors.red.withOpacity(0.4);
          gradient = LinearGradient(colors: [Colors.white.withOpacity(0.8), Colors.red.withOpacity(0.05)]);
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          border: Border.all(
              color: isCurrentDay && !isTaken ? borderColor : borderColor.withOpacity(0.5),
              width: isCurrentDay && !isTaken ? 2 : 1
          ),
          boxShadow: shadows,
        ),
        alignment: Alignment.center,
        child: icon ?? Text(
          "$number",
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)]
            )
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}