import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class COCStartDialog extends StatelessWidget {
  final VoidCallback onFreshStart;
  final VoidCallback onContinue;

  const COCStartDialog({
    super.key,
    required this.onFreshStart,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medication_liquid_rounded, size: 32, color: Colors.teal),
                ),
                const SizedBox(height: 16),

                // Текст
                Text(
                  l10n.dialogCOCStartTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dialogCOCStartSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // КНОПКА 1: Fresh Start
                _ActionCard(
                  title: l10n.optionFreshPack,
                  subtitle: l10n.optionFreshPackSub,
                  icon: Icons.play_circle_fill_rounded,
                  color: const Color(0xFF00C853),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onFreshStart();
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.labelOr, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ),

                // КНОПКА 2: Continue
                _ActionCard(
                  title: l10n.optionContinuePack,
                  subtitle: l10n.optionContinuePackSub,
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF2962FF),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onContinue();
                  },
                ),

                const SizedBox(height: 20),

                // Отмена
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.btnCancel, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}