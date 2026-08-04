import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IsoReportDocument {
  final String title;
  final String docNo;
  final String revNo;
  final String revDate;
  final String preparedBy;
  final String approvedBy;
  final List<String> headers;
  final List<List<String>> dataRows;

  IsoReportDocument({
    required this.title,
    required this.docNo,
    required this.revNo,
    required this.revDate,
    required this.preparedBy,
    required this.approvedBy,
    required this.headers,
    required this.dataRows,
  });
}

class IsoReportExporter {
  static String _cleanText(String text) {
    return text
        .replaceAll('₹', 'Rs. ')
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('•', '*')
        .replaceAll('…', '...')
        .replaceAll('™', '(TM)')
        .replaceAll('®', '(R)')
        .replaceAll('©', '(C)');
  }

  /// Generate and prompt PDF layout / download for an ISO Report Document
  static Future<void> exportIsoPdf(IsoReportDocument doc) async {
    pw.Font? ttfRegular;
    pw.Font? ttfBold;
    try {
      ttfRegular = await PdfGoogleFonts.robotoRegular();
      ttfBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      // Offline fallback
    }

    final pdf = pw.Document(
      theme: (ttfRegular != null && ttfBold != null)
          ? pw.ThemeData.withFont(base: ttfRegular, bold: ttfBold)
          : null,
    );

    final cleanedHeaders = doc.headers.map((h) => _cleanText(h)).toList();
    final cleanedDataRows = doc.dataRows.map((row) => row.map((cell) => _cleanText(cell)).toList()).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            padding: const pw.EdgeInsets.all(8),
            margin: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'FLEXORA PACKAGING PRIVATE LIMITED',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                    ),
                    pw.Text('ISO 9001:2015 REGISTERED', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        _cleanText(doc.title).toUpperCase(),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('DOC NO: ${_cleanText(doc.docNo)}', style: const pw.TextStyle(fontSize: 8)),
                        pw.Text('REV NO: ${_cleanText(doc.revNo)} | DATE: ${_cleanText(doc.revDate)}', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            padding: const pw.EdgeInsets.all(6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('PREPARED BY: ${_cleanText(doc.preparedBy)}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('PAGE ${context.pageNumber} OF ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
                pw.Text('APPROVED BY: ${_cleanText(doc.approvedBy)}', style: const pw.TextStyle(fontSize: 8)),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.all(5),
              headers: cleanedHeaders,
              data: cleanedDataRows,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${doc.title.replaceAll(" ", "_")}_ISO_${doc.docNo.replaceAll("/", "_")}.pdf',
    );
  }

  /// Generate CSV String formatted for Excel ISO downloads
  static String generateIsoCsv(IsoReportDocument doc) {
    final buffer = StringBuffer();

    // Standard ISO Header block
    buffer.writeln('"FLEXORA PACKAGING PRIVATE LIMITED - ISO 9001:2015 DOCUMENTED RECORD"');
    buffer.writeln('"DOCUMENT TITLE:","${doc.title}"');
    buffer.writeln('"DOC NO:","${doc.docNo}"');
    buffer.writeln('"REV NO:","${doc.revNo}"');
    buffer.writeln('"REV DATE:","${doc.revDate}"');
    buffer.writeln('"PREPARED BY:","${doc.preparedBy}"');
    buffer.writeln('"APPROVED BY:","${doc.approvedBy}"');
    buffer.writeln('');

    // Headers
    buffer.writeln(doc.headers.map((h) => '"$h"').join(','));

    // Rows
    for (final row in doc.dataRows) {
      buffer.writeln(row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','));
    }

    return buffer.toString();
  }
}
