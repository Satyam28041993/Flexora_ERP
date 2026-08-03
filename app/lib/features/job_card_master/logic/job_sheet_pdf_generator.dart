import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/job_card_model.dart';

/// PDF Generator for PGPL Job Sheet matching "JOB CARD JULY 2026.xlsx" layout.
/// Generates a pixel-perfect A4 printable PDF document for physical printing and PDF download.
class JobSheetPdfGenerator {
  static Future<Uint8List> generatePdf(JobCardModel jobCard) async {
    final pdf = pw.Document();

    final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final cellStyle = const pw.TextStyle(fontSize: 9);

    pw.Widget buildPdfCell(
      String text, {
      bool isHeader = false,
      int flex = 1,
      PdfColor? bg,
      pw.TextAlign align = pw.TextAlign.left,
    }) {
      return pw.Expanded(
        flex: flex,
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: pw.BoxDecoration(
            color: bg ?? (isHeader ? PdfColors.grey200 : PdfColors.white),
            border: pw.Border.all(color: PdfColors.black, width: 0.5),
          ),
          child: pw.Text(
            text,
            style: isHeader ? headerStyle : cellStyle,
            textAlign: align,
          ),
        ),
      );
    }

    pw.Widget buildPdfRow(List<pw.Widget> children) {
      return pw.Row(children: children);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Company Title Header
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5), color: PdfColors.grey100),
                  child: pw.Text('PRAKRUTI GRAPHICS PVT LTD', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5), color: PdfColors.grey200),
                  child: pw.Text('JOB SHEET', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ),
                buildPdfRow([
                  buildPdfCell('Machine Line:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.machineName.toUpperCase(), flex: 8, bg: PdfColors.amber50),
                ]),

                // Grid Row 4: Job Sheet No, Date
                buildPdfRow([
                  buildPdfCell('Job Sheet No', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.jobCardNo, flex: 3, bg: PdfColors.amber100),
                  buildPdfCell('Date:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.dateStr.isNotEmpty ? jobCard.dateStr : '01-07-2026', flex: 3),
                ]),

                // Grid Row 5: PO No, PO Date
                buildPdfRow([
                  buildPdfCell('PO No:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.poNumber, flex: 3),
                  buildPdfCell('PO Date:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.poDateStr, flex: 3),
                ]),

                // Grid Row 6: JOB CODE, NO, u
                buildPdfRow([
                  buildPdfCell('JOB CODE', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.jobCode.isNotEmpty ? jobCard.jobCode : '208280', flex: 3, bg: PdfColors.grey100),
                  buildPdfCell('NO', isHeader: true, flex: 1),
                  buildPdfCell('', flex: 2),
                  buildPdfCell('u', isHeader: true, flex: 1),
                  buildPdfCell('', flex: 1),
                ]),

                // Grid Row 7: Customer Name
                buildPdfRow([
                  buildPdfCell('Customer Name', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.customerName, flex: 8),
                ]),

                // Grid Row 8: Job Name, CQAL No
                buildPdfRow([
                  buildPdfCell('Job Name', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.productName, flex: 5),
                  buildPdfCell('CQAL No', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.cqalNo, flex: 2),
                ]),

                // Grid Row 9: Label Size, LABLE/MTR
                buildPdfRow([
                  buildPdfCell('Label Size', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.labelSize, flex: 3),
                  buildPdfCell('LABLE/MTR', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.labelPerMtr.toString(), flex: 3),
                ]),

                // Grid Row 10: Stock Label Qty
                buildPdfRow([
                  buildPdfCell('Stock Label Qty', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.stockLabelQty > 0 ? jobCard.stockLabelQty.toInt().toString() : '', flex: 8),
                ]),

                // Grid Row 11: Artwork No, Direction, Gear Size
                buildPdfRow([
                  buildPdfCell('Art Work No:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.artWorkNo, flex: 2),
                  buildPdfCell('Direction:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.rollWindingDirection, flex: 1, bg: PdfColors.amber100),
                  buildPdfCell('Gear Size:', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.gearSize, flex: 2),
                ]),

                // Grid Row 12: Numbering, Punch Online, Punch
                buildPdfRow([
                  buildPdfCell('Numbering', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.numbering, flex: 2),
                  buildPdfCell('Punch Online', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.punchOnline, flex: 1),
                  buildPdfCell('Punch', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.punchType, flex: 2),
                ]),

                // Grid Row 13: Special Info, Plate Old/New
                buildPdfRow([
                  buildPdfCell('Special Info', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.specialInfo, flex: 3),
                  buildPdfCell('Plate Old/New', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.plateOldNew, flex: 3),
                ]),

                // Grid Row 14: Reslam/Delam, No of color, Material & Code
                buildPdfRow([
                  buildPdfCell('Reslam / Delam', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.reslamDelam, flex: 2),
                  buildPdfCell('No of color', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.noOfColors, flex: 2),
                  buildPdfCell('Material & Code', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.materialAndCode, flex: 1),
                ]),

                // Grid Row 15: As per shade Card, Special Color, Product
                buildPdfRow([
                  buildPdfCell('As per shade Card', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.asPerShadeCard, flex: 1),
                  buildPdfCell('Special Color:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.specialColors, flex: 3),
                  buildPdfCell('Product:', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.productMaterialType, flex: 1),
                ]),

                // Grid Row 16: UV Gloss/Lamination, Order Qty, Paper Size
                buildPdfRow([
                  buildPdfCell('UV Gloss/Lamination', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.uvGlossLamination, flex: 2),
                  buildPdfCell('Order Qty', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.targetOrderQty.toInt().toString(), flex: 2),
                  buildPdfCell('Paper Size', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.paperSize > 0 ? jobCard.paperSize.toString() : '', flex: 1),
                ]),

                // Grid Row 17: UV Mat, Screen Details, UPS
                buildPdfRow([
                  buildPdfCell('UV Mat', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.uvMat, flex: 2),
                  buildPdfCell('Screen Details :', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.screenDetails, flex: 2),
                  buildPdfCell('UPS', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.ups.toString(), flex: 1),
                ]),

                // Grid Row 18: Texture Varnish, Stamping Details, RMT
                buildPdfRow([
                  buildPdfCell('Texture Varnish', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.textureVarnish, flex: 2),
                  buildPdfCell('Stamping Details:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.stampingDetails, flex: 2),
                  buildPdfCell('RMT', isHeader: true, flex: 1),
                  buildPdfCell(jobCard.rmt > 0 ? jobCard.rmt.toInt().toString() : '', flex: 1, bg: PdfColors.amber100),
                ]),

                // Grid Row 19: Remarks
                buildPdfRow([
                  buildPdfCell('Remarks', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.remarks, flex: 8),
                ]),

                pw.SizedBox(height: 6),

                // Roll Winding Direction Header & Diagrams
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Roll Winding Direction', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: ['F1', 'F2', 'F3', 'F4', 'R1', 'R2', 'R3', 'R4'].map((dir) {
                      final isSelected = jobCard.rollWindingDirection.toUpperCase() == dir;
                      return pw.Container(
                        width: 50,
                        padding: const pw.EdgeInsets.all(3),
                        decoration: pw.BoxDecoration(
                          color: isSelected ? PdfColors.amber200 : PdfColors.grey50,
                          border: pw.Border.all(color: isSelected ? PdfColors.amber900 : PdfColors.black, width: isSelected ? 1.5 : 0.5),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                        child: pw.Column(
                          children: [
                            pw.Text(dir, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: isSelected ? PdfColors.amber900 : PdfColors.black)),
                            pw.SizedBox(height: 2),
                            pw.Text(dir.startsWith('F') ? 'O' : 'C', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 2),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.5), color: PdfColors.white),
                              child: pw.Text('PGPL', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                pw.SizedBox(height: 6),

                // Production Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Production Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                buildPdfRow([
                  buildPdfCell('Date', isHeader: true, flex: 2),
                  buildPdfCell('Operator', isHeader: true, flex: 2),
                  buildPdfCell('Print RMT', isHeader: true, flex: 2),
                  buildPdfCell('Print Qty', isHeader: true, flex: 2),
                  buildPdfCell('Wastage', isHeader: true, flex: 2),
                  buildPdfCell('Total Prod.Time Used', isHeader: true, flex: 3),
                ]),
                for (int i = 0; i < 2; i++)
                  buildPdfRow([
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 3),
                  ]),
                buildPdfRow([
                  buildPdfCell('Total RMT=', isHeader: true, flex: 4),
                  buildPdfCell('', flex: 9),
                ]),

                pw.SizedBox(height: 6),

                // Actual Production Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Actual Production Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                buildPdfRow([
                  buildPdfCell('Roll Id', isHeader: true, flex: 2),
                  buildPdfCell('From Store', isHeader: true, flex: 2),
                  buildPdfCell('Printing Rmt', isHeader: true, flex: 2),
                  buildPdfCell('Setting Rmt', isHeader: true, flex: 2),
                  buildPdfCell('Wastage Rmt', isHeader: true, flex: 2),
                  buildPdfCell('Leftover', isHeader: true, flex: 2),
                ]),
                for (int i = 0; i < 2; i++)
                  buildPdfRow([
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                    buildPdfCell('', flex: 2),
                  ]),
                buildPdfRow([
                  buildPdfCell('Total RMT=', isHeader: true, flex: 4),
                  buildPdfCell('', flex: 8),
                ]),

                pw.SizedBox(height: 6),

                // Post Production Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Post Production Details At Final Inspection & Dispatch Stage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                buildPdfRow([
                  buildPdfCell('Date', isHeader: true, flex: 2),
                  buildPdfCell('Inspected', isHeader: true, flex: 2),
                  buildPdfCell('Ok Quantity', isHeader: true, flex: 2),
                  buildPdfCell('Rejected Quantity', isHeader: true, flex: 2),
                  buildPdfCell('% Rejection', isHeader: true, flex: 2),
                  buildPdfCell('Sign Dh (PTG)', isHeader: true, flex: 2),
                ]),
                buildPdfRow([
                  buildPdfCell('', flex: 2),
                  buildPdfCell('', flex: 2),
                  buildPdfCell('', flex: 2),
                  buildPdfCell('', flex: 2),
                  buildPdfCell('', flex: 2),
                  buildPdfCell('', flex: 2),
                ]),

                pw.SizedBox(height: 6),

                // Raw Material Issue Sheet & Tooling
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Raw Material Issue Sheet', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                buildPdfRow([
                  buildPdfCell('Paper : Chroma/ MirrorCoat', isHeader: true, flex: 4),
                  buildPdfCell(jobCard.productMaterialType, flex: 3),
                  buildPdfCell('Paper Size:', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.paperSize > 0 ? jobCard.paperSize.toString() : '', flex: 2),
                ]),
                buildPdfRow([
                  buildPdfCell('Plate :', isHeader: true, flex: 3),
                  buildPdfCell(jobCard.plateCode, flex: 4),
                  buildPdfCell('No. Of Plate :', isHeader: true, flex: 3),
                  buildPdfCell('', flex: 4),
                ]),
                buildPdfRow([
                  buildPdfCell('Die :', isHeader: true, flex: 3),
                  buildPdfCell(jobCard.dieCode, flex: 3),
                  buildPdfCell('Online', isHeader: true, flex: 2),
                  buildPdfCell(jobCard.punchOnline, flex: 2),
                  buildPdfCell('Offline', isHeader: true, flex: 2),
                  buildPdfCell('', flex: 2),
                ]),

                pw.SizedBox(height: 6),

                // Despatch Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, border: pw.Border.all(color: PdfColors.black, width: 0.5)),
                  alignment: pw.Alignment.center,
                  child: pw.Text('Despatch Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                buildPdfRow([
                  buildPdfCell('DC/Invoice NO. PGPL/22-23/', isHeader: true, flex: 4),
                  buildPdfCell('Date:', isHeader: true, flex: 2),
                  buildPdfCell('Despatched Qty', isHeader: true, flex: 4),
                ]),
                buildPdfRow([
                  buildPdfCell('DC/Invoice NO. PGPL/22-23/', isHeader: true, flex: 4),
                  buildPdfCell('Date:', isHeader: true, flex: 2),
                  buildPdfCell('Bal Qty .', isHeader: true, flex: 4),
                ]),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Opens native PDF print & download viewer modal.
  static Future<void> printOrDownloadPdf(JobCardModel jobCard) async {
    final pdfBytes = await generatePdf(jobCard);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'JobSheet_${jobCard.jobCardNo.replaceAll('/', '_')}.pdf',
    );
  }
}
