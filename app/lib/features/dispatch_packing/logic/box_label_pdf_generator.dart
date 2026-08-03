import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Box QR/Barcode Label PDF Generator.
///
/// Generates industrial 4" x 6" shipping & packing box labels
/// with high-density barcodes/QR codes, weights, and roll breakdown.
class BoxLabelPdfGenerator {
  static Future<Uint8List> generateSingleBoxLabel({
    required String boxNumber,
    required int totalBoxesInShipment,
    required String jobCardNo,
    required String poNumber,
    required String customerName,
    required String productName,
    required int rollCount,
    required int labelsPerRoll,
    required double totalQuantityPcs,
    required double netWeightKg,
    required double grossWeightKg,
    required String windingDirection,
    required double coreSizeMm,
    required String packedBy,
    required DateTime packingDate,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd-MMM-yyyy');
    final formattedDate = dateFormat.format(packingDate);

    // QR Data Payload JSON
    final qrPayload = '''
{
  "box": "$boxNumber",
  "jobNo": "$jobCardNo",
  "po": "$poNumber",
  "customer": "$customerName",
  "product": "$productName",
  "rolls": $rollCount,
  "pcs": ${totalQuantityPcs.toInt()},
  "netW": $netWeightKg,
  "grossW": $grossWeightKg
}
'''.trim();

    // 4" x 6" Label Dimensions in PDF points (1 in = 72 pt) -> 288 x 432 pt
    final labelFormat = PdfPageFormat(288, 432, marginAll: 12);

    pdf.addPage(
      pw.Page(
        pageFormat: labelFormat,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  color: PdfColors.indigo900,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'FLEXORA PACKAGING',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'BOX $boxNumber / $totalBoxesInShipment',
                        style: pw.TextStyle(
                          color: PdfColors.amber300,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),

                // Customer & SKU Title
                pw.Text(
                  customerName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
                pw.Text(
                  productName,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  maxLines: 2,
                  overflow: pw.TextOverflow.clip,
                ),
                pw.Divider(thickness: 1, color: PdfColors.grey400),

                // Key Spec Grid
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _labelValue('JOB CARD NO:', jobCardNo),
                          _labelValue('PO REF:', poNumber.isNotEmpty ? poNumber : 'N/A'),
                          _labelValue('PACKED DATE:', formattedDate),
                          _labelValue('PACKED BY:', packedBy),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 75,
                      height: 75,
                      padding: const pw.EdgeInsets.all(2),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey600),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrPayload,
                        drawText: false,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 6),
                pw.Divider(thickness: 1, color: PdfColors.grey400),

                // Roll & Quantity Highlights
                pw.Container(
                  color: PdfColors.grey200,
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _statBox('ROLL COUNT', '$rollCount Rolls'),
                      _statBox('QTY / ROLL', '$labelsPerRoll Pcs'),
                      _statBox('TOTAL QTY', '${totalQuantityPcs.toInt()} Pcs'),
                    ],
                  ),
                ),

                pw.SizedBox(height: 6),

                // Weight & Technical Details
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _cellText('NET WEIGHT', isHeader: true),
                        _cellText('GROSS WEIGHT', isHeader: true),
                        _cellText('CORE SIZE', isHeader: true),
                        _cellText('WINDING DIR', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _cellText('${netWeightKg.toStringAsFixed(2)} kg'),
                        _cellText('${grossWeightKg.toStringAsFixed(2)} kg'),
                        _cellText('${coreSizeMm.toInt()} mm'),
                        _cellText(windingDirection),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // Linear Barcode for Job/Box
                pw.Center(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(
                        height: 35,
                        width: 220,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.code128(),
                          data: '$jobCardNo-BX$boxNumber',
                          drawText: false,
                        ),
                      ),
                      pw.Text(
                        '*$jobCardNo-BX$boxNumber*',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _labelValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _statBox(String title, String val) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.Text(val, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
      ],
    );
  }

  static pw.Widget _cellText(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey900 : PdfColors.black,
        ),
      ),
    );
  }
}
