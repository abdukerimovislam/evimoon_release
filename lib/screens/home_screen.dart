import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ImageFilter
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../logic/cycle_ai_engine.dart';
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
import '../widgets/mode_transition_overlay.dart'; // 🔥 Import Animation Overlay

import '../utils/responsive.dart';

// Import TTC Screen
import 'ttc/ttc_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();

    // ROUTING
    if (cycleProvider.isTTCMode) {
      return const TTCHomeScreen();
    }

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
              // Debug/Hidden Button
              title: GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  final newStatus = !settings.isPremium;
                  context.read<SettingsProvider>().setPremiumStatus(newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("DEBUG: Premium ${newStatus ? 'ON' : 'OFF'}")));
                },
                child: Text(
                  _getGreeting(context),
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: Responsive.fontSize(context, 20)),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (isPremium) {
                      showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => const SubscriptionStatusSheet());
                    } else {
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PremiumPaywallSheet());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: isPremium ? Colors.amber.withOpacity(0.2) : AppColors.primary, borderRadius: BorderRadius.circular(20), border: isPremium ? Border.all(color: Colors.amber, width: 1.5) : null, boxShadow: isPremium ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(isPremium ? Icons.verified_rounded : Icons.diamond_rounded, color: isPremium ? Colors.amber[800] : Colors.white, size: 18), const SizedBox(width: 4), Text(isPremium ? "PRO" : "GO PRO", style: TextStyle(color: isPremium ? Colors.amber[900] : Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 🔥 MODE SWITCHER (With Premium Check & Animations)
                if (!isCOC)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: _ModeSwitcher(
                        isTTC: false,
                        isPremium: isPremium,
                        l10n: l10n
                    ),
                  ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 340, height: 340,
                  child: Stack(children: [Center(child: CycleTimerSelector(data: cycleProvider.currentData, isCOC: isCOC)), Positioned(right: 0, top: 0, child: _buildDesignButton(context))]),
                ),

                const SizedBox(height: 25),

                if (isCOC) ...[const PillWidget(), const SizedBox(height: 20)],

                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: controlBar),

                const SizedBox(height: 30),

                if (!isCOC) ...[
                  if (!isPremium) _buildLockedAICard(context, l10n)
                  else if (cycleProvider.aiConfidence != null) AIConfidenceCard(confidence: cycleProvider.aiConfidence, onTap: () => _showConfidenceDetails(context, cycleProvider)),
                  const SizedBox(height: 12),
                ],

                VisionCard(padding: EdgeInsets.zero, child: isCOC ? const PillBlisterCard() : const CycleTimelineWidget()),
                const SizedBox(height: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... Helpers ...
  void _handleMainAction(BuildContext context, CycleProvider provider, AppLocalizations l10n) {
    HapticFeedback.mediumImpact();
    final bool isCOCNow = provider.isCOCEnabled;
    final bool isPeriodNow = provider.currentData.phase == CyclePhase.menstruation;
    if (isCOCNow) {
      _showConfirmationDialog(context, title: l10n.dialogStartPackTitle, body: l10n.dialogStartPackBody, isDestructive: true, confirmText: l10n.btnRestartPack, onConfirm: () async => await provider.startNewCycle());
    } else {
      if (isPeriodNow) {
        _showConfirmationDialog(context, title: l10n.dialogEndTitle, body: l10n.dialogEndBody, isDestructive: false, onConfirm: () async { HapticFeedback.heavyImpact(); await provider.endCurrentPeriod(); });
      } else {
        _showStartPeriodDialog(context, provider, l10n);
      }
    }
  }
  Widget _buildLockedAICard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PremiumPaywallSheet()); },
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), child: VisionCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(l10n.featureAiTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)), const SizedBox(width: 6), const Icon(Icons.lock, size: 14, color: Colors.amber)]), Text(l10n.featureAiDesc, style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.8)))]))]))),
    );
  }
  Widget _buildDesignButton(BuildContext context) {
    return GestureDetector(onTap: () { HapticFeedback.mediumImpact(); showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const DesignSelectorSheet()); }, child: ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.6))), child: const Icon(Icons.palette_rounded, size: 20, color: AppColors.textSecondary)))));
  }
  void _showConfidenceDetails(BuildContext context, CycleProvider provider) {}
  void _showStartPeriodDialog(BuildContext context, CycleProvider cycle, AppLocalizations l10n) { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(l10n.dialogPeriodStartTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 24), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { Navigator.pop(ctx); await cycle.setSpecificCycleStartDate(DateTime.now()); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.menstruation, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(l10n.btnToday, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]))); }
  void _showConfirmationDialog(BuildContext context, {required String title, required String body, required Future<void> Function() onConfirm, bool isDestructive = false, String? confirmText}) { final l10n = AppLocalizations.of(context)!; showCupertinoDialog(context: context, barrierDismissible: true, builder: (ctx) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: CupertinoAlertDialog(title: Text(title), content: Text(body), actions: [CupertinoDialogAction(isDefaultAction: true, onPressed: () => Navigator.pop(ctx), child: Text(l10n.btnCancel)), CupertinoDialogAction(isDestructiveAction: isDestructive, onPressed: () async { Navigator.pop(ctx); await onConfirm(); }, child: Text(confirmText ?? l10n.btnConfirm))]))); }
  String _getGreeting(BuildContext context) { final h = DateTime.now().hour; final l = AppLocalizations.of(context)!; if (h < 12) return l.greetMorning; if (h < 17) return l.greetAfternoon; return l.greetEvening; }
}

