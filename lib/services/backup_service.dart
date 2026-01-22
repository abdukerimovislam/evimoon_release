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

class BackupService {

  /// 📤 СОЗДАТЬ БЭКАП (Статический метод)
  static Future<void> createBackup(BuildContext context) async {
    try {
      // Получаем доступ к боксам напрямую по имени (они открыты в main.dart)
      final cycleBox = Hive.box('cycles');
      final settingsBox = Hive.box('settings');

      // 1. Собираем данные циклов
      final List<Map<String, dynamic>> cyclesJson = cycleBox.values.map((e) {
        final cycle = e as CycleModel;
        return {
          'startDate': cycle.startDate.millisecondsSinceEpoch,
          'endDate': cycle.endDate?.millisecondsSinceEpoch,
          'length': cycle.length,
          // 🔥 Важно: сохраняем ручную овуляцию
          'ovulationOverrideDate': cycle.ovulationOverrideDate?.millisecondsSinceEpoch,
        };
      }).toList();

      // 2. Собираем настройки
      final Map<String, dynamic> settingsJson = {
        'coc_enabled': settingsBox.get('coc_enabled'),
        'avg_cycle_len': settingsBox.get('avg_cycle_len'),
        'avg_period_len': settingsBox.get('avg_period_len'),
        'current_cycle_start': settingsBox.get('current_cycle_start'),
        'ttc_mode_enabled': settingsBox.get('ttc_mode_enabled'), // Сохраняем режим TTC
      };

      // 3. Формируем полный объект
      final Map<String, dynamic> backupData = {
        'version': 1,
        'app': 'EviMoon',
        'timestamp': DateTime.now().toIso8601String(),
        'cycles': cyclesJson,
        'settings': settingsJson,
      };

      // 4. Конвертируем в JSON
      final String jsonString = jsonEncode(backupData);

      // 5. Создаем временный файл
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/EviMoon_Backup_$dateStr.json');

      await file.writeAsString(jsonString);

      // 6. 🔥 FIX ДЛЯ IOS/IPAD
      final box = context.findRenderObject() as RenderBox?;
      Rect? shareOrigin;
      if (box != null) {
        shareOrigin = box.localToGlobal(Offset.zero) & box.size;
      }

      // 7. Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'EviMoon Backup',
        text: 'Backup data for EviMoon app created on $dateStr',
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

  /// 📥 ВОССТАНОВИТЬ ИЗ БЭКАПА (Статический метод)
  static Future<void> restoreBackup(BuildContext context) async {
    try {
      // 1. Выбор файла
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // 2. Парсинг
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (!data.containsKey('cycles') || !data.containsKey('settings')) {
        throw Exception("Invalid backup file format");
      }

      final cycleBox = Hive.box('cycles');
      final settingsBox = Hive.box('settings');

      // 3. Восстановление
      await cycleBox.clear(); // Очищаем старое

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
      // Безопасное восстановление ключей
      void restoreKey(String key) {
        if (settingsMap.containsKey(key)) settingsBox.put(key, settingsMap[key]);
      }

      restoreKey('coc_enabled');
      restoreKey('avg_cycle_len');
      restoreKey('avg_period_len');
      restoreKey('current_cycle_start');
      restoreKey('ttc_mode_enabled');

      // 4. Обновление UI
      if (context.mounted) {
        // Перезагружаем провайдер, чтобы UI обновился
        context.read<CycleProvider>().reload();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data restored successfully!"), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      debugPrint("Restore Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Restore failed: Corrupted file"), backgroundColor: Colors.red),
        );
      }
    }
  }
}