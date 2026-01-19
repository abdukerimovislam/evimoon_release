import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/ttc_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../widgets/glass_container.dart';

// 🔥 ИМПОРТЫ ТВОИХ ВИДЖЕТОВ
import 'widgets/ttc_action_card.dart';
import 'widgets/ttc_fertility_ring.dart';
import 'widgets/ttc_quick_log_sheet.dart';

class TTCHomeScreen extends StatefulWidget {
  const TTCHomeScreen({super.key});

  @override
  State<TTCHomeScreen> createState() => _TTCHomeScreenState();
}

class _TTCHomeScreenState extends State<TTCHomeScreen> {

  // --- ЛОГИКА ШТОРКИ ---
  void _openQuickLog(BuildContext context, QuickLogFocus focus) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TTCQuickLogSheet(date: DateTime.now(), initialFocus: focus),
    );
  }

  // --- ЛОГИКА ДИАЛОГОВ ---
  void _showConfirmationDialog({
    required String title,
    required String body,
    required Future<void> Function() onConfirm,
    bool isDestructive = false,
    String? confirmText,
  }) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(body)),
        actions: [
          CupertinoDialogAction(isDefaultAction: true, onPressed: () => Navigator.pop(ctx), child: Text(l10n.btnCancel)),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () async {
              Navigator.pop(ctx);
              await onConfirm();
            },
            child: Text(confirmText ?? l10n.btnConfirm, style: TextStyle(color: isDestructive ? CupertinoColors.destructiveRed : AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showStartPeriodDialog(CycleProvider cycle) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.dialogPeriodStartTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(l10n.dialogPeriodStartBody, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  HapticFeedback.heavyImpact();
                  await cycle.setSpecificCycleStartDate(DateTime.now());
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.menstruation, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(l10n.btnToday, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 1)),
                  firstDate: DateTime.now().subtract(const Duration(days: 45)),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.menstruation)), child: child!),
                );
                if (picked != null) {
                  HapticFeedback.heavyImpact();
                  await cycle.setSpecificCycleStartDate(picked);
                }
              },
              child: Text(l10n.btnAnotherDay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER METHODS ---
  String _getTestLabel(OvulationTestResult result, AppLocalizations l10n) {
    switch (result) {
      case OvulationTestResult.positive: return l10n.lblPositive;
      case OvulationTestResult.peak: return l10n.lblPeak.toUpperCase();
      case OvulationTestResult.negative: return l10n.lblNegative;
      default: return l10n.ttcBtnTest;
    }
  }

  String _getDailyTip(AppLocalizations l10n, CycleProvider cycle) {
    if (cycle.currentData.phase == CyclePhase.menstruation) return l10n.tipPeriod;
    if (cycle.conceptionChance == FertilityChance.peak || cycle.conceptionChance == FertilityChance.high) return l10n.tipOvulation;
    if (cycle.currentDPO != null) {
      if (cycle.currentDPO! >= 7) return l10n.tipLutealLate;
      return l10n.tipLutealEarly;
    }
    return l10n.tipFollicular;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = Provider.of<CycleProvider>(context);
    final wellness = Provider.of<WellnessProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final data = cycle.currentData;
    final todayLog = wellness.getLogForDate(DateTime.now());

    // Флаг: идут ли месячные сейчас
    final bool isPeriodActive = data.phase == CyclePhase.menstruation;

    // Данные для карточек
    final bool hasTemp = todayLog.temperature != null && todayLog.temperature! > 0;
    final bool hasTest = todayLog.ovulationTest != OvulationTestResult.none;
    final bool hasSex = todayLog.hadSex;

    String mainStatus = "";
    String subStatus = "";

    final Color glowColor = TTCTheme.getGlowColor(
        dpo: cycle.currentDPO,
        chance: cycle.conceptionChance
    );

    if (cycle.currentDPO != null) {
      final dpo = cycle.currentDPO!;
      mainStatus = l10n.ttcDPO(dpo);
      subStatus = (dpo >= 10) ? l10n.ttcTestReady : l10n.ttcTestWait;
    } else {
      switch (cycle.conceptionChance) {
        case FertilityChance.peak:
          mainStatus = l10n.ttcStatusPeak;
          subStatus = l10n.ttcStatusOvulation;
          break;
        case FertilityChance.high:
          mainStatus = l10n.ttcStatusHigh;
          subStatus = l10n.ttcChance;
          break;
        case FertilityChance.low:
        default:
          mainStatus = l10n.ttcStatusLow;
          subStatus = l10n.lblCycleDay(data.currentDay);
      }
    }

    double progressValue = 0.0;
    if (data.totalCycleLength > 0) {
      progressValue = (data.currentDay / data.totalCycleLength).clamp(0.0, 1.0);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      // ❌ FloatingActionButton удален отсюда

      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.modeTTC.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.lblCycleDay(data.currentDay),
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.star_fill, color: TTCTheme.primaryGold, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // GOLDEN RING
            Center(
              child: TTCFertilityRing(
                progress: progressValue,
                glowColor: glowColor,
                mainText: mainStatus,
                subText: subStatus,
              ),
            ),

            const SizedBox(height: 30),

            // 🔥🔥🔥 КНОПКА ПРЯМО ПОД ТАЙМЕРОМ 🔥🔥🔥
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TTCPeriodButton(
                isPeriodActive: isPeriodActive,
                l10n: l10n,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isPeriodActive) {
                    _showConfirmationDialog(
                      title: l10n.dialogEndTitle,
                      body: l10n.dialogEndBody,
                      isDestructive: false,
                      onConfirm: () async {
                        HapticFeedback.heavyImpact();
                        await cycle.endCurrentPeriod();
                      },
                    );
                  } else {
                    _showStartPeriodDialog(cycle);
                  }
                },
              ),
            ),
            // ----------------------------------------

            const SizedBox(height: 30),

            // ACTION CARDS
            Row(
              children: [
                Expanded(
                  child: TTCActionCard(
                    icon: CupertinoIcons.thermometer,
                    label: l10n.ttcBtnBBT,
                    value: hasTemp ? "${todayLog.temperature}°" : null,
                    isActive: hasTemp,
                    color: TTCTheme.cardBBT,
                    onTap: () => _openQuickLog(context, QuickLogFocus.bbt),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TTCActionCard(
                    icon: CupertinoIcons.drop,
                    label: l10n.ttcBtnTest,
                    value: hasTest ? _getTestLabel(todayLog.ovulationTest, l10n) : null,
                    isActive: hasTest,
                    color: TTCTheme.cardTest,
                    onTap: () => _openQuickLog(context, QuickLogFocus.test),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TTCActionCard(
                    icon: CupertinoIcons.heart_fill,
                    label: l10n.ttcBtnSex,
                    value: hasSex ? l10n.lblSexYes : null,
                    isActive: hasSex,
                    color: TTCTheme.cardSex,
                    onTap: () => _openQuickLog(context, QuickLogFocus.sex),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INSIGHT CARD
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.lightbulb_fill, color: TTCTheme.primaryGold),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              l10n.ttcTipTitle.toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.0)
                          ),
                          const SizedBox(height: 6),
                          Text(
                              _getDailyTip(l10n, cycle),
                              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.3)
                          ),
                        ],
                      ),
                    )
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

// 🔥 ВИДЖЕТ КНОПКИ
class _TTCPeriodButton extends StatelessWidget {
  final bool isPeriodActive;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _TTCPeriodButton({
    required this.isPeriodActive,
    required this.onTap,
    required this.l10n
  });

  @override
  Widget build(BuildContext context) {
    // Белая если закончить, Градиент если начать
    final Color bgColor = isPeriodActive ? Colors.white : AppColors.menstruation;
    final Color textColor = isPeriodActive ? AppColors.textPrimary : Colors.white;
    final IconData icon = isPeriodActive ? Icons.check_rounded : Icons.water_drop_rounded;
    final String text = isPeriodActive ? l10n.btnPeriodEnd : l10n.btnPeriodStart;

    Gradient? gradient;
    if (!isPeriodActive) {
      gradient = const LinearGradient(
        colors: [AppColors.menstruation, Color(0xFFFF8A8A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56, // Чуть компактнее
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (isPeriodActive ? Colors.black : AppColors.menstruation).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
                text,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)
            ),
          ],
        ),
      ),
    );
  }
}