import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
import '../models/timer_design.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_paywall_sheet.dart';

class DesignSelectorSheet extends StatelessWidget {
  const DesignSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Слушаем провайдер, чтобы обновлять UI при смене выбора или покупке премиума
    final settings = context.watch<SettingsProvider>();

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
          // Заголовок и индикатор перетаскивания
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Timer Style",
                style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              if (settings.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.amber.shade300,
                      Colors.orange.shade300
                    ]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("PREMIUM", style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1)),
                )
            ],
          ),
          const SizedBox(height: 24),

          // Сетка Дизайнов
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: TimerDesign.values.map((design) {
              final isSelected = settings.currentDesign == design;
              final isLocked = design.isPremium && !settings.isPremium;

              return GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();

                  // Пытаемся установить дизайн
                  bool success = await settings.setDesign(design);

                  if (!success && context.mounted) {
                    // Если не вышло (нужен премиум) -> показываем Paywall
                    Navigator.pop(context); // Закрываем выбор
                    _showPaywallStub(context, settings);
                  }
                },
                child: Column(
                  children: [
                    // Карточка превью
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
                          // Иконка дизайна
                          Icon(
                              design.icon,
                              size: 42,
                              color: isSelected ? AppColors.primary : Colors
                                  .grey[400]
                          ),

                          // Слой замка (если закрыто)
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

                          // Галочка (если выбрано)
                          if (isSelected)
                            const Positioned(
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
                      design.name
                          .split(" ")
                          .last, // Берем последнее слово для краткости
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight
                            .w500,
                        color: isSelected ? AppColors.primary : AppColors
                            .textSecondary,
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

  // --- ЗАГЛУШКА PAYWALL (ЭКРАН ПОКУПКИ) ---
  void _showPaywallStub(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PremiumPaywallSheet(), // Используем новый виджет
    );
  }
}