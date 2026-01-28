import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/ttc_theme.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/premium_paywall_sheet.dart';
import '../widgets/mode_transition_overlay.dart';

// NOTE: This widget is used both in Track Cycle and TTC screens.
// Main routing is controlled by SettingsProvider.isTTCMode (see MainScreen).
// CycleProvider also needs the flag for fertility calculations, so we keep them in sync here.

class ModeSwitcher extends StatelessWidget {
  final bool isTTC;
  final bool isPremium;
  final AppLocalizations l10n;

  const ModeSwitcher({
    super.key,
    required this.isTTC,
    required this.isPremium,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.read<CycleProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isTTC) {
                  HapticFeedback.selectionClick();
                  ModeTransitionOverlay.show(
                    context,
                    TransitionMode.tracking,
                    l10n.transitionTrack,
                    onComplete: () {
                      // ✅ Single UX toggle, two storages.
                      // SettingsProvider controls routing, CycleProvider controls calculations.
                      settingsProvider.setTTCMode(false);
                      cycleProvider.setTTCMode(false);
                    },
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: !isTTC ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.modeTrackCycle,
                  style: GoogleFonts.inter(
                    fontWeight: !isTTC ? FontWeight.w700 : FontWeight.w500,
                    color: !isTTC ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isTTC) {
                  HapticFeedback.selectionClick();

                  if (!isPremium) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PremiumPaywallSheet(),
                    );
                    return;
                  }

                  // 🚫 TTC cannot be enabled while contraceptive mode is active.
                  // Show localized dialog and offer to disable COC first.
                  if (cycleProvider.isCOCEnabled) {
                    _showTTCConflictDialog(
                      context,
                      l10n: l10n,
                      onDisableCOC: () async {
                        await cycleProvider.setCOCMode(false);
                      },
                      onContinue: () {
                        ModeTransitionOverlay.show(
                          context,
                          TransitionMode.ttc,
                          l10n.transitionTTC,
                          onComplete: () {
                            settingsProvider.setTTCMode(true);
                            cycleProvider.setTTCMode(true);
                          },
                        );
                      },
                    );
                    return;
                  }

                  ModeTransitionOverlay.show(
                    context,
                    TransitionMode.ttc,
                    l10n.transitionTTC,
                    onComplete: () {
                      settingsProvider.setTTCMode(true);
                      cycleProvider.setTTCMode(true);
                    },
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isTTC ? (TTCTheme.primaryGold.withOpacity(0.15)) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.modeGetPregnant,
                      style: GoogleFonts.inter(
                        fontWeight: isTTC ? FontWeight.w700 : FontWeight.w500,
                        color: isTTC ? TTCTheme.primaryGold : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isPremium ? Icons.auto_awesome_rounded : Icons.lock_rounded,
                      size: 16,
                      color: isPremium ? TTCTheme.primaryGold : AppColors.textSecondary.withOpacity(0.5),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTTCConflictDialog(
      BuildContext context, {
        required AppLocalizations l10n,
        required Future<void> Function() onDisableCOC,
        required VoidCallback onContinue,
      }) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.dialogTTCConflict),
        content: Text(l10n.dialogTTCConflictBody),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await onDisableCOC();
              onContinue();
            },
            child: Text(l10n.btnConfirm),
          ),
        ],
      ),
    );
  }
}
