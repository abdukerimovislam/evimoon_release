import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import 'auth_service.dart';
import 'backup_crypto.dart';

class BackupService {
  static Future<Box> _getBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box(name);
    return Hive.openBox(name);
  }

  static bool _isRu(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'ru';
  }

  static String _t(BuildContext context, String en, String ru) => _isRu(context) ? ru : en;

  static Future<void> _showSnack(
      BuildContext context, {
        required String message,
        required bool success,
      }) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  static Future<bool> _confirmSensitiveAction(
      BuildContext context, {
        required String titleEn,
        required String titleRu,
        required String bodyEn,
        required String bodyRu,
        required String confirmEn,
        required String confirmRu,
      }) async {
    if (!context.mounted) return false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_t(ctx, titleEn, titleRu)),
          content: Text(_t(ctx, bodyEn, bodyRu)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_t(ctx, 'Cancel', 'Отмена')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_t(ctx, confirmEn, confirmRu)),
            ),
          ],
        );
      },
    );

    return ok ?? false;
  }

  static Future<bool> _requireAuthIfEnabled(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.biometricsEnabled) return true;

    final auth = AuthService();
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck) return true;

    final l10n = AppLocalizations.of(context);
    final reason = l10n?.authReason ?? _t(context, 'Scan to continue', 'Подтвердите для продолжения');
    return auth.authenticate(reason);
  }

  static Future<String?> _askPassword(
      BuildContext context, {
        required bool confirm,
        required String titleEn,
        required String titleRu,
        required String hintEn,
        required String hintRu,
      }) async {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    bool obscure = true;
    String? error;

    Future<void> showError(StateSetter setState, String msg) async {
      setState(() => error = msg);
    }

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(_t(ctx, titleEn, titleRu)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller1,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: _t(ctx, hintEn, hintRu),
                      errorText: error,
                    ),
                  ),
                  if (confirm) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller2,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: _t(ctx, 'Confirm password', 'Повторите пароль'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: !obscure,
                        onChanged: (v) => setState(() => obscure = !(v ?? false)),
                      ),
                      Text(_t(ctx, 'Show password', 'Показать пароль')),
                    ],
                  ),
                  Text(
                    _t(
                      ctx,
                      'Important: if you forget this password, the backup cannot be recovered.',
                      'Важно: если забудете пароль, восстановить бэкап будет невозможно.',
                    ),
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(_t(ctx, 'Cancel', 'Отмена')),
                ),
                FilledButton(
                  onPressed: () async {
                    final p1 = controller1.text.trim();
                    if (p1.length < 6) {
                      await showError(setState, _t(ctx, 'Password too short (min 6)', 'Слишком короткий пароль (мин 6)'));
                      return;
                    }
                    if (confirm) {
                      final p2 = controller2.text.trim();
                      if (p1 != p2) {
                        await showError(setState, _t(ctx, 'Passwords do not match', 'Пароли не совпадают'));
                        return;
                      }
                    }
                    Navigator.of(ctx).pop(p1);
                  },
                  child: Text(_t(ctx, 'Continue', 'Продолжить')),
                ),
              ],
            );
          },
        );
      },
    );

    controller1.dispose();
    controller2.dispose();
    return result;
  }

  /// 📤 CREATE BACKUP (Encrypted v2 by default)
  static Future<void> createBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await _confirmSensitiveAction(
      context,
      titleEn: 'Export backup',
      titleRu: 'Экспорт бэкапа',
      bodyEn:
      'The backup file contains private health data. '
          'We will encrypt it with a password.',
      bodyRu:
      'Файл бэкапа содержит приватные данные. '
          'Мы зашифруем его паролем.',
      confirmEn: 'Continue',
      confirmRu: 'Продолжить',
    );
    if (!confirmed) return;

    final authed = await _requireAuthIfEnabled(context);
    if (!authed) {
      await _showSnack(
        context,
        message: _t(context, 'Authentication failed', 'Не удалось подтвердить доступ'),
        success: false,
      );
      return;
    }

    final password = await _askPassword(
      context,
      confirm: true,
      titleEn: 'Set backup password',
      titleRu: 'Пароль для бэкапа',
      hintEn: 'Password',
      hintRu: 'Пароль',
    );
    if (password == null) return;

    try {
      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');

      final List<Map<String, dynamic>> cyclesJson = cycleBox.values.map((e) {
        final cycle = e as CycleModel;
        return {
          'startDate': cycle.startDate.millisecondsSinceEpoch,
          'endDate': cycle.endDate?.millisecondsSinceEpoch,
          'length': cycle.length,
          'ovulationOverrideDate': cycle.ovulationOverrideDate?.millisecondsSinceEpoch,
        };
      }).toList();

      final Map<String, dynamic> settingsJson = {
        'coc_enabled': settingsBox.get('coc_enabled'),
        'avg_cycle_len': settingsBox.get('avg_cycle_len'),
        'avg_period_len': settingsBox.get('avg_period_len'),
        'current_cycle_start': settingsBox.get('current_cycle_start'),
        'ttc_mode_enabled': settingsBox.get('ttc_mode_enabled'),
      };

      final Map<String, dynamic> backupData = {
        'version': 1, // inner schema version (your app data schema)
        'app': 'EviMoon',
        'timestamp': DateTime.now().toIso8601String(),
        'cycles': cyclesJson,
        'settings': settingsJson,
      };

      final innerJson = jsonEncode(backupData);

      // ✅ Encrypt into envelope (v2)
      final envelope = await BackupCrypto.encryptEnvelopeAsync(
        plaintext: innerJson,
        password: password,
      );
      final envelopeJson = jsonEncode(envelope);

      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/EviMoon_Backup_$dateStr.enc.json');
      await file.writeAsString(envelopeJson);

      final box = context.findRenderObject() as RenderBox?;
      Rect? shareOrigin;
      if (box != null) {
        shareOrigin = box.localToGlobal(Offset.zero) & box.size;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n?.backupSubject ?? _t(context, 'EviMoon Backup', 'Бэкап EviMoon'),
        text: _t(
          context,
          'Encrypted backup created on $dateStr',
          'Зашифрованный бэкап создан: $dateStr',
        ),
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugPrint("Backup Error: $e");
      await _showSnack(
        context,
        message: _t(context, 'Backup failed: $e', 'Ошибка бэкапа: $e'),
        success: false,
      );
    }
  }

  /// 📥 RESTORE FROM BACKUP
  /// Supports:
  /// - Encrypted v2 envelope (AES-GCM)
  /// - Legacy plain JSON (v1) for backward compatibility
  static Future<void> restoreBackup(BuildContext context) async {
    final confirmed = await _confirmSensitiveAction(
      context,
      titleEn: 'Restore backup',
      titleRu: 'Восстановить бэкап',
      bodyEn:
      'This will replace your current data with the data from the backup file.',
      bodyRu:
      'Текущие данные будут заменены данными из файла бэкапа.',
      confirmEn: 'Restore',
      confirmRu: 'Восстановить',
    );
    if (!confirmed) return;

    final authed = await _requireAuthIfEnabled(context);
    if (!authed) {
      await _showSnack(
        context,
        message: _t(context, 'Authentication failed', 'Не удалось подтвердить доступ'),
        success: false,
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) return;

      final path = result.files.single.path;
      if (path == null || path.isEmpty) {
        throw Exception(_t(context, 'File path is empty', 'Путь к файлу пуст'));
      }

      final file = File(path);
      final raw = await file.readAsString();

      // Parse top-level JSON
      final dynamic top = jsonDecode(raw);

      Map<String, dynamic> appData;

      // Detect encrypted envelope v2
      final isEnvelopeV2 = top is Map &&
          top['version'] == BackupCrypto.version &&
          top['alg'] == 'AES-GCM-256' &&
          top['ciphertext'] != null &&
          top['mac'] != null;

      if (isEnvelopeV2) {
        final password = await _askPassword(
          context,
          confirm: false,
          titleEn: 'Enter backup password',
          titleRu: 'Введите пароль бэкапа',
          hintEn: 'Password',
          hintRu: 'Пароль',
        );
        if (password == null) return;

        try {
          final plaintext = await BackupCrypto.decryptEnvelopeAsyncToPlaintext(
            envelope: Map<String, dynamic>.from(top as Map),
            password: password,
          );
          final decoded = jsonDecode(plaintext);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Inner JSON is not a map');
          }
          appData = decoded;
        } catch (e) {
          await _showSnack(
            context,
            message: _t(
              context,
              'Wrong password or corrupted backup',
              'Неверный пароль или файл бэкапа повреждён',
            ),
            success: false,
          );
          return;
        }
      } else {
        // Legacy plain JSON
        if (top is! Map<String, dynamic>) {
          throw Exception(_t(context, 'Invalid backup format', 'Неверный формат бэкапа'));
        }
        appData = top;
      }

      // Validate app payload
      if (appData['app'] != 'EviMoon' || !appData.containsKey('cycles') || !appData.containsKey('settings')) {
        throw Exception(_t(context, 'Invalid backup file format', 'Неверный формат файла бэкапа'));
      }

      // Restore
      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');

      await cycleBox.clear();

      final List<dynamic> cyclesList = (appData['cycles'] as List<dynamic>);
      for (final c in cyclesList) {
        if (c is! Map) continue;
        final startMs = c['startDate'];
        if (startMs == null) continue;

        final cycleModel = CycleModel(
          startDate: DateTime.fromMillisecondsSinceEpoch(startMs),
          endDate: c['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(c['endDate']) : null,
          length: c['length'],
          ovulationOverrideDate: c['ovulationOverrideDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(c['ovulationOverrideDate'])
              : null,
        );

        await cycleBox.add(cycleModel);
      }

      final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(appData['settings']);

      Future<void> restoreKey(String key) async {
        if (settingsMap.containsKey(key)) {
          await settingsBox.put(key, settingsMap[key]);
        }
      }

      await restoreKey('coc_enabled');
      await restoreKey('avg_cycle_len');
      await restoreKey('avg_period_len');
      await restoreKey('current_cycle_start');
      await restoreKey('ttc_mode_enabled');

      if (context.mounted) {
        context.read<CycleProvider>().reload();
        context.read<SettingsProvider>().reload();

        await _showSnack(
          context,
          message: _t(context, 'Data restored successfully!', 'Данные успешно восстановлены!'),
          success: true,
        );
      }
    } catch (e) {
      debugPrint("Restore Error: $e");
      await _showSnack(
        context,
        message: _t(
          context,
          'Restore failed: corrupted file or wrong format',
          'Ошибка восстановления: файл повреждён или неверный формат',
        ),
        success: false,
      );
    }
  }
}
