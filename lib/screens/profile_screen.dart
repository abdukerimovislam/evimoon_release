import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Для открытия почты
import 'dart:io' show Platform; // ✅ Для определения платформы

// Локализация и Тема
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// Модели
import '../models/cycle_model.dart';

// Провайдеры
import '../providers/settings_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';
import '../providers/coc_provider.dart';

// Сервисы
import '../services/auth_service.dart';
import '../services/pdf_service.dart';
import '../services/backup_service.dart';

// Виджеты
import '../widgets/vision_card.dart';
import '../widgets/coc_start_dialog.dart';
import '../widgets/pack_selection_dialog.dart';

// Экраны
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final settings = Provider.of<SettingsProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);
    final wellnessProvider = Provider.of<WellnessProvider>(context);
    final cocProvider = Provider.of<COCProvider>(context);

    // Инициализация сервиса бэкапа
    final backupService = BackupService(
      Hive.box('cycles'),
      Hive.box('settings'),
    );

    final bool isCOC = cocProvider.isEnabled;
    final double safeCycleLength = cycleProvider.cycleLength.toDouble().clamp(21.0, 45.0);
    final double safePeriodLength = cycleProvider.periodDuration.toDouble().clamp(2.0, 10.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.tabProfile, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // --- АВАТАР ---
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                  ]
              ),
              child: const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
              child: Text("EviMoon User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))
          ),

          const SizedBox(height: 30),

          // --- 1. КОНТРАЦЕПЦИЯ (COC) ---
          _SectionTitle(title: l10n.settingsContraception),
          _SettingsGroup(
            children: [
              _SwitchTile(
                icon: Icons.medication_liquid_rounded,
                title: l10n.settingsTrackPill,
                value: isCOC,
                onChanged: (val) {
                  if (val) {
                    _showCOCStartDialog(context, cocProvider, cycleProvider, l10n);
                  } else {
                    cocProvider.toggleCOC(false);
                    cycleProvider.setCOCMode(false);
                  }
                },
              ),
              if (isCOC) ...[
                const Divider(height: 1, indent: 50, color: Colors.black12),
                _SettingsTile(
                  icon: Icons.grid_on_rounded,
                  title: l10n.settingsPackType,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                        l10n.settingsPills(cocProvider.pillCount),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                    ),
                  ),
                  onTap: () => _showPackTypePicker(context, cocProvider, cycleProvider, l10n),
                ),
                const Divider(height: 1, indent: 50, color: Colors.black12),
                _SettingsTile(
                  icon: Icons.access_alarm_rounded,
                  title: l10n.settingsReminder,
                  trailing: Text(
                      cocProvider.reminderTime.format(context),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(context: context, initialTime: cocProvider.reminderTime);
                    if (newTime != null) {
                      cocProvider.setTime(newTime, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                    }
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: 30),

          // --- 2. НАСТРОЙКИ ЦИКЛА ---
          _SectionTitle(title: isCOC ? l10n.settingsPackSettings : l10n.sectionCycle),
          _SettingsGroup(
            children: [
              if (!isCOC)
                _SliderTile(
                  icon: Icons.loop_rounded,
                  title: l10n.insightAvgCycle,
                  value: safeCycleLength,
                  min: 21, max: 45,
                  onChanged: (val) => cycleProvider.setCycleLength(val.toInt()),
                  suffix: l10n.daysUnit,
                ),
              if (!isCOC) const Divider(height: 1, indent: 50, color: Colors.black12),
              _SliderTile(
                icon: isCOC ? Icons.pause_circle_outline_rounded : Icons.water_drop_rounded,
                title: isCOC
                    ? (cocProvider.pillCount == 28 ? l10n.settingsPlaceboCount : l10n.settingsBreakDuration)
                    : l10n.insightAvgPeriod,
                value: safePeriodLength,
                min: 2, max: 10,
                onChanged: (val) => cycleProvider.setAveragePeriodDuration(val.toInt()),
                suffix: l10n.daysUnit,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --- 3. ОБЩИЕ ---
          _SectionTitle(title: l10n.settingsGeneral),
          _SettingsGroup(
            children: [
              // Язык
              _SettingsTile(
                icon: Icons.language,
                title: l10n.settingsLanguage,
                trailing: DropdownButton<String>(
                  value: settings.locale.languageCode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      settings.setLocale(Locale(val));
                      Provider.of<CycleProvider>(context, listen: false).reload();
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 50, color: Colors.black12),

              // Уведомления
              _SwitchTile(
                icon: Icons.notifications_active_rounded,
                title: l10n.settingsNotifs,
                value: settings.notificationsEnabled,
                onChanged: (val) => settings.setNotifications(val),
              ),

              const Divider(height: 1, indent: 50, color: Colors.black12),

              // ✅ КНОПКА ПОДДЕРЖКИ (EMAIL)
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: l10n.settingsSupport, // Убедитесь, что этот ключ есть в arb файле
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () => _openSupportEmail(context, l10n),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --- 4. ДАННЫЕ И БЕЗОПАСНОСТЬ ---
          _SectionTitle(title: l10n.settingsData),
          _SettingsGroup(
            children: [
              // Биометрия
              _SwitchTile(
                icon: Icons.fingerprint_rounded,
                title: l10n.settingsBiometrics,
                value: settings.biometricsEnabled,
                onChanged: (val) async {
                  if (val) {
                    final auth = AuthService();
                    bool canCheck = await auth.canCheckBiometrics;
                    if (canCheck) {
                      bool success = await auth.authenticate("Confirm to enable biometrics");
                      if (success) settings.setBiometrics(true);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometrics not available on this device")));
                      }
                    }
                  } else {
                    settings.setBiometrics(false);
                  }
                },
              ),
              const Divider(height: 1, indent: 50, color: Colors.black12),

              // Экспорт PDF
              _SettingsTile(
                icon: Icons.picture_as_pdf_rounded,
                title: l10n.settingsExport,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: () async {
                  try {
                    final logs = wellnessProvider.getLogHistory();
                    if (logs.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to export yet.")));
                      }
                      return;
                    }
                    await PdfService().generateAndPrint(logs, cycleProvider.cycleLength);
                  } catch (e) {
                    debugPrint("Export error: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not generate PDF")));
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --- 5. РЕЗЕРВНОЕ КОПИРОВАНИЕ ---
          const _SectionTitle(title: "Backup & Restore"),
          _SettingsGroup(
            children: [
              // Сохранить в файл
              _SettingsTile(
                icon: Icons.cloud_upload_rounded,
                title: "Save Backup",
                trailing: const Icon(Icons.save_alt, size: 20, color: AppColors.primary),
                onTap: () async {
                  await backupService.createBackup(context);
                },
              ),
              const Divider(height: 1, indent: 50, color: Colors.black12),

              // Восстановить из файла
              _SettingsTile(
                icon: Icons.cloud_download_rounded,
                title: "Restore from File",
                trailing: const Icon(Icons.restore_page, size: 20, color: AppColors.primary),
                onTap: () async {
                  showCupertinoDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text("Restore Data?"),
                        content: const Text("This will overwrite your current data with the backup file. Are you sure?"),
                        actions: [
                          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
                          CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text("Restore"),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                bool success = await backupService.restoreBackup(context);
                                if (success && context.mounted) {
                                  Provider.of<CycleProvider>(context, listen: false).reload();
                                  Provider.of<SettingsProvider>(context, listen: false).reload();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Data restored successfully!"), backgroundColor: Colors.green)
                                  );
                                }
                              }
                          ),
                        ],
                      )
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 40),

          // --- КНОПКА СБРОСА ---
          Center(
            child: TextButton(
              onPressed: () => _showDeleteDialog(context, l10n),
              child: Text(
                  l10n.settingsReset,
                  style: TextStyle(color: Colors.red.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- МЕТОД ОТКРЫТИЯ ПОЧТЫ ---
  Future<void> _openSupportEmail(BuildContext context, AppLocalizations l10n) async {
    const String supportEmail = "evimoon.app@proton.me"; // Замени на свой email

    final String subject = Uri.encodeComponent(l10n.emailSubject);
    final String platformName = Platform.isIOS ? "iOS" : "Android";
    final String body = Uri.encodeComponent("${l10n.emailBody} $platformName");

    final Uri emailLaunchUri = Uri.parse("mailto:$supportEmail?subject=$subject&body=$body");

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not open email client. Write to: $supportEmail")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ ДИАЛОГИ ---
  void _showPackTypePicker(BuildContext context, COCProvider coc, CycleProvider cycle, AppLocalizations l10n) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: PackSelectionDialog(
              currentSelection: coc.pillCount,
              onSelect: (newCount) {
                coc.setPillCount(newCount);
                if (newCount == 21) {
                  cycle.setAveragePeriodDuration(7);
                } else {
                  cycle.setAveragePeriodDuration(4);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showCOCStartDialog(BuildContext context, COCProvider coc, CycleProvider cycle, AppLocalizations l10n) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: COCStartDialog(
              onFreshStart: () {
                Navigator.pop(ctx);
                coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                cycle.setCOCMode(true);
                cycle.startNewCycle();
              },
              onContinue: () async {
                Navigator.pop(ctx);
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: AppColors.primary),
                        ),
                        child: child!,
                      );
                    }
                );
                if (picked != null) {
                  coc.toggleCOC(true, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                  cycle.setCOCMode(true);
                  cycle.setSpecificCycleStartDate(picked);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    final storage = Provider.of<SettingsProvider>(context, listen: false).storageService;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.dialogResetTitle),
        content: Text(l10n.dialogResetBody),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.dialogCancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await Hive.deleteFromDisk();
              await storage.clearAll();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                        (route) => false
                );
              }
            },
            child: Text(l10n.dialogResetConfirm),
          ),
        ],
      ),
    );
  }
}

// --- ВИДЖЕТЫ UI ---

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return VisionCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: trailing,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      onTap: () => onChanged(!value),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String suffix;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.suffix
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          trailing: Text(
            "${value.toInt()} $suffix",
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}