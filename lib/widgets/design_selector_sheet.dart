import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/timer_design.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_paywall_sheet.dart';
import '../l10n/app_localizations.dart';

class DesignSelectorSheet extends StatelessWidget {
  const DesignSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Индикатор
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.designSelectorTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              if (settings.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.amber.shade300,
                      Colors.orange.shade300
                    ]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                      l10n.badgePremium,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1
                      )
                  ),
                )
            ],
          ),
          const SizedBox(height: 24),

          // Сетка
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: TimerDesign.values.map((design) {
              final isSelected = settings.currentDesign == design;
              final isLocked = design.isPremium && !settings.isPremium;

              return GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();

                  bool success = await settings.setDesign(design);

                  if (!success && context.mounted) {
                    Navigator.pop(context);
                    _showPaywallStub(context, settings);
                  }
                },
                child: Column(
                  children: [
                    // Карточка
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.05)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2.5)
                            : Border.all(color: Colors.grey[200]!),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ]
                            : [],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                              design.icon,
                              size: 42,
                              color: isSelected ? AppColors.primary : Colors.grey[400]
                          ),

                          if (isLocked)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.lock_rounded, color: Colors.white,
                                      size: 18),
                                ),
                              ),
                            ),

                          if (isSelected)
                            Positioned(
                              top: 8, right: 8,
                              child: Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 22),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Название
                    Text(
                      _getDesignName(design, l10n),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🔥 Обновленный хелпер с учетом всех вариантов
  String _getDesignName(TimerDesign design, AppLocalizations l10n) {
    switch (design) {
      case TimerDesign.classic:
        return l10n.designClassic;
      case TimerDesign.minimal:
        return l10n.designMinimal;
      case TimerDesign.lunar:
        return l10n.designLunar;
      case TimerDesign.bloom:
        return l10n.designBloom;
      case TimerDesign.liquid:
        return l10n.designLiquid;
      case TimerDesign.orbit:
        return l10n.designOrbit;
      case TimerDesign.zen:
        return l10n.designZen;
      default:
        return design.toString().split('.').last; // Fallback
    }
  }

  void _showPaywallStub(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PremiumPaywallSheet(),
    );
  }
}