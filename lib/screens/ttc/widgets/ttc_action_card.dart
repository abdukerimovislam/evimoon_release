import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';

class TTCActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  // 🔥 НОВЫЕ ПАРАМЕТРЫ
  final String? value;      // Например "36.6°" или "Peak"
  final bool isActive;      // Если данные есть, карточка меняет стиль

  const TTCActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.value,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // Если карточка активна (данные есть), она становится цветной, иначе - стеклянной
    final backgroundColor = isActive
        ? color.withOpacity(0.15)
        : Colors.transparent; // Внутри GlassContainer это будет просто стекло

    final iconBackground = isActive
        ? Colors.white.withOpacity(0.5) // Белая подложка, если карточка цветная
        : color.withOpacity(0.15);      // Цветная подложка, если карточка стеклянная

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        // Переопределяем цвет стекла, если активна
        opacity: isActive ? 0.3 : 0.1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : null, // Легкая заливка
            borderRadius: BorderRadius.circular(20),
            border: isActive ? Border.all(color: color.withOpacity(0.3), width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ИКОНКА (Или Галочка, если активна?)
              // Оставим иконку, но изменим подложку
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle
                ),
                child: Icon(
                  // Если есть значение, можно показать галочку, но лучше оставить иконку категории
                    isActive ? CupertinoIcons.checkmark_alt : icon,
                    color: isActive ? color.withOpacity(1) : color,
                    size: 22
                ),
              ),
              const SizedBox(height: 8),

              // ТЕКСТ (Label или Value)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isActive ? (value ?? label) : label, // Если активна, показываем значение
                  key: ValueKey(isActive ? (value ?? label) : label),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.textPrimary
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}