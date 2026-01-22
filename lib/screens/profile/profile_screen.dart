import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Imports
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/cycle_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/wellness_provider.dart';
import '../../providers/coc_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/backup_service.dart';
import '../../widgets/vision_card.dart';
import '../../widgets/mode_transition_overlay.dart';
import '../../widgets/premium_paywall_sheet.dart';

import '../profile/profile_logic_mixin.dart';
import '../profile/profile_settings_list.dart';

class ProfileScreen extends StatelessWidget with ProfileLogicMixin {
  const ProfileScreen({super.key});

  // Проверяем, открыты ли боксы перед бэкапом
  Future<void> _ensureBoxes() async {
    if (!Hive.isBoxOpen('cycles')) await Hive.openBox('cycles');
    if (!Hive.isBoxOpen('settings')) await Hive.openBox('settings');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final settings = context.watch<SettingsProvider>();
    final cycle = context.watch<CycleProvider>();
    final wellness = context.watch<WellnessProvider>();
    final coc = context.watch<COCProvider>();

    final bool isCOC = coc.isEnabled;
    final bool isTTC = settings.isTTCMode;
    final bool isPremium = settings.isPremium;

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
          // --- AVATAR ---
          _buildAvatar(isTTC),
          const SizedBox(height: 10),
          Center(child: Text(l10n.lblUser, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          const SizedBox(height: 30),

          // ❌ КАРТОЧКА TTC УДАЛЕНА ОТСЮДА

          // --- 1. CONTRACEPTION ---
          if (!isTTC) ...[
            ProfileSectionTitle(title: l10n.settingsContraception),
            ProfileSettingsGroup(children: [
              ProfileSwitchTile(
                icon: Icons.medication_liquid_rounded,
                title: l10n.settingsTrackPill,
                value: isCOC,
                onChanged: (val) {
                  if (val) {
                    showCOCStartDialog(context);
                  } else {
                    // Анимация выключения
                    ModeTransitionOverlay.show(context, TransitionMode.tracking, l10n.transitionTrack, onComplete: () {
                      coc.toggleCOC(false);
                      cycle.setCOCMode(false);
                      goToHome(context);
                    });
                  }
                },
              ),
              if (isCOC) ...[
                const Divider(height: 1, indent: 50, color: Colors.black12),
                ProfileSettingsTile(
                  icon: Icons.grid_on_rounded,
                  title: l10n.settingsPackType,
                  trailing: _buildBadge(l10n.settingsPills(coc.pillCount)),
                  onTap: () => showPackTypePicker(context),
                ),
                const Divider(height: 1, indent: 50, color: Colors.black12),
                ProfileSettingsTile(
                  icon: Icons.access_alarm_rounded,
                  title: l10n.settingsReminder,
                  trailing: Text(coc.reminderTime.format(context), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final newTime = await showTimePicker(context: context, initialTime: coc.reminderTime);
                    if (newTime != null) coc.setTime(newTime, notifTitle: l10n.notifPillTitle, notifBody: l10n.notifPillBody);
                  },
                ),
              ],
            ]),
            const SizedBox(height: 30),
          ],

          // --- 2. CYCLE SETTINGS ---
          ProfileSectionTitle(title: isCOC ? l10n.settingsPackSettings : l10n.sectionCycle),
          ProfileSettingsGroup(children: [
            if (!isCOC)
              ProfileSliderTile(
                icon: Icons.loop_rounded,
                title: l10n.insightAvgCycle,
                value: cycle.cycleLength.toDouble().clamp(21.0, 45.0),
                min: 21, max: 45,
                onChanged: (val) => cycle.setCycleLength(val.toInt()),
                suffix: l10n.daysUnit,
              ),
            if (!isCOC) const Divider(height: 1, indent: 50, color: Colors.black12),
            ProfileSliderTile(
              icon: isCOC ? Icons.pause_circle_outline_rounded : Icons.water_drop_rounded,
              title: isCOC ? (coc.pillCount == 28 ? l10n.settingsPlaceboCount : l10n.settingsBreakDuration) : l10n.insightAvgPeriod,
              value: cycle.periodDuration.toDouble().clamp(2.0, 10.0),
              min: 2, max: 10,
              onChanged: (val) => cycle.setAveragePeriodDuration(val.toInt()),
              suffix: l10n.daysUnit,
            ),
          ]),
          const SizedBox(height: 30),

          // --- 3. GENERAL ---
          ProfileSectionTitle(title: l10n.settingsGeneral),
          ProfileSettingsGroup(children: [
            ProfileSettingsTile(
              icon: Icons.language,
              title: l10n.settingsLanguage,
              trailing: DropdownButton<String>(
                value: settings.locale.languageCode,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                items: const [DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'ru', child: Text('Русский'))],
                onChanged: (val) { if (val != null) settings.setLocale(Locale(val)); cycle.reload(); },
              ),
            ),
            const Divider(height: 1, indent: 50, color: Colors.black12),

            ProfileSwitchTile(
                icon: Icons.notifications_active_rounded,
                title: l10n.settingsNotifs,
                value: settings.notificationsEnabled,
                onChanged: settings.setNotifications// Исправлено на правильный метод провайдера
            ),

            if (settings.notificationsEnabled) ...[
              const Divider(height: 1, indent: 50, color: Colors.black12),
              ProfileSwitchTile(
                icon: Icons.nights_stay_rounded,
                title: l10n.settingsDailyLog ?? "Daily Check-in",
                value: settings.dailyLogEnabled,
                onChanged: (val) => settings.toggleDailyLogReminder(val),
              ),
            ],

            const Divider(height: 1, indent: 50, color: Colors.black12),
            ProfileSettingsTile(icon: Icons.mail_outline_rounded, title: l10n.settingsSupport, trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey), onTap: () => openSupportEmail(context)),
          ]),
          const SizedBox(height: 30),

          // --- 4. DATA ---
          ProfileSectionTitle(title: l10n.settingsData),
          ProfileSettingsGroup(children: [
            ProfileSwitchTile(icon: Icons.fingerprint_rounded, title: l10n.settingsBiometrics, value: settings.biometricsEnabled, onChanged: (v) => handleBiometrics(context, v)),
            const Divider(height: 1, indent: 50, color: Colors.black12),

            ProfileSettingsTile(
              icon: Icons.picture_as_pdf_rounded,
              title: l10n.settingsExport,
              trailing: isPremium
                  ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)
                  : const Icon(Icons.lock_outline, size: 20, color: Colors.amber),
              onTap: () async {
                if (!isPremium) {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const PremiumPaywallSheet(),
                  );
                  return;
                }

                // Проверка данных перед экспортом
                final allLogs = wellness.getLogHistory();
                final validLogs = allLogs.where((l) {
                  return l.flow != FlowIntensity.none ||
                      l.painSymptoms.isNotEmpty ||
                      l.symptoms.isNotEmpty ||
                      (l.notes != null && l.notes!.trim().isNotEmpty) ||
                      (l.temperature != null && l.temperature! > 0) ||
                      l.ovulationTest != OvulationTestResult.none;
                }).toList();

                if (validLogs.length < 7) {
                  if (context.mounted) {
                    showCupertinoDialog(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: Text(l10n.dialogDataInsufficientTitle),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(l10n.dialogDataInsufficientBody),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: Text(l10n.btnOk),
                            onPressed: () => Navigator.pop(ctx),
                          )
                        ],
                      ),
                    );
                  }
                  return;
                }

