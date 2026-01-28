import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'cycle_settings_sheet.dart';

class LastCycleBadge extends StatelessWidget {
  const LastCycleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final l10n = AppLocalizations.of(context)!; // 🔥 Теперь используем локализацию

    String label = l10n.lblPreviousCycle;
    String value;
    bool hasHistory = cycleProvider.history.isNotEmpty;

    if (hasHistory) {
      // history[0] - это последний завершенный цикл
      final lastCycle = cycleProvider.history.first;

      // Вычисляем длину, если она не сохранена явно
      int length = lastCycle.length ?? 0;
      if (length == 0 && lastCycle.endDate != null) {
        length = lastCycle.endDate!.difference(lastCycle.startDate).inDays + 1;
      }

      // Используем локализованную единицу измерения (daysUnit)
      value = "$length ${l10n.daysUnit}";
    } else {
      value = l10n.lblNoData; // "--"
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const CycleSettingsSheet(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  "$label: ",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.tune_rounded, size: 14, color: AppColors.primary.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}