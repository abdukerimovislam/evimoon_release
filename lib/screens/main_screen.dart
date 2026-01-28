import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui'; // Для Blur
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart'; // ✅ Импорт настроек

// Виджет фона
import '../widgets/mesh_background.dart';

// Экраны
import 'home_screen.dart';
import 'ttc/ttc_home_screen.dart';
import 'symptom_log_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'insights_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Стартуем с индекса 2 (Центр)
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context); // ✅ Слушаем настройки

    final cyclePhase = cycleProvider.currentData.phase;
    final isTTC = settingsProvider.isTTCMode; // ✅ Проверяем режим

    // ✅ Keep CycleProvider in sync with SettingsProvider.
    // SettingsProvider controls routing (MainScreen), CycleProvider controls fertility calculations.
    if (cycleProvider.isTTCMode != isTTC) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cp = context.read<CycleProvider>();
        if (cp.isTTCMode != isTTC) {
          cp.setTTCMode(isTTC);
        }
      });
    }

    // 🔥 ДИНАМИЧЕСКИЙ СПИСОК ЭКРАНОВ
    // Пересоздается при изменении isTTCMode
    final List<Widget> currentScreens = [
      const CalendarScreen(), // 0
      const InsightsScreen(), // 1

      // 2. ЦЕНТР: Выбираем экран в зависимости от режима
      isTTC ? const TTCHomeScreen() : const HomeScreen(),

      SymptomLogScreen( // 3
        date: DateTime.now(),
        isTab: true,
      ),
      const ProfileScreen(), // 4
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: MeshCycleBackground(
        phase: cyclePhase,
        child: Stack(
          children: [
            // 1. Контент
            IndexedStack(
              index: _currentIndex,
              children: currentScreens,
            ),

            // 2. Парящая стеклянная навигация
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 10 : 25,
              child: _CrystalNavBar(
                currentIndex: _currentIndex,
                isTTCMode: isTTC, // ✅ Передаем режим в навбар
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 💎 CRYSTAL NAV BAR ---
class _CrystalNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isTTCMode; // ✅ Флаг режима
  final ValueChanged<int> onTap;

  const _CrystalNavBar({
    required this.currentIndex,
    required this.isTTCMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A4063).withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: CupertinoIcons.calendar,
                index: 0,
                isSelected: currentIndex == 0,
                onTap: onTap,
              ),
              _NavBarItem(
                icon: CupertinoIcons.graph_square,
                index: 1,
                isSelected: currentIndex == 1,
                onTap: onTap,
              ),

              // ЦЕНТРАЛЬНАЯ КНОПКА
              _NavBarItem(
                icon: isTTCMode ? CupertinoIcons.star_fill : CupertinoIcons.drop, // Звезда для TTC
                index: 2,
                isSelected: currentIndex == 2,
                onTap: onTap,
                isCenter: true,
                // ✅ Если TTC - цвет золотой, иначе стандартный
                activeColor: isTTCMode ? Colors.amber : AppColors.primary,
              ),

              _NavBarItem(
                icon: CupertinoIcons.list_bullet,
                index: 3,
                isSelected: currentIndex == 3,
                onTap: onTap,
              ),
              _NavBarItem(
                icon: CupertinoIcons.person,
                index: 4,
                isSelected: currentIndex == 4,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;
  final bool isCenter;
  final Color? activeColor; // ✅ Возможность переопределить цвет

  const _NavBarItem({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.isCenter = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: isCenter ? const EdgeInsets.all(14) : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
          color: isCenter ? effectiveActiveColor : effectiveActiveColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(22),
        )
            : const BoxDecoration(color: Colors.transparent),
        child: Icon(
          isSelected ? _getSelectedIcon(icon) : icon,
          size: isCenter ? 32 : 26,
          color: isSelected ? (isCenter ? Colors.white : effectiveActiveColor) : AppColors.textSecondary.withOpacity(0.6),
        ),
      ),
    );
  }

  IconData _getSelectedIcon(IconData icon) {
    // Небольшая “магия” для выбранного состояния
    if (icon == CupertinoIcons.calendar) return CupertinoIcons.calendar_today;
    if (icon == CupertinoIcons.graph_square) return CupertinoIcons.graph_square_fill;
    if (icon == CupertinoIcons.drop) return CupertinoIcons.drop_fill;
    if (icon == CupertinoIcons.star_fill) return CupertinoIcons.star_fill;
    if (icon == CupertinoIcons.list_bullet) return CupertinoIcons.list_bullet_indent;
    if (icon == CupertinoIcons.person) return CupertinoIcons.person_fill;
    return icon;
  }
}
