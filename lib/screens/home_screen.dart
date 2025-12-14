import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Для ImageFilter

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart' hide GlassContainer;
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';

import '../widgets/cycle_timer_widget.dart';
import '../widgets/pill_widget.dart';
import '../widgets/pill_blister_card.dart';
import '../widgets/prediction_card.dart';
import '../widgets/vision_card.dart';
import '../utils/responsive.dart';
import 'symptom_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔥 КЛЮЧ ДЛЯ ДОСТУПА К АНИМАЦИИ
  final GlobalKey<CycleTimerWidgetState> _timerKey = GlobalKey<CycleTimerWidgetState>();

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final bool isPeriodActive = cycleProvider.currentData.phase == CyclePhase.menstruation;
    final bool isCOC = cycleProvider.isCOCEnabled;

    // Выносим панель управления в переменную для удобства чтения верстки
    final controlBar = SmartControlBar(
      isPeriodActive: isPeriodActive,
      isCOC: isCOC,
      onMainAction: () {
        HapticFeedback.mediumImpact();
        if (isCOC) {
          _showConfirmationDialog(
              context,
              title: l10n.dialogStartPackTitle,
              body: l10n.dialogStartPackBody,
              isDestructive: true,
              onConfirm: () => cycleProvider.startNewCycle(),
              confirmText: l10n.btnRestartPack
          );
        } else {
          if (isPeriodActive) {
            // ЗАКОНЧИТЬ МЕСЯЧНЫЕ
            _showConfirmationDialog(
                context,
                title: l10n.dialogEndTitle,
                body: l10n.dialogEndBody,
                isDestructive: false,
                onConfirm: () {
                  _triggerAnimation(); // 🔥 Крутим
                  cycleProvider.endCurrentPeriod();
                }
            );
          } else {
            // НАЧАТЬ МЕСЯЧНЫЕ (Показываем выбор даты)
            _showStartPeriodDialog(context, cycleProvider, l10n);
          }
        }
      },
      onDailyLog: () => _showSymptomSheet(context),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                  _getGreeting(context),
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: Responsive.fontSize(context, 20))
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 1. ГЕРОЙ: ТАЙМЕР С АНИМАЦИЕЙ
                CycleTimerWidget(
                  key: _timerKey, // 🔥 ПЕРЕДАЕМ КЛЮЧ
                  data: cycleProvider.currentData,
                  isCOC: isCOC,
                ),
                const SizedBox(height: 30),

                // 2. ТАБЛЕТКА (Для КОК)
                if (isCOC) ...[
                  const PillWidget(),
                  const SizedBox(height: 20),
                ],

                // 3. СТАТУС ФАЗЫ
                VisionCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)
                            ]
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getPhaseMessage(context, cycleProvider.currentData.phase, isCOC),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. ТЕКСТ ПРОГНОЗА
                Text(
                  _getPredictionText(context, cycleProvider.currentData, isCOC),
                  style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6), fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 25),

                // 5. 🔥 ПАНЕЛЬ УПРАВЛЕНИЯ (ПЕРЕНЕСЕНА СЮДА) 🔥
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: controlBar,
                ),

                const SizedBox(height: 25),

                // 6. ОСНОВНОЙ КОНТЕНТ (Блистер или График)
                VisionCard(
                  padding: EdgeInsets.zero,
                  child: isCOC
                      ? const PillBlisterCard()
                      : const PredictionCard(),
                ),

                // Нижний отступ теперь меньше, так как кнопки нет внизу
                const SizedBox(height: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 🔥 МЕТОД ЗАПУСКА АНИМАЦИИ ---
  void _triggerAnimation() {
    _timerKey.currentState?.spinEffect();
  }

  // --- 🔥 ДИАЛОГ ВЫБОРА ДАТЫ ---
  void _showStartPeriodDialog(BuildContext context, CycleProvider cycle, AppLocalizations l10n) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.dialogPeriodStartTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(l10n.dialogPeriodStartBody, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Кнопка СЕГОДНЯ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _triggerAnimation(); // 🔥 Крутим
                    cycle.startNewCycle();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.menstruation,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: Text(l10n.btnToday, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),

              // Кнопка ВЫБРАТЬ ДАТУ
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 1)),
                      firstDate: DateTime.now().subtract(const Duration(days: 45)),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.menstruation)), child: child!)
                  );

                  if (picked != null) {
                    _triggerAnimation(); // 🔥 Крутим
                    cycle.setSpecificCycleStartDate(picked);
                  }
                },
                child: Text(l10n.btnAnotherDay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
    );
  }

  String _getGreeting(BuildContext context) {
    final h = DateTime.now().hour;
    final l = AppLocalizations.of(context)!;
    if (h < 12) return l.greetMorning;
    if (h < 17) return l.greetAfternoon;
    return l.greetEvening;
  }

  String _getPhaseMessage(BuildContext context, CyclePhase phase, bool isCOC) {
    final l = AppLocalizations.of(context)!;
    if (isCOC) {
      if (phase == CyclePhase.menstruation) return l.cocBreakPhase;
      return l.cocActivePhase;
    }
    switch (phase) {
      case CyclePhase.menstruation: return l.phaseStatusMenstruation;
      case CyclePhase.follicular: return l.phaseStatusFollicular;
      case CyclePhase.ovulation: return l.phaseStatusOvulation;
      case CyclePhase.luteal: return l.phaseStatusLuteal;
      case CyclePhase.late: return l.phaseLate;
    }
  }

  String _getPredictionText(BuildContext context, CycleData data, bool isCOC) {
    final l10n = AppLocalizations.of(context)!;
    if (isCOC) {
      if (data.phase == CyclePhase.menstruation) {
        return l10n.cocPredictionBreak(data.daysUntilNextPeriod);
      } else {
        return l10n.cocPredictionActive(data.daysUntilNextPeriod);
      }
    }
    return l10n.predictionText(data.daysUntilNextPeriod);
  }

  void _showConfirmationDialog(BuildContext context, {required String title, required String body, required VoidCallback onConfirm, bool isDestructive = false, String? confirmText}) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(body)),
          actions: [
            CupertinoDialogAction(isDefaultAction: true, onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.btnCancel)),
            CupertinoDialogAction(
                isDestructiveAction: isDestructive,
                onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
                child: Text(confirmText ?? l10n.btnConfirm, style: TextStyle(color: isDestructive ? CupertinoColors.destructiveRed : AppColors.primary, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      ),
    );
  }

  void _showSymptomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SymptomLogScreen(date: DateTime.now(), scrollController: scroll, isModal: true),
        ),
      ),
    );
  }
}

