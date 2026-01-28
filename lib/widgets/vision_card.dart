import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VisionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isGlass; // 🔥 Включить эффект стекла
  final Color? backgroundColor;
  final double borderRadius;

  const VisionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.isGlass = false, // По умолчанию обычная карточка
    this.backgroundColor,
    this.borderRadius = 24, // Более скругленные углы
  });

  @override
  Widget build(BuildContext context) {
    // Базовый контейнер
    Widget cardContent = Container(
      padding: padding,
      width: double.infinity, // Карточка занимает доступную ширину
      decoration: BoxDecoration(
        color: backgroundColor ?? (isGlass
            ? Colors.white.withOpacity(0.65) // Полупрозрачный для стекла
            : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(isGlass ? 0.5 : 0.8), // Тонкая обводка
          width: 1.5,
        ),
        boxShadow: isGlass ? [] : [ // У стекла обычно нет жесткой тени
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );

    // Если включен режим стекла - оборачиваем в блюр
    if (isGlass) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Сила размытия
          child: cardContent,
        ),
      );
    }

    // Если карточка кликабельна
    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent, // Чтобы кликалось даже по прозрачным местам
          child: AnimatedScale( // Микро-анимация нажатия
            scale: 1.0,
            duration: const Duration(milliseconds: 100),
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }
}