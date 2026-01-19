import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class CycleTimelineWidget extends StatefulWidget {
  const CycleTimelineWidget({super.key});

  @override
  State<CycleTimelineWidget> createState() => _CycleTimelineWidgetState();
}

class _CycleTimelineWidgetState extends State<CycleTimelineWidget> {
  // Показываем прогноз на 30 дней вперед
  final int _daysToDisplay = 30;

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            l10n.calendarForecastTitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),

        // Сама лента
        SizedBox(
          height: 85, // Высота ленты
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _daysToDisplay,
            separatorBuilder: (ctx, index) => const SizedBox(width: 12),
            itemBuilder: (ctx, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isToday = index == 0;

              // 🔮 Спрашиваем у провайдера фазу для этой даты
              final phase = cycleProvider.getPhaseForDate(date);
              final color = _getColorForPhase(phase);
              final isPeriod = phase == CyclePhase.menstruation;
              final isOvulation = phase == CyclePhase.ovulation;

              return _DateCapsule(
                date: date,
                color: color,
                isToday: isToday,
                isFilled: isPeriod, // Заливаем цветом только месячные
                hasDot: isOvulation, // Точка для овуляции
              );
            },
          ),
        ),
      ],
    );
  }

  // Хелпер для цветов фаз
  Color _getColorForPhase(CyclePhase? phase) {
    if (phase == null) return Colors.grey.withOpacity(0.3);
    switch (phase) {
      case CyclePhase.menstruation: return AppColors.menstruation;
      case CyclePhase.follicular: return AppColors.follicular.withOpacity(0.6); // Чуть бледнее
      case CyclePhase.ovulation: return AppColors.ovulation;
      case CyclePhase.luteal: return AppColors.luteal.withOpacity(0.6);
      default: return Colors.grey;
    }
  }
}

class _DateCapsule extends StatelessWidget {
  final DateTime date;
  final Color color;
  final bool isToday;
  final bool isFilled;
  final bool hasDot;

  const _DateCapsule({
    required this.date,
    required this.color,
    required this.isToday,
    required this.isFilled,
    required this.hasDot,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем код текущего языка
    final localeCode = Localizations.localeOf(context).toString();

    // Форматируем день недели (Пн, Вт...) и число (12, 13...)
    final dayName = DateFormat('E', localeCode).format(date).toUpperCase();
    final dayNum = DateFormat('d').format(date);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // День недели
        Text(
          dayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isToday ? AppColors.primary : AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),

        // Кружок с числом
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            // 🔥 FIX: Используем AppColors.surface вместо Colors.white
            color: isFilled ? color : (isToday ? AppColors.primary : AppColors.surface),
            shape: BoxShape.circle,
            border: isToday
                ? null // У "сегодня" нет обводки, есть заливка
                : Border.all(
                color: isFilled ? Colors.transparent : Colors.grey.withOpacity(0.2),
                width: 1
            ),
            boxShadow: isToday
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : (isFilled ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))] : null),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Число
              Text(
                dayNum,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // Белый текст на активных элементах, иначе цвет темы
                  color: isFilled || isToday ? Colors.white : AppColors.textPrimary,
                ),
              ),

              // Индикатор фазы (если это не месячные и не сегодня)
              if (!isFilled && !isToday)
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: hasDot ? AppColors.ovulation : color, // Овуляция ярче
                      shape: BoxShape.circle,
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}