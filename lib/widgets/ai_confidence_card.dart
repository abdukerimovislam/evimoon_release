import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/cycle_ai_engine.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class AIConfidenceCard extends StatelessWidget {
  final CycleConfidenceResult? confidence;
  final VoidCallback? onTap;

  const AIConfidenceCard({
    super.key,
    required this.confidence,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = confidence;
    if (c == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    late final Color accentColor;
    late final Color iconBgColor;
    late final IconData icon;
    late final String title;
    late final String subtitle;

    final bool isCalculating = c.level == ConfidenceLevel.calculating;

    switch (c.level) {
      case ConfidenceLevel.high:
        accentColor = AppColors.follicular;
        iconBgColor = const Color(0xFFE8F3F1);
        icon = Icons.verified_user_outlined;
        title = l10n.aiForecastHigh;
        subtitle = l10n.aiForecastHighSub;
        break;
      case ConfidenceLevel.medium:
        accentColor = AppColors.ovulation;
        iconBgColor = const Color(0xFFFFF8EC);
        icon = Icons.shield_outlined;
        title = l10n.aiForecastMedium;
        subtitle = l10n.aiForecastMediumSub;
        break;
      case ConfidenceLevel.low:
        accentColor = AppColors.menstruation;
        iconBgColor = const Color(0xFFF9EAEB);
        icon = Icons.info_outline_rounded;
        title = l10n.aiForecastLow;
        subtitle = l10n.aiForecastLowSub;
        break;
      case ConfidenceLevel.calculating:
        accentColor = AppColors.primary;
        iconBgColor = AppColors.secondaryBackground;
        icon = Icons.hourglass_empty_rounded;
        title = l10n.aiLearning;
        subtitle = l10n.aiLearningSub;
        break;
    }

    final int scoreInt = c.score.clamp(0, 100);
    final double percent = (scoreInt / 100.0).clamp(0.0, 1.0);

    return Semantics(
      button: onTap != null,
      label: isCalculating ? title : '$title, $scoreInt',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A4063).withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.03)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isCalculating) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isCalculating)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 3.5,
                            backgroundColor: AppColors.secondaryBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '$scoreInt',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    )
                  else
                    _PulsingRing(color: accentColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingRing extends StatefulWidget {
  final Color color;
  const _PulsingRing({required this.color});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _value;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _value = Tween<double>(begin: 0.15, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _value,
      builder: (_, __) {
        return SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(
            value: _value.value,
            strokeWidth: 3.5,
            backgroundColor: AppColors.secondaryBackground,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            strokeCap: StrokeCap.round,
          ),
        );
      },
    );
  }
}