// 🔥 UPDATED MODE SWITCHER WITH PREMIUM LOGIC & ANIMATION
class _ModeSwitcher extends StatelessWidget {
  final bool isTTC;
  final bool isPremium;
  final AppLocalizations l10n;

  const _ModeSwitcher({
    required this.isTTC,
    required this.isPremium,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F5), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          // TRACKER MODE
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isTTC) {
                  HapticFeedback.selectionClick();
                  // Animate back to standard tracker
                  ModeTransitionOverlay.show(
                      context,
                      TransitionMode.tracking,
                      l10n.transitionTrack,
                      onComplete: () {
                        context.read<CycleProvider>().setTTCMode(false);
                      }
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(color: !isTTC ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: !isTTC ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : []),
                alignment: Alignment.center,
                child: Text("Track Cycle", style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: !isTTC ? Colors.black : Colors.grey, fontSize: 14)),
              ),
            ),
          ),

          // TTC (PREGNANCY) MODE
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isTTC) {
                  HapticFeedback.selectionClick();

                  // 🔒 CHECK PREMIUM
                  if (!isPremium) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PremiumPaywallSheet(),
                    );
                    return;
                  }

                  // 🔥 ANIMATE TO TTC MODE
                  ModeTransitionOverlay.show(
                      context,
                      TransitionMode.ttc,
                      l10n.transitionTTC,
                      onComplete: () {
                        context.read<CycleProvider>().setTTCMode(true);
                      }
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(color: isTTC ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18), boxShadow: isTTC ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : []),
                alignment: Alignment.center,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Get Pregnant", style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: isTTC ? AppColors.primary : Colors.grey, fontSize: 14)),
                  const SizedBox(width: 4),
                  // Lock icon if not premium, Star/Baby if active or premium
                  Icon(
                      isPremium ? Icons.auto_awesome : Icons.lock,
                      size: 14,
                      color: isPremium ? Colors.amber : Colors.grey
                  )
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmartControlBar extends StatelessWidget {
  final bool isPeriodActive;
  final bool isCOC;
  final VoidCallback onMainAction;
  const SmartControlBar({super.key, required this.isPeriodActive, required this.onMainAction, this.isCOC = false});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color btnColor = isCOC ? Colors.white : (isPeriodActive ? Colors.white : AppColors.menstruation);
    String btnText = isCOC ? l10n.btnStartNewPack : (isPeriodActive ? l10n.btnPeriodEnd : l10n.btnPeriodStart);
    IconData btnIcon = isCOC ? Icons.restart_alt_rounded : (isPeriodActive ? Icons.check_rounded : Icons.water_drop_rounded);
    Color contentColor = (isCOC || isPeriodActive) ? AppColors.textPrimary : Colors.white;
    return GestureDetector(onTap: onMainAction, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white.withOpacity(0.6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]), child: Container(height: 64, decoration: BoxDecoration(color: btnColor, borderRadius: BorderRadius.circular(34)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(btnIcon, color: contentColor, size: 24), const SizedBox(width: 10), Text(btnText, style: TextStyle(color: contentColor, fontWeight: FontWeight.w800, fontSize: 15))]))));
  }
}