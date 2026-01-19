import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ImageFilter

import '../l10n/app_localizations.dart';
import '../logic/cycle_ai_engine.dart';
import '../theme/app_theme.dart' hide GlassContainer;
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart'; // 🔥 IMPORT SETTINGS

import '../widgets/cycle_timer_selector.dart';
import '../widgets/design_selector_sheet.dart';

import '../widgets/pill_widget.dart';
import '../widgets/pill_blister_card.dart';
import '../widgets/cycle_timeline_widget.dart';
import '../widgets/vision_card.dart';
import '../widgets/ai_confidence_card.dart';
import '../widgets/premium_paywall_sheet.dart'; // 🔥 IMPORT PAYWALL
import '../widgets/subscription_status_sheet.dart'; // 🔥 IMPORT STATUS SHEET

import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final settings = context.watch<SettingsProvider>(); // 🔥 WATCH SETTINGS
    final l10n = AppLocalizations.of(context)!;

    final bool isPeriodActive = cycleProvider.currentData.phase == CyclePhase.menstruation;
    final bool isCOC = cycleProvider.isCOCEnabled;
    final bool isPremium = settings.isPremium; // 🔥 CHECK STATUS

    final controlBar = SmartControlBar(
      isPeriodActive: isPeriodActive,
      isCOC: isCOC,
      onMainAction: () {
        HapticFeedback.mediumImpact();

        final bool isCOCNow = cycleProvider.isCOCEnabled;
        final bool isPeriodNow = cycleProvider.currentData.phase == CyclePhase.menstruation;

        if (isCOCNow) {
          _showConfirmationDialog(
            context,
            title: l10n.dialogStartPackTitle,
            body: l10n.dialogStartPackBody,
            isDestructive: true,
            confirmText: l10n.btnRestartPack,
            onConfirm: () async {
              await cycleProvider.startNewCycle();
            },
          );
        } else {
          if (isPeriodNow) {
            _showConfirmationDialog(
              context,
              title: l10n.dialogEndTitle,
              body: l10n.dialogEndBody,
              isDestructive: false,
              onConfirm: () async {
                _triggerAnimation();
                await cycleProvider.endCurrentPeriod();
              },
            );
          } else {
            _showStartPeriodDialog(context, cycleProvider, l10n);
          }
        }
      },
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
              // 🔥🔥🔥 СЕКРЕТНАЯ КНОПКА ЗДЕСЬ 🔥🔥🔥
              title: GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  // Переключаем статус (Инверсия)
                  final newStatus = !settings.isPremium;
                  context.read<SettingsProvider>().setPremiumStatus(newStatus);

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("DEBUG: Premium is now ${newStatus ? 'ON' : 'OFF'}"),
                        backgroundColor: newStatus ? Colors.amber : Colors.grey,
                        duration: const Duration(seconds: 1),
                      )
                  );
                },
                child: Text(
                  _getGreeting(context),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: Responsive.fontSize(context, 20),
                  ),
                ),
              ),
              // ----------------------------------------
            ),
            // КНОПКА PRO / GO PRO В УГЛУ
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Логика переключения экранов
                    if (isPremium) {
                      // Если уже купил -> Управление подпиской
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const SubscriptionStatusSheet(),
                      );
                    } else {
                      // Если не купил -> Пейволл
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const PremiumPaywallSheet(),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      // Золотой фон для премиума, Синий для Free
                      color: isPremium ? Colors.amber.withOpacity(0.2) : AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: isPremium ? Border.all(color: Colors.amber, width: 1.5) : null,
                      boxShadow: isPremium ? [] : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            isPremium ? Icons.verified_rounded : Icons.diamond_rounded,
                            color: isPremium ? Colors.amber[800] : Colors.white,
                            size: 18
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPremium ? "PRO" : "GO PRO",
                          style: TextStyle(
                            color: isPremium ? Colors.amber[900] : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),

                SizedBox(
                  width: 340,
                  height: 340,
                  child: Stack(
                    children: [
                      Center(
                        child: CycleTimerSelector(
                          data: cycleProvider.currentData,
                          isCOC: isCOC,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: _buildDesignButton(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                if (isCOC) ...[
                  const PillWidget(),
                  const SizedBox(height: 20),
                ],

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: controlBar,
                ),

                const SizedBox(height: 30),

                // 🔥 AI CONFIDENCE LOGIC
                if (!isCOC) ...[
                  if (!isPremium)
                  // Вариант 1: Пользователь без премиума -> Тизер с замком
                    _buildLockedAICard(context, l10n)
                  else if (cycleProvider.aiConfidence != null)
                  // Вариант 2: Премиум есть + Данные есть -> Реальная карточка
                    AIConfidenceCard(
                      confidence: cycleProvider.aiConfidence,
                      onTap: () => _showConfidenceDetails(context, cycleProvider),
                    ),
                  // Вариант 3 (else): Премиум есть, но данных нет -> Ничего
                  const SizedBox(height: 12),
                ],

                VisionCard(
                  padding: EdgeInsets.zero,
                  child: isCOC ? const PillBlisterCard() : const CycleTimelineWidget(),
                ),

                const SizedBox(height: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Тизер AI функционала
  Widget _buildLockedAICard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PremiumPaywallSheet(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: VisionCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.featureAiTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.lock, size: 14, color: Colors.amber),
                      ],
                    ),
                    Text(
                      l10n.featureAiDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesignButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const DesignSelectorSheet(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Icon(
              Icons.palette_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _triggerAnimation() {
    HapticFeedback.heavyImpact();
  }

  void _showConfidenceDetails(BuildContext context, CycleProvider provider) {
    final c = provider.aiConfidence;
    if (c == null) return;

    final l10n = AppLocalizations.of(context)!;

    String trKey(String key) {
      switch (key) {
        case 'factorDataNeeded': return l10n.factorDataNeeded;
        case 'factorHighVar': return l10n.factorHighVar;
        case 'factorSlightVar': return l10n.factorSlightVar;
        case 'factorStable': return l10n.factorStable;
        case 'factorAnomaly': return l10n.factorAnomaly;
        case 'confidenceHighDesc': return l10n.confidenceHighDesc;
        case 'confidenceMedDesc': return l10n.confidenceMedDesc;
        case 'confidenceLowDesc': return l10n.confidenceLowDesc;
        case 'confidenceCalcDesc': return l10n.confidenceCalcDesc;
        case 'confidenceNoData': return l10n.confidenceNoData;
        default: return key;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiDialogTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              l10n.aiDialogScore(c.score.clamp(0, 100)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Text(
              trKey(c.explanationKey),
              style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.3),
            ),

            const Divider(height: 30),

            Text(
              l10n.aiDialogFactors,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (c.factors.isEmpty)
              Text(
                trKey('factorDataNeeded'),
                style: const TextStyle(fontSize: 15),
              )
            else
              ...c.factors.map(
                    (factorKey) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trKey(factorKey),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  l10n.btnGotIt,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartPeriodDialog(BuildContext context, CycleProvider cycle, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dialogPeriodStartTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dialogPeriodStartBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  _triggerAnimation();
                  await cycle.setSpecificCycleStartDate(DateTime.now());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.menstruation,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  l10n.btnToday,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppColors.menstruation),
                    ),
                    child: child!,
                  ),
                );

                if (picked != null) {
                  _triggerAnimation();
                  await cycle.setSpecificCycleStartDate(picked);
                }
              },
              child: Text(
                l10n.btnAnotherDay,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final h = DateTime.now().hour;
    final l = AppLocalizations.of(context)!;
    if (h < 12) return l.greetMorning;
    if (h < 17) return l.greetAfternoon;
    return l.greetEvening;
  }

  void _showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String body,
        required Future<void> Function() onConfirm,
        bool isDestructive = false,
        String? confirmText,
      }) {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(body),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.btnCancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () async {
                Navigator.of(ctx).pop();
                await onConfirm();
              },
              child: Text(
                confirmText ?? l10n.btnConfirm,
                style: TextStyle(
                  color: isDestructive ? CupertinoColors.destructiveRed : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmartControlBar extends StatelessWidget {
  final bool isPeriodActive;
  final bool isCOC;
  final VoidCallback onMainAction;

  const SmartControlBar({
    super.key,
    required this.isPeriodActive,
    required this.onMainAction,
    this.isCOC = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color btnColor;
    // 🔥 Добавляем переменную для градиента
    Gradient? btnGradient;
    String btnText;
    IconData btnIcon;
    Color contentColor;

    if (isCOC) {
      // Состояние: Прием таблеток
      btnColor = Colors.white;
      btnGradient = null; // Нет градиента
      btnText = l10n.btnStartNewPack;
      btnIcon = Icons.restart_alt_rounded;
      contentColor = AppColors.textPrimary;
    } else {
      if (isPeriodActive) {
        // Состояние: Месячные идут (Кнопка "Закончить")
        btnColor = Colors.white;
        btnGradient = null; // Нет градиента
        btnText = l10n.btnPeriodEnd;
        btnIcon = Icons.check_rounded;
        contentColor = AppColors.textPrimary;
      } else {
        // Состояние: Месячных нет (Кнопка "Начать") - 🔥 ДЕЛАЕМ ГРАДИЕНТ
        btnColor = AppColors.menstruation; // Фоллбэк цвет
        btnGradient = const LinearGradient(
          colors: [
            AppColors.menstruation, // Основной красный
            Color(0xFFFF8A8A),      // Более светлый оттенок для объема
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        btnText = l10n.btnPeriodStart;
        btnIcon = Icons.water_drop_rounded;
        contentColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: onMainAction,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 64,
          decoration: BoxDecoration(
            color: btnColor,
            gradient: btnGradient, // 🔥 Применяем градиент
            borderRadius: BorderRadius.circular(34),
            boxShadow: (btnColor != Colors.white)
                ? [
              BoxShadow(
                color: AppColors.menstruation.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(btnIcon, color: contentColor, size: 24),
              const SizedBox(width: 10),
              Text(
                btnText,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}