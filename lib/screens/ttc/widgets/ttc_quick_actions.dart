import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class TTCQuickActionsDock extends StatelessWidget {
  final VoidCallback onBBT;
  final VoidCallback onTest;
  final VoidCallback onSex;
  final VoidCallback onMucus;

  const TTCQuickActionsDock({
    super.key,
    required this.onBBT,
    required this.onTest,
    required this.onSex,
    required this.onMucus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _DockButton(
                  icon: Icons.thermostat_rounded,
                  label: l10n.ttcShortBBT,
                  onTap: onBBT,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DockButton(
                  icon: Icons.water_drop_rounded,
                  label: l10n.ttcShortLH,
                  onTap: onTest,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DockButton(
                  icon: Icons.favorite_rounded,
                  label: l10n.ttcShortSex,
                  onTap: onSex,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DockButton(
                  icon: Icons.spa_rounded,
                  label: l10n.ttcShortMucus,
                  onTap: onMucus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DockButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}