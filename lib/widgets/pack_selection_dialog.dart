import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart'; // ✅ Импорт локализации

class PackSelectionDialog extends StatefulWidget {
  final int currentSelection;
  final Function(int) onSelect;

  const PackSelectionDialog({
    super.key,
    required this.currentSelection,
    required this.onSelect,
  });

  @override
  State<PackSelectionDialog> createState() => _PackSelectionDialogState();
}

class _PackSelectionDialogState extends State<PackSelectionDialog> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ Получаем доступ к переводам

    return Center(
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Text(
                  l10n.dialogPackTitle, // "Choose Pack Type"
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dialogPackSubtitle, // "Select the pill pack format..."
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // ОПЦИЯ 1: 21 Таблетка
                _PackOptionCard(
                  title: l10n.pack21Title,       // "21 Pills"
                  subtitle: l10n.pack21Subtitle, // "21 Active + 7 Days Break"
                  icon: Icons.pause_circle_outline_rounded,
                  color: const Color(0xFFFF8A80),
                  isSelected: _selected == 21,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = 21);
                  },
                ),

                const SizedBox(height: 12),

                // ОПЦИЯ 2: 28 Таблеток
                _PackOptionCard(
                  title: l10n.pack28Title,       // "28 Pills"
                  subtitle: l10n.pack28Subtitle, // "21 Active + 7 Placebo"
                  icon: Icons.loop_rounded,
                  color: const Color(0xFF69F0AE),
                  isSelected: _selected == 28,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = 28);
                  },
                ),

                const SizedBox(height: 24),

                // Кнопка Сохранить
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelect(_selected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.btnSaveSettings, // "Save Settings"
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}