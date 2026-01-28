import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ImageFilter
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart' hide GlassContainer;
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';

import '../widgets/cycle_timer_selector.dart';
import '../widgets/design_selector_sheet.dart';
import '../widgets/pill_widget.dart';
import '../widgets/pill_blister_card.dart';
import '../widgets/cycle_timeline_widget.dart';
import '../widgets/vision_card.dart';
import '../widgets/ai_confidence_card.dart';
import '../widgets/premium_paywall_sheet.dart';
import '../widgets/subscription_status_sheet.dart';
import '../widgets/mesh_background.dart';
import '../widgets/last_cycle_badge.dart'; // 🔥 Import LastCycleBadge
import '../widgets/mode_switcher.dart';

import '../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ HomeScreen renders only the standard cycle tracking view.
    // TTC routing is handled by MainScreen via SettingsProvider.isTTCMode.
    final cycleProvider = context.watch<CycleProvider>();
    return _buildStandardScreen(context, cycleProvider);
  }

  Widget _buildStandardScreen(BuildContext context, CycleProvider cycleProvider) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    final bool isPeriodActive = cycleProvider.currentData.phase == CyclePhase.menstruation;
    final bool isCOC = cycleProvider.isCOCEnabled;
    final bool isPremium = settings.isPremium;

    final controlBar = SmartControlBar(
      isPeriodActive: isPeriodActive,
      isCOC: isCOC,
      onMainAction: () => _handleMainAction(context, cycleProvider, l10n),
    );

    return MeshCycleBackground(
      phase: cycleProvider.currentData.phase,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    title: GestureDetector(
                      onLongPress: () {
                        // Скрытый способ (оставил на всякий случай)
                        HapticFeedback.heavyImpact();
                        final newStatus = !settings.isPremium;
                        context.read<SettingsProvider>().setPremiumStatus(newStatus);
                      },
                      child: Text(
                        _getGreeting(context),
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.fontSize(context, 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Center(child: _buildPremiumBadge(context, isPremium, l10n)),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 🛠️ ВРЕМЕННАЯ КНОПКА ДЛЯ ТЕСТА PREMUIM
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final newStatus = !settings.isPremium;
                        context.read<SettingsProvider>().setPremiumStatus(newStatus);
                      },
                      icon: Icon(isPremium ? Icons.lock_open : Icons.lock, size: 16, color: isPremium ? Colors.green : Colors.red),
                      label: Text(
                        isPremium ? "DEV: PRO ACTIVE" : "DEV: ENABLE PRO",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (!isCOC)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: ModeSwitcher(
                        isTTC: false,
                        isPremium: isPremium,
                        l10n: l10n,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ТАЙМЕР ЦИКЛА
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CycleTimerSelector(data: cycleProvider.currentData, isCOC: isCOC),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: _buildDesignButton(context),
                        )
                      ],
                    ),
                  ),

                  // 🔥 ПЛАШКА "ПРОШЛЫЙ ЦИКЛ" (ПЕРЕМЕЩЕНА СЮДА)
                  if (!isCOC) ...[
                    const SizedBox(height: 24), // Отступ от таймера
                    const Center(child: LastCycleBadge()),
                  ],

                  const SizedBox(height: 32),

                  if (isCOC) ...[
                    const PillWidget(),
                    const SizedBox(height: 24),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: controlBar,
                  ),

                  const SizedBox(height: 32),

                  if (!isCOC) ...[
                    if (!isPremium)
                      _buildLockedAICard(context, l10n)
                    else if (cycleProvider.aiConfidence != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: VisionCard(
                          isGlass: true,
                          padding: EdgeInsets.zero,
                          child: AIConfidenceCard(
                            confidence: cycleProvider.aiConfidence,
                            onTap: () => _showConfidenceDetails(context, cycleProvider),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: VisionCard(
                      isGlass: true,
                      padding: EdgeInsets.zero,
                      child: isCOC ? const PillBlisterCard() : const CycleTimelineWidget(),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildPremiumBadge(BuildContext context, bool isPremium, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isPremium) {
          showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => const SubscriptionStatusSheet());
        } else {
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PremiumPaywallSheet());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isPremium ? LinearGradient(colors: [Colors.amber.shade300, Colors.amber.shade600]) : LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: (isPremium ? Colors.amber : AppColors.primary).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isPremium ? Icons.verified_rounded : Icons.diamond_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              isPremium ? l10n.badgePro : l10n.badgeGoPro,
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLockedAICard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PremiumPaywallSheet());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: VisionCard(
          isGlass: true,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l10n.featureAiTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.featureAiDesc, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                  ],
                ),
              )
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
        showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const DesignSelectorSheet());
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(Icons.palette_outlined, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  // --- ЛОГИКА ---

  void _handleMainAction(BuildContext context, CycleProvider provider, AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    final bool isCOCNow = provider.isCOCEnabled;
    final bool isPeriodNow = provider.currentData.phase == CyclePhase.menstruation;

    if (isCOCNow) {
      _showConfirmationDialog(
        context,
        title: l10n.dialogStartPackTitle,
        body: l10n.dialogStartPackBody,
        isDestructive: true,
        confirmText: l10n.btnRestartPack,
        onConfirm: () async => await provider.startNewCycle(),
      );
    } else {
      if (isPeriodNow) {
        _showConfirmationDialog(
          context,
          title: l10n.dialogEndTitle,
          body: l10n.dialogEndBody,
          isDestructive: false,
          onConfirm: () async {
            HapticFeedback.heavyImpact();
            await provider.endCurrentPeriod();
          },
        );
      } else {
        _showStartPeriodDialog(context, provider, l10n);
      }
    }
  }

  void _showStartPeriodDialog(BuildContext context, CycleProvider cycle, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dialogPeriodStartTitle,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  await cycle.setSpecificCycleStartDate(DateTime.now());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.menstruation,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.btnToday,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  await cycle.setSpecificCycleStartDate(DateTime.now().subtract(const Duration(days: 1)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.menstruation.withOpacity(0.1),
                  foregroundColor: AppColors.menstruation,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.btnYesterday,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 60)),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.menstruation,
                            onPrimary: Colors.white,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    HapticFeedback.mediumImpact();
                    await cycle.setSpecificCycleStartDate(picked);
                  }
                },
                icon: Icon(Icons.calendar_month_rounded, color: AppColors.textSecondary),
                label: Text(
                  l10n.btnPickDate,
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          content: Text(body),
          actions: [
            CupertinoDialogAction(isDefaultAction: true, onPressed: () => Navigator.pop(ctx), child: Text(l10n.btnCancel)),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () async {
                Navigator.pop(ctx);
                await onConfirm();
              },
              child: Text(confirmText ?? l10n.btnConfirm),
            )
          ],
        ),
      ),
    );
  }

  void _showConfidenceDetails(BuildContext context, CycleProvider provider) {
    HapticFeedback.mediumImpact();
    final confidence = provider.aiConfidence;
    if (confidence == null) return;

    final l10n = AppLocalizations.of(context)!;

    // Определяем цвет и текст в зависимости от уровня
    Color statusColor;
    String statusText;
    String description;

    // score приходит 0.0 - 1.0
    if (confidence.score >= 0.8) {
      statusColor = Colors.green;
      statusText = l10n.aiStatusHigh;
      description = l10n.aiDescHigh;
    } else if (confidence.score >= 0.5) {
      statusColor = Colors.orange;
      statusText = l10n.aiStatusMedium;
      description = l10n.aiDescMedium;
    } else {
      statusColor = Colors.redAccent;
      statusText = l10n.aiStatusLow;
      description = l10n.aiDescLow;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 Разрешаем шторке занимать больше места
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        // Ограничиваем высоту (чтобы не улетала в самый верх), но даем скролл
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), // Нижний отступ побольше
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор-ручка
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),

              // Иконка
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: statusColor, size: 32),
              ),
              const SizedBox(height: 16),

              Text(
                statusText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 8),

              // Проценты
              Text(
                "${(confidence.score * 100).toInt()}% ${l10n.aiConfidenceScore}",
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor
                ),
              ),

              const SizedBox(height: 24),

              // Описание причин
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                        Icons.history,
                        l10n.aiLabelHistory,
                        "${provider.history.length} ${l10n.aiSuffixCycles}"
                    ),
                    const Divider(height: 24),
                    // Используем данные из движка
                    _buildDetailRow(
                        Icons.waves,
                        l10n.aiLabelVariation,
                        "±${confidence.stdDevDays.toStringAsFixed(1)} ${l10n.aiSuffixDays}"
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                      l10n.btnGotIt,
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
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
}