class SmartControlBar extends StatelessWidget {
  final bool isPeriodActive;
  final bool isCOC;
  final VoidCallback onMainAction;
  final VoidCallback onDailyLog;

  const SmartControlBar({super.key, required this.isPeriodActive, required this.onMainAction, required this.onDailyLog, this.isCOC = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color btnColor;
    String btnText;
    IconData btnIcon;
    Color contentColor;

    if (isCOC) {
      btnColor = Colors.white;
      btnText = l10n.btnStartNewPack;
      btnIcon = Icons.restart_alt_rounded;
      contentColor = AppColors.textPrimary;
    } else {
      if (isPeriodActive) {
        btnColor = Colors.white;
        btnText = l10n.btnPeriodEnd;
        btnIcon = Icons.check_rounded;
        contentColor = AppColors.textPrimary;
      } else {
        btnColor = AppColors.menstruation;
        btnText = l10n.btnPeriodStart;
        btnIcon = Icons.water_drop_rounded;
        contentColor = Colors.white;
      }
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white.withOpacity(0.6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: onMainAction,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 64,
                decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(34), boxShadow: (!isCOC && !isPeriodActive) ? [BoxShadow(color: AppColors.menstruation.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))] : []),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(btnIcon, color: contentColor, size: 24),
                    const SizedBox(width: 10),
                    Text(btnText, style: TextStyle(color: contentColor, fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: onDailyLog,
              child: Container(
                height: 64,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(34), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}