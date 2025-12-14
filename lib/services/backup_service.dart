import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

// Импорты моделей
import '../models/cycle_model.dart';

class BackupService {
  final Box _cycleBox;
  final Box _settingsBox;
  // Если есть коробка для симптомов/велнеса, добавь её сюда
  // final Box _wellnessBox;

  BackupService(this._cycleBox, this._settingsBox);

  /// 📤 СОЗДАТЬ БЭКАП
  Future<void> createBackup(BuildContext context) async {
    try {
      // 1. Собираем данные циклов
      final List<Map<String, dynamic>> cyclesJson = _cycleBox.values.map((e) {
        final cycle = e as CycleModel;
        return {
          'startDate': cycle.startDate.millisecondsSinceEpoch,
          'endDate': cycle.endDate?.millisecondsSinceEpoch,
          // Добавь сюда другие поля CycleModel, если они есть
        };
      }).toList();

      // 2. Собираем настройки
      final Map<String, dynamic> settingsJson = {
        'coc_enabled': _settingsBox.get('coc_enabled'),
        'avg_cycle_len': _settingsBox.get('avg_cycle_len'),
        'avg_period_len': _settingsBox.get('avg_period_len'),
        'current_cycle_start': _settingsBox.get('current_cycle_start'),
        // Добавь другие важные настройки
      };

      // 3. Формируем полный объект
      final Map<String, dynamic> backupData = {
        'version': 1, // Версия структуры бэкапа (на будущее)
        'timestamp': DateTime.now().toIso8601String(),
        'cycles': cyclesJson,
        'settings': settingsJson,
      };

      // 4. Конвертируем в JSON строку
      final String jsonString = jsonEncode(backupData);

      // 5. Создаем временный файл
      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${directory.path}/EviMoon_Backup_$dateStr.json');

      await file.writeAsString(jsonString);

      // 6. Открываем диалог "Поделиться / Сохранить"
      // Пользователь сам выберет: iCloud, GDrive, Telegram и т.д.
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'EviMoon Backup',
        text: 'Backup data for EviMoon app created on $dateStr',
      );

      if (result.status == ShareResultStatus.success) {
        debugPrint("Backup exported successfully");
      }

    } catch (e) {
      debugPrint("Backup Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backup failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 📥 ВОССТАНОВИТЬ ИЗ БЭКАПА
  Future<bool> restoreBackup(BuildContext context) async {
    try {
      // 1. Открываем выбор файла
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return false; // Пользователь отменил

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // 2. Парсим JSON
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Простая валидация
      if (!data.containsKey('cycles') || !data.containsKey('settings')) {
        throw Exception("Invalid backup file format");
      }

      // 3. ВОССТАНАВЛИВАЕМ ДАННЫЕ

      // А. Очищаем текущие данные (Опасно, поэтому лучше спросить подтверждение в UI перед вызовом)
      await _cycleBox.clear();
      // Настройки можно не чистить полностью, а перезаписывать

      // Б. Восстанавливаем циклы
      final List<dynamic> cyclesList = data['cycles'];
      for (var c in cyclesList) {
        final cycleModel = CycleModel(
          startDate: DateTime.fromMillisecondsSinceEpoch(c['startDate']),
          endDate: c['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(c['endDate']) : null,
        );
        await _cycleBox.add(cycleModel);
      }

      // В. Восстанавливаем настройки
      final Map<String, dynamic> settingsMap = data['settings'];
      if (settingsMap.containsKey('coc_enabled')) await _settingsBox.put('coc_enabled', settingsMap['coc_enabled']);
      if (settingsMap.containsKey('avg_cycle_len')) await _settingsBox.put('avg_cycle_len', settingsMap['avg_cycle_len']);
      if (settingsMap.containsKey('avg_period_len')) await _settingsBox.put('avg_period_len', settingsMap['avg_period_len']);
      if (settingsMap.containsKey('current_cycle_start')) await _settingsBox.put('current_cycle_start', settingsMap['current_cycle_start']);

      return true;

    } catch (e) {
      debugPrint("Restore Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Restore failed: Corrupted file"), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }
}