Widget _buildDetailRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
            label,
            style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600
            )
        ),
      ),
      Text(
          value,
          style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold
          )
      ),
    ],
  );
}

class SmartControlBar extends StatelessWidget {
  final bool isPeriodActive;
  final bool isCOC;
  final VoidCallback onMainAction;
  const SmartControlBar({super.key, required this.isPeriodActive, required this.onMainAction, this.isCOC = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isActiveStyle = !isCOC && !isPeriodActive;
    Color btnColor = isCOC ? Colors.white : (isPeriodActive ? Colors.white : AppColors.menstruation);
    String btnText = isCOC ? l10n.btnStartNewPack : (isPeriodActive ? l10n.btnPeriodEnd : l10n.btnPeriodStart);
    IconData btnIcon = isCOC ? Icons.restart_alt_rounded : (isPeriodActive ? Icons.check_rounded : Icons.water_drop_rounded);
    Color contentColor = (isCOC || isPeriodActive) ? AppColors.textPrimary : Colors.white;

    return GestureDetector(
      onTap: onMainAction,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: -2)],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            color: btnColor,
            gradient: isActiveStyle
                ? const LinearGradient(colors: [Color(0xFFE57373), Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            borderRadius: BorderRadius.circular(34),
            boxShadow: isActiveStyle ? [BoxShadow(color: AppColors.menstruation.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(btnIcon, color: contentColor, size: 24),
              const SizedBox(width: 12),
              Text(
                btnText,
                style: GoogleFonts.inter(color: contentColor, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
              )
            ],
          ),
        ),
      ),
    );
  }

}
