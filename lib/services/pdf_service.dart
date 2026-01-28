import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для debugPrint
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/cycle_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/cycle_provider.dart';
import '../providers/wellness_provider.dart';

class PdfService {

  /// 🔥 ТОЧКА ВХОДА (Вызывается из настроек)
  static Future<void> generateReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // Используем listen: false, так как мы только читаем данные один раз
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final wellnessProvider = Provider.of<WellnessProvider>(context, listen: false);

    // 1. Собираем данные (за последние 90 дней)
    final List<SymptomLog> logs = [];
    final now = DateTime.now();

    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final log = wellnessProvider.getLogForDate(date);

      // Фильтруем пустые дни
      bool hasData = log.flow != FlowIntensity.none ||
          log.painSymptoms.isNotEmpty ||
          (log.temperature != null && log.temperature! > 0) ||
          (log.notes != null && log.notes!.trim().isNotEmpty) || // trim() для защиты от пробелов
          log.hadSex ||
          log.ovulationTest != OvulationTestResult.none;

      if (hasData) {
        logs.add(log);
      }
    }

    if (logs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No sufficient data to generate report"))
        );
      }
      return;
    }

    // 2. Вызываем генератор
    try {
      await PdfService().generateMedicalReport(
        logs: logs,
        avgCycleLength: cycleProvider.cycleLength,
        avgPeriodLength: cycleProvider.avgPeriodDuration,
        l10n: l10n,
      );
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error creating PDF: $e"))
        );
      }
    }
  }

  // --- ЛОГИКА ГЕНЕРАЦИИ PDF ---

  Future<void> generateMedicalReport({
    required List<SymptomLog> logs,
    required int avgCycleLength,
    required int avgPeriodLength,
    required AppLocalizations l10n,
    String userName = "Patient",
  }) async {
    final pdf = pw.Document();

    pw.Font fontRegular;
    pw.Font fontBold;

    // 🔥 ИСПРАВЛЕНИЕ: Защита от краша без интернета
    try {
      // Пытаемся загрузить красивые шрифты (требует интернет)
      fontRegular = await PdfGoogleFonts.openSansRegular();
      fontBold = await PdfGoogleFonts.openSansBold();
    } catch (e) {
      debugPrint("Offline mode: Using fallback fonts. Error: $e");
      // Если интернета нет, используем стандартные шрифты
      // (Внимание: Helvetica может не поддерживать кириллицу на некоторых устройствах,
      // лучше всего добавить .ttf в assets и грузить через rootBundle, если нужна гарантия)
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    // Сортируем: сначала новые
    logs.sort((a, b) => b.date.compareTo(a.date));

    final totalLogs = logs.length;
    final painDays = logs.where((l) => l.painSymptoms.isNotEmpty).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            // 1. ШАПКА
            _buildMedicalHeader(userName, fontBold, fontRegular, l10n),
            pw.SizedBox(height: 20),

            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.SizedBox(height: 10),

            // 2. СВОДКА
            pw.Text(l10n.pdfClinicalSummary.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, letterSpacing: 1.0)),
            pw.SizedBox(height: 10),
            _buildClinicalSummaryGrid(avgCycleLength, avgPeriodLength, painDays, totalLogs, fontRegular, fontBold, l10n),

            pw.SizedBox(height: 20),

            // 3. ТАБЛИЦА
            pw.Text(l10n.pdfDetailedLogs.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, letterSpacing: 1.0)),
            pw.SizedBox(height: 10),
            _buildStrictTable(logs, fontRegular, fontBold, l10n),

            pw.SizedBox(height: 20),

            // 4. ДИСКЛЕЙМЕР
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                l10n.pdfDisclaimer,
                style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'EviMoon_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
    );
  }

  // --- WIDGETS ---

  pw.Widget _buildMedicalHeader(String name, pw.Font bold, pw.Font regular, AppLocalizations l10n) {
    final now = DateTime.now();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.pdfReportTitle.toUpperCase(), style: pw.TextStyle(font: bold, fontSize: 18, color: PdfColors.black)),
            pw.SizedBox(height: 4),
            pw.Text(l10n.pdfReportSubtitle, style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("${l10n.pdfGenerated}: ${DateFormat('dd MMM yyyy').format(now)}", style: pw.TextStyle(font: regular, fontSize: 10)),
            pw.Text("${l10n.pdfPatient}: $name", style: pw.TextStyle(font: bold, fontSize: 10)),
          ],
        )
      ],
    );
  }

  pw.Widget _buildClinicalSummaryGrid(int cycleLen, int periodLen, int painDays, int totalDays, pw.Font regular, pw.Font bold, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
        color: PdfColors.grey50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _medicalMetric(l10n.pdfAvgCycle, "$cycleLen ${l10n.unitDays}", bold, regular),
          _medicalMetric(l10n.pdfAvgPeriod, "$periodLen ${l10n.unitDays}", bold, regular),
          _medicalMetric(
              l10n.pdfPainReported,
              totalDays > 0 ? "${((painDays/totalDays)*100).toStringAsFixed(1)}%" : "0%",
              bold,
              regular,
              isWarning: totalDays > 0 && painDays > totalDays * 0.3
          ),
        ],
      ),
    );
  }

  pw.Widget _medicalMetric(String label, String value, pw.Font bold, pw.Font regular, {bool isWarning = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text(
            value,
            style: pw.TextStyle(
                font: bold,
                fontSize: 14,
                color: isWarning ? PdfColors.red800 : PdfColors.black
            )
        ),
      ],
    );
  }

  pw.Widget _buildStrictTable(List<SymptomLog> logs, pw.Font regular, pw.Font bold, AppLocalizations l10n) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(60), // Date
        1: const pw.FixedColumnWidth(40), // CD
        2: const pw.FixedColumnWidth(80), // Symptoms
        3: const pw.FixedColumnWidth(40), // BBT
        4: const pw.FlexColumnWidth(),    // Notes
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _th(l10n.pdfTableDate.toUpperCase(), bold),
            _th(l10n.pdfTableCD.toUpperCase(), bold),
            _th(l10n.pdfTableSymptoms.toUpperCase(), bold),
            _th(l10n.pdfTableBBT.toUpperCase(), bold),
            _th(l10n.pdfTableNotes.toUpperCase(), bold),
          ],
        ),
        // Rows
        ...logs.map((log) {
          String cd = "--"; // TODO: Можно передать cycleStartDate и рассчитать

          List<String> symptoms = [];
          if (log.flow != FlowIntensity.none) {
            symptoms.add("${l10n.pdfFlowShort}: ${_flowShort(log.flow, l10n)}");
          }
          symptoms.addAll(log.painSymptoms);

          return pw.TableRow(
            children: [
              _td(DateFormat('dd.MM.yy').format(log.date), regular),
              _td(cd, regular, align: pw.TextAlign.center),
              _td(symptoms.join(", "), regular, fontSize: 8),
              _td(
                  (log.temperature != null && log.temperature! > 0) ? "${log.temperature}°" : "-",
                  regular,
                  align: pw.TextAlign.center
              ),
              _td(log.notes ?? "", regular, fontSize: 8),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _th(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _td(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left, double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: fontSize), textAlign: align),
    );
  }

  String _flowShort(FlowIntensity f, AppLocalizations l10n) {
    switch (f) {
      case FlowIntensity.light: return "L";
      case FlowIntensity.medium: return "M";
      case FlowIntensity.heavy: return "H";
      default: return "";
    }
  }
}