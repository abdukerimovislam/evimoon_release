import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/cycle_model.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart'; // Added for reload if needed
import '../l10n/app_localizations.dart'; // 🔥 Import Localization

class BackupService {

  /// 🔒 Helper to safely get a box (opens it if not already open)
  static Future<Box> _getBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box(name);
    } else {
      return await Hive.openBox(name);
    }
  }

  /// 📤 CREATE BACKUP
  static Future<void> createBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!; // Get localization

    try {
      // 1. Safely access boxes
      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');

      // 2. Collect Cycle Data
      final List<Map<String, dynamic>> cyclesJson = cycleBox.values.map((e) {
        final cycle = e as CycleModel;
        return {
          'startDate': cycle.startDate.millisecondsSinceEpoch,
          'endDate': cycle.endDate?.millisecondsSinceEpoch,
          'length': cycle.length,
          'ovulationOverrideDate': cycle.ovulationOverrideDate?.millisecondsSinceEpoch,
        };
      }).toList();

      // 3. Collect Settings
      final Map<String, dynamic> settingsJson = {
        'coc_enabled': settingsBox.get('coc_enabled'),
        'avg_cycle_len': settingsBox.get('avg_cycle_len'),
        'avg_period_len': settingsBox.get('avg_period_len'),
        'current_cycle_start': settingsBox.get('current_cycle_start'),
        'ttc_mode_enabled': settingsBox.get('ttc_mode_enabled'),
      };

      // 4. Form Complete Object
      final Map<String, dynamic> backupData = {
        'version': 1,
        'app': 'EviMoon',
        'timestamp': DateTime.now().toIso8601String(),
        'cycles': cyclesJson,
        'settings': settingsJson,
      };

      // 5. Convert to JSON String
      final String jsonString = jsonEncode(backupData);

      // 6. Create Temp File
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/EviMoon_Backup_$dateStr.json');

      await file.writeAsString(jsonString);

      // 7. iPad Fix for Share Origin
      final box = context.findRenderObject() as RenderBox?;
      Rect? shareOrigin;
      if (box != null) {
        shareOrigin = box.localToGlobal(Offset.zero) & box.size;
      }

      // 8. Open Share Dialog
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.backupSubject,
        text: l10n.backupBody(dateStr), // Передаем дату как параметр
        sharePositionOrigin: shareOrigin,
      );

    } catch (e) {
      debugPrint("Backup Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backup failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 📥 RESTORE FROM BACKUP
  static Future<void> restoreBackup(BuildContext context) async {
    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // 2. Parse JSON
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (!data.containsKey('cycles') || !data.containsKey('settings')) {
        throw Exception("Invalid backup file format");
      }

      // 3. Safely open boxes
      final cycleBox = await _getBox('cycles');
      final settingsBox = await _getBox('settings');

      // 4. Restore Data
      await cycleBox.clear(); // Clear old data

      final List<dynamic> cyclesList = data['cycles'];
      for (var c in cyclesList) {
        final cycleModel = CycleModel(
          startDate: DateTime.fromMillisecondsSinceEpoch(c['startDate']),
          endDate: c['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(c['endDate']) : null,
          length: c['length'],
          ovulationOverrideDate: c['ovulationOverrideDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(c['ovulationOverrideDate'])
              : null,
        );
        await cycleBox.add(cycleModel);
      }

      final Map<String, dynamic> settingsMap = data['settings'];

      void restoreKey(String key) {
        if (settingsMap.containsKey(key)) {
          settingsBox.put(key, settingsMap[key]);
        }
      }

      restoreKey('coc_enabled');
      restoreKey('avg_cycle_len');
      restoreKey('avg_period_len');
      restoreKey('current_cycle_start');
      restoreKey('ttc_mode_enabled');

      // 5. Update UI
      if (context.mounted) {
        // Reload providers to refresh UI immediately
        context.read<CycleProvider>().reload();
        context.read<SettingsProvider>().reload();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data restored successfully!"), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      debugPrint("Restore Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Restore failed: Corrupted file or wrong format"), backgroundColor: Colors.red),
        );
      }
    }
  }
}