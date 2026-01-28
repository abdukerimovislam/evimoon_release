import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui; // Для ImageFilter
import 'package:provider/provider.dart';

import '../models/cycle_model.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class MeshCycleBackground extends StatefulWidget {
  final CyclePhase phase;
  final Widget child;

  const MeshCycleBackground({
    super.key,
    required this.phase,
    required this.child,
  });

  @override
  State<MeshCycleBackground> createState() => _MeshCycleBackgroundState();
}

class _MeshCycleBackgroundState extends State<MeshCycleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🔥 ГЛАВНАЯ ЛОГИКА: Выбор цветов в зависимости от Темы и Фазы
  List<Color> _getThemeColors(AppThemeType theme, CyclePhase phase) {
    switch (theme) {
      case AppThemeType.oceanic:
        return _getOceanicColors(phase);
      case AppThemeType.nature:
        return _getNatureColors(phase);
      case AppThemeType.velvet:
        return _getVelvetColors(phase);
      case AppThemeType.digital:
        return _getDigitalColors(phase);
    }
  }

  // --- 1. OCEANIC (Свежесть, Вода, Коралл) ---
  List<Color> _getOceanicColors(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation: // Мягкий коралл
        return [const Color(0xFFF8EDEB), const Color(0xFFFFB5A7), const Color(0xFFFCD5CE)];
      case CyclePhase.follicular: // Морская пена
        return [const Color(0xFFEDF6F9), const Color(0xFFA8DADC), const Color(0xFFE0FBFC)];
      case CyclePhase.ovulation: // Солнечный пляж
        return [const Color(0xFFFFFBEB), const Color(0xFFFFD166), const Color(0xFFFFE8D6)];
      case CyclePhase.luteal: // Глубина океана
        return [const Color(0xFFF1FAEE), const Color(0xFF457B9D), const Color(0xFFA8DADC)];
      default:
        return [const Color(0xFFEDF6F9), const Color(0xFF83C5BE), const Color(0xFFE29578)];
    }
  }

  // --- 2. NATURE (Земля, Зелень, Глина) ---
  List<Color> _getNatureColors(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation: // Глина / Терракота
        return [const Color(0xFFFAEDCD), const Color(0xFFBC4749), const Color(0xFFE9EDC9)];
      case CyclePhase.follicular: // Молодой росток
        return [const Color(0xFFFEFAE0), const Color(0xFFA3B18A), const Color(0xFFCCD5AE)];
      case CyclePhase.ovulation: // Песок и солнце
        return [const Color(0xFFFFF3B0), const Color(0xFFD4A373), const Color(0xFFFAEDCD)];
      case CyclePhase.luteal: // Лес и олива
        return [const Color(0xFFE9EDC9), const Color(0xFF588157), const Color(0xFFA3B18A)];
      default:
        return [const Color(0xFFFEFAE0), const Color(0xFFCCD5AE), const Color(0xFFD4A373)];
    }
  }

  // --- 3. VELVET (Розовый, Персик, Вино) ---
  List<Color> _getVelvetColors(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation: // Ягодный / Вишневый
        return [const Color(0xFFFFF0F3), const Color(0xFFFF4D6D), const Color(0xFFFF8FA3)];
      case CyclePhase.follicular: // Розовая пудра
        return [const Color(0xFFFFF0F3), const Color(0xFFD4B5B0), const Color(0xFFFFCCD5)];
      case CyclePhase.ovulation: // Нежный персик
        return [const Color(0xFFFFF5F5), const Color(0xFFFFB3C1), const Color(0xFFFFD6E0)];
      case CyclePhase.luteal: // Лиловый вечер
        return [const Color(0xFFF3E5F5), const Color(0xFF9D8189), const Color(0xFF6D597A)];
      default:
        return [const Color(0xFFFFF0F3), const Color(0xFFE5989B), const Color(0xFFFFB4A2)];
    }
  }

  // --- 4. DIGITAL (Неон, Кибер, Космос) ---
  List<Color> _getDigitalColors(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation: // Неоновый красный
        return [const Color(0xFFF8F9FC), const Color(0xFFEF233C), const Color(0xFFFF006E)];
      case CyclePhase.follicular: // Электрик фиолетовый
        return [const Color(0xFFF8F9FC), const Color(0xFF7209B7), const Color(0xFF3A0CA3)];
      case CyclePhase.ovulation: // Циан / Голубой лазер
        return [const Color(0xFFF8F9FC), const Color(0xFF4CC9F0), const Color(0xFF4361EE)];
      case CyclePhase.luteal: // Маджента
        return [const Color(0xFFF8F9FC), const Color(0xFFF72585), const Color(0xFF7209B7)];
      default:
        return [const Color(0xFFF8F9FC), const Color(0xFF4CC9F0), const Color(0xFFF72585)];
    }
  }

  @override
  void initState() {
    super.initState();
    // Очень медленное "дыхание" фона (12 секунд)
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 12)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем провайдер настроек для получения текущей темы
    final settings = context.watch<SettingsProvider>();

    // Получаем цвета [Фон, Пятно1, Пятно2]
    final colors = _getThemeColors(settings.currentTheme, widget.phase);

    return Stack(
      children: [
        // 1. Базовый цвет фона (плавная смена при переключении темы)
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(color: colors[0]),
        ),

        // 2. Движущиеся пятна (Blobs)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // Траектория движения (Лиссажу)
            final dx1 = sin(t * 2 * pi) * 0.35;
            final dy1 = cos(t * 2 * pi) * 0.25;

            final dx2 = cos(t * 2 * pi) * 0.35;
            final dy2 = sin(t * 2 * pi) * -0.25;

            return Stack(
              children: [
                // Пятно 1 (Верхний левый угол -> Центр)
                Align(
                  alignment: Alignment(-0.7 + dx1, -0.6 + dy1),
                  child: _BlurBlob(color: colors[1].withOpacity(0.6), size: 400),
                ),

                // Пятно 2 (Нижний правый угол -> Центр)
                Align(
                  alignment: Alignment(0.7 + dx2, 0.6 + dy2),
                  child: _BlurBlob(color: colors[2].withOpacity(0.6), size: 350),
                ),
              ],
            );
          },
        ),

        // 3. Super Glass Blur (Размывает пятна в мягкий градиент)
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0), // Сильный блюр!
          child: Container(color: Colors.transparent),
        ),

        // 4. Контент приложения
        widget.child,
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    // Используем AnimatedContainer для плавной смены цвета
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}