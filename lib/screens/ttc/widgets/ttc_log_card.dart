import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ttc_theme.dart';
import '../../../models/cycle_model.dart';
import '../../../models/personal_model.dart';

class TTCQuickLogCard extends StatelessWidget {
  final DateTime date;
  final SymptomLog log;
  final VoidCallback onBBT;
  final VoidCallback onTest;
  final VoidCallback onSex;
  final VoidCallback onMucus;

  const TTCQuickLogCard({
    super.key,
    required this.date,
    required this.log,
    required this.onBBT,
    required this.onTest,
    required this.onSex,
    required this.onMucus,
  });

  // Метод для показа образовательной шторки
  void _showEduSheet(BuildContext context, String title, String body) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TTCTheme.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lightbulb_rounded, color: TTCTheme.primaryGold, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text("Got it"),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final doneBBT = (log.temperature != null && (log.temperature ?? 0) > 0);
    final doneLH = (log.ovulationTest != OvulationTestResult.none);
    final doneSex = log.hadSex;

    final doneCount = (doneBBT ? 1 : 0) + (doneLH ? 1 : 0) + (doneSex ? 1 : 0);

    String? testVal;
    if (log.ovulationTest == OvulationTestResult.positive) testVal = l10n.valPositive;
    if (log.ovulationTest == OvulationTestResult.peak) testVal = l10n.valPeak;
    if (log.ovulationTest == OvulationTestResult.negative) testVal = l10n.valNegative;

    String remainingText;
    if (doneCount == 3) {
      remainingText = l10n.ttcAllDone;
    } else {
      final missing = <String>[];
      if (!doneBBT) missing.add(l10n.ttcShortBBT);
      if (!doneLH) missing.add(l10n.ttcShortLH);
      if (!doneSex) missing.add(l10n.ttcShortSex);
      remainingText = l10n.ttcMissingList(missing.join(', '));
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.ttcLogTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Text(
                  '$doneCount/3',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔥 ВАРИАНТ 1: Baby Steps ProgressBar
          _BabyStepsProgressBar(stepsDone: doneCount),

          const SizedBox(height: 12),
          Opacity(
            opacity: 0.7,
            child: Text(
              remainingText,
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _MiniTile(
                  title: l10n.ttcSectionBBT,
                  value: doneBBT ? (log.temperature?.toStringAsFixed(2) ?? '') : null,
                  icon: Icons.thermostat_rounded,
                  onTap: onBBT,
                  onInfoTap: () => _showEduSheet(context, l10n.eduTitleBBT, l10n.eduBodyBBT),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniTile(
                  title: l10n.ttcSectionTest,
                  value: testVal,
                  icon: Icons.water_drop_rounded,
                  onTap: onTest,
                  onInfoTap: () => _showEduSheet(context, l10n.eduTitleLH, l10n.eduBodyLH),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniTile(
                  title: l10n.ttcSectionSex,
                  value: log.hadSex ? l10n.valSexYes : null,
                  icon: Icons.favorite_rounded,
                  onTap: onSex,
                  onInfoTap: () => _showEduSheet(context, l10n.eduTitleSex, l10n.eduBodySex),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniTile(
                  title: l10n.titleInputMucus,
                  value: log.mucus != CervicalMucusType.none ? l10n.valMucusLogged : null,
                  icon: Icons.spa_rounded,
                  onTap: onMucus,
                  onInfoTap: () => _showEduSheet(context, l10n.eduTitleMucus, l10n.eduBodyMucus),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔥 ВАРИАНТ 1: Реализация Baby Steps
class _BabyStepsProgressBar extends StatelessWidget {
  final int stepsDone; // 0, 1, 2, or 3

  const _BabyStepsProgressBar({required this.stepsDone});

  Widget _buildConnector(bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 3,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.5) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    final isActive = stepsDone >= index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      width: isActive ? 28 : 16,
      height: isActive ? 28 : 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? LinearGradient(colors: [AppColors.primary, TTCTheme.primaryGold])
            : null,
        color: isActive ? null : Colors.black.withOpacity(0.1),
        boxShadow: isActive
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
            : [],
      ),
      child: isActive
          ? Icon(Icons.child_care_rounded, color: Colors.white, size: 18)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _buildStep(1),
          _buildConnector(stepsDone >= 2),
          _buildStep(2),
          _buildConnector(stepsDone >= 3),
          _buildStep(3),
        ],
      ),
    );
  }
}

// --- Обновленный MiniTile с кнопкой инфо ---
class _MiniTile extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const _MiniTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final has = value != null && value!.isNotEmpty;

    return Semantics(
      button: true,
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: has ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          has ? value! : l10n.ttcDash,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: has ? AppColors.textPrimary : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: onInfoTap,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 14,
                    color: AppColors.textSecondary.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}