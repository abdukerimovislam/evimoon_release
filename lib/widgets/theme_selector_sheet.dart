import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart'; // Импорт локализации
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.selectThemeTitle, // "Select Theme" / "Выберите тему"
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: AppThemeType.values.length,
            itemBuilder: (context, index) {
              final themeType = AppThemeType.values[index];
              return _ThemeCard(
                type: themeType,
                isSelected: settings.currentTheme == themeType,
                onTap: () => settings.setTheme(themeType),
                l10n: l10n,
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeType type;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _ThemeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.getPalette(type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? palette.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -10, top: -10, child: CircleAvatar(backgroundColor: palette.primary.withOpacity(0.2), radius: 30)),
            Positioned(right: 10, top: 10, child: CircleAvatar(backgroundColor: palette.primary, radius: 10)),
            Positioned(right: 25, top: 30, child: CircleAvatar(backgroundColor: palette.menstruation, radius: 8)),

            Positioned(
              left: 16, bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getThemeName(type, l10n),
                    style: GoogleFonts.inter(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isSelected)
                    Text(
                      l10n.themeActive, // "Active" / "Активна"
                      style: GoogleFonts.inter(
                          color: palette.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                ],
              ),
            ),

            if (isSelected)
              Positioned(
                top: 8, left: 8,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: palette.primary,
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(AppThemeType type, AppLocalizations l10n) {
    switch (type) {
      case AppThemeType.oceanic: return l10n.themeOceanic;
      case AppThemeType.nature: return l10n.themeNature;
      case AppThemeType.velvet: return l10n.themeVelvet;
      case AppThemeType.digital: return l10n.themeDigital;
    }
  }
}