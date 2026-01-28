import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';
import '../providers/coc_provider.dart';
import '../theme/app_theme.dart';
import '../screens/profile/profile_settings_list.dart'; // Для ProfileSliderTile

class CycleSettingsSheet extends StatelessWidget {
  const CycleSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cycle = context.watch<CycleProvider>();
    final coc = context.watch<COCProvider>();
    final isCOC = coc.isEnabled;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            isCOC ? l10n.settingsPackSettings : l10n.sectionCycle,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),

          // Sliders
          if (!isCOC)
            ProfileSliderTile(
              icon: Icons.loop_rounded,
              title: l10n.insightAvgCycle, // "Средний цикл"
              value: cycle.cycleLength.toDouble().clamp(21.0, 45.0),
              min: 21, max: 45,
              onChanged: (val) => cycle.setCycleLength(val.toInt()),
              suffix: l10n.daysUnit,
            ),

          if (!isCOC) const SizedBox(height: 16),

          ProfileSliderTile(
            icon: isCOC ? Icons.pause_circle_outline_rounded : Icons.water_drop_rounded,
            title: isCOC
                ? (coc.pillCount == 28 ? l10n.settingsPlaceboCount : l10n.settingsBreakDuration)
                : l10n.insightAvgPeriod, // "Средние месячные"
            value: cycle.periodDuration.toDouble().clamp(2.0, 10.0),
            min: 2, max: 10,
            onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
            suffix: l10n.daysUnit,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}