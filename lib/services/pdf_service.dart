import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/cycle_model.dart';

class PdfService {
  Future<void> generateAndPrint(List<SymptomLog> logs, int cycleLength) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    // Сортируем логи по дате
    logs.sort((a, b) => b.date.compareTo(a.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSummary(logs.length, cycleLength),
            pw.SizedBox(height: 20),
            pw.Text("Symptom Log History", style: pw.TextStyle(fontSize: 18, font: font, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildTable(logs, font),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildHeader() {
    return pw.Header(
      level: 0,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("EviMoon Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
          pw.Text(DateFormat.yMMMMd().format(DateTime.now()), style: const pw.TextStyle(color: PdfColors.grey)),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(int logsCount, int cycleLength) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Avg Cycle", "$cycleLength days"),
          _summaryItem("Total Logs", "$logsCount"),
          _summaryItem("Status", "Regular"),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800)),
      ],
    );
  }

  pw.Widget _buildTable(List<SymptomLog> logs, pw.Font font) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Phase', 'Mood', 'Energy', 'Notes'],
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple400),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      data: logs.map((log) {
        return [
          DateFormat('MM/dd').format(log.date),
          _getFlowString(log.flow), // Или фазу, если вычислим
          "${log.mood}/5",
          "${log.energy}/5",
          log.notes ?? "-",
        ];
      }).toList(),
    );
  }

  String _getFlowString(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.none: return "";
      case FlowIntensity.light: return "Light";
      case FlowIntensity.medium: return "Medium";
      case FlowIntensity.heavy: return "Heavy";
    }
  }
}