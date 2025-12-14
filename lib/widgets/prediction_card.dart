import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_theme.dart';
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../providers/prediction_provider.dart';

class PredictionCard extends StatefulWidget {
  const PredictionCard({super.key});

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  // Локальное состояние "Корректировок" пользователя.
  // Если null - показываем прогноз. Если есть значение - показываем реальность.
  final Map<String, double> _overrides = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycleProvider = Provider.of<CycleProvider>(context);
    final wellnessProvider = Provider.of<WellnessProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);

    // Получаем базовый прогноз
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayLog = wellnessProvider.hasLogForDate(yesterday)
        ? wellnessProvider.getLogForDate(yesterday)
        : null;

    final baseScores = predictionProvider.calculateDailyState(
        cycleProvider.currentData,
        yesterdayLog
    );

    // Объединяем Прогноз + Корректировки пользователя
    final Map<String, double> finalScores = {
      'energy': _overrides['energy'] ?? baseScores['energy']!,
      'mood': _overrides['mood'] ?? baseScores['mood']!,
      'focus': _overrides['focus'] ?? baseScores['focus']!,
    };

    // Определяем "Главный" показатель для совета (где самое экстремальное значение)
    // Если энергия низкая - советуем про отдых. Если высокая - про спорт.
    String mainCategory = 'energy';
    if (_overrides.containsKey('mood')) mainCategory = 'mood';
    else if (_overrides.containsKey('focus')) mainCategory = 'focus';

    String hormoneText = l10n.hormoneEstrogen;

    if (cycleProvider.currentData.phase == CyclePhase.luteal) {
      hormoneText = l10n.hormoneProgesterone;
    }
    if (cycleProvider.currentData.phase == CyclePhase.menstruation) {
      hormoneText = l10n.hormoneReset;
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ЗАГОЛОВОК И КОНТЕКСТ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      l10n.predTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                  ),
                  const SizedBox(height: 2),
                  if (hormoneText != "Reset")
                    Text(
                      l10n.predInsightHormones(hormoneText),
                      style: TextStyle(fontSize: 12, color: AppColors.primary.withOpacity(0.8), fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              // Кнопка сброса, если есть изменения
              if (_overrides.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _overrides.clear());
                  },
                  child: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                )
            ],
          ),

          const SizedBox(height: 20),

          // 2. ИНТЕРАКТИВНЫЕ ИНДИКАТОРЫ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InteractiveIndicator(
                label: l10n.paramEnergy,
                score: finalScores['energy']!,
                icon: Icons.bolt,
                color: Colors.orangeAccent,
                isOverridden: _overrides.containsKey('energy'),
                onTap: () => _showAdjustmentDialog(context, 'energy', l10n.paramEnergy, l10n),
              ),
              _InteractiveIndicator(
                label: l10n.logMood,
                score: finalScores['mood']!,
                icon: Icons.mood,
                color: Colors.purpleAccent,
                isOverridden: _overrides.containsKey('mood'),
                onTap: () => _showAdjustmentDialog(context, 'mood', l10n.logMood, l10n),
              ),
              _InteractiveIndicator(
                label: l10n.paramFocus,
                score: finalScores['focus']!,
                icon: Icons.center_focus_strong,
                color: Colors.blueAccent,
                isOverridden: _overrides.containsKey('focus'),
                onTap: () => _showAdjustmentDialog(context, 'focus', l10n.paramFocus, l10n),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3. АДАПТИВНЫЙ СОВЕТ (SMART TIP)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(finalScores.toString()), // Анимация при смене
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getSmartTip(mainCategory, finalScores[mainCategory]!, l10n),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Подсказка, если пользователь еще ничего не менял
          if (_overrides.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                l10n.predMismatchBody, // "Нажми на иконку, чтобы изменить совет"
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  // Логика выбора совета
  String _getSmartTip(String category, double score, AppLocalizations l10n) {
    if (category == 'energy') {
      return score > 60 ? l10n.tipHighEnergy : l10n.tipLowEnergy;
    } else if (category == 'mood') {
      return score > 60 ? l10n.tipHighMood : l10n.tipLowMood;
    } else { // focus
      return score > 60 ? l10n.tipHighFocus : l10n.tipLowFocus;
    }
  }

  // Диалог быстрой корректировки
  void _showAdjustmentDialog(BuildContext context, String category, String title, AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.predMismatchTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text("$title: ${l10n.btnAdjust}", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AdjustmentBtn(
                        label: l10n.stateLow,
                        color: Colors.redAccent,
                        icon: Icons.battery_1_bar,
                        onTap: () {
                          setState(() => _overrides[category] = 30.0);
                          Navigator.pop(ctx);
                        }
                    ),
                    _AdjustmentBtn(
                        label: l10n.stateMedium,
                        color: Colors.orangeAccent,
                        icon: Icons.battery_3_bar,
                        onTap: () {
                          setState(() => _overrides[category] = 60.0);
                          Navigator.pop(ctx);
                        }
                    ),
                    _AdjustmentBtn(
                        label: l10n.stateHigh,
                        color: Colors.green,
                        icon: Icons.battery_full,
                        onTap: () {
                          setState(() => _overrides[category] = 90.0);
                          Navigator.pop(ctx);
                        }
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- НОВЫЕ КОМПОНЕНТЫ ---

class _InteractiveIndicator extends StatelessWidget {
  final String label;
  final double score;
  final IconData icon;
  final Color color;
  final bool isOverridden;
  final VoidCallback onTap;

  const _InteractiveIndicator({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
    required this.isOverridden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Если пользователь вручную изменил значение, показываем "точку" индикатор
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 55, height: 55,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isOverridden ? color : Colors.transparent,
                      width: 2
                  ),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              if (isOverridden)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.edit, size: 12, color: color),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),

          // Маленький прогресс бар
          SizedBox(
            width: 40,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _AdjustmentBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AdjustmentBtn({required this.label, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}