                // Старт экспорта
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  // Вызов статического метода
                  await PdfService.generateReport(context);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.msgExportError)));
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: 30),

          // --- 5. BACKUP ---
          ProfileSectionTitle(title: l10n.sectionBackup),
          ProfileSettingsGroup(children: [
            // 🔥 Save Backup
            Builder(builder: (ctx) => ProfileSettingsTile(
                icon: Icons.cloud_upload_rounded,
                title: l10n.btnSaveBackup,
                trailing: const Icon(Icons.save_alt, size: 20, color: AppColors.primary),
                onTap: () async {
                  await _ensureBoxes();
                  if (ctx.mounted) await BackupService.createBackup(ctx);
                }
            )),

            const Divider(height: 1, indent: 50, color: Colors.black12),

            // 🔥 Restore Backup
            ProfileSettingsTile(
              icon: Icons.cloud_download_rounded,
              title: l10n.btnRestoreBackup,
              trailing: const Icon(Icons.restore_page, size: 20, color: AppColors.primary),
              onTap: () => showCupertinoDialog(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: Text(l10n.dialogRestoreTitle), content: Text(l10n.dialogRestoreBody),
                  actions: [
                    CupertinoDialogAction(child: Text(l10n.btnCancel), onPressed: () => Navigator.pop(ctx)),
                    CupertinoDialogAction(isDestructiveAction: true, child: Text(l10n.btnRestore), onPressed: () async {
                      Navigator.pop(ctx);

                      await _ensureBoxes();
                      // Вызов статического метода
                      await BackupService.restoreBackup(context);

                      // Обновляем провайдеры
                      cycle.reload();
                      settings.reload();
                    }),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 40),

          Center(child: TextButton(onPressed: () => showDeleteDialog(context), child: Text(l10n.settingsReset, style: TextStyle(color: Colors.red.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildAvatar(bool isTTC) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isTTC ? Colors.amber.withOpacity(0.6) : AppColors.primary.withOpacity(0.3), width: isTTC ? 2 : 1),
          boxShadow: [BoxShadow(color: (isTTC ? Colors.amber : AppColors.primary).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
        ),
        child: const CircleAvatar(radius: 45, backgroundColor: Colors.white, child: Icon(Icons.person, size: 45, color: AppColors.primary)),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }
}