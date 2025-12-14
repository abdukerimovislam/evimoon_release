import 'package:flutter/material.dart';
import 'dart:ui'; // Для ImageFilter

class VisionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;

  const VisionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), // Более скругленные углы (Apple style)
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Размытие фона под карточкой
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Градиентная заливка: сверху светлее, снизу прозрачнее
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.6), // Светлый блик
                    Colors.white.withOpacity(0.3), // Прозрачность
                  ],
                ),
                // Тонкая обводка (Border) - "фишка" VisionOS
                border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5
                ),
                borderRadius: BorderRadius.circular(24),
                // Мягкая тень
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}