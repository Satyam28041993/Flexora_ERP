import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/dispatch_challan_model.dart';

/// GST Delivery / Dispatch Challan PDF Document Generator.
///
/// Generates full GST/Logistics-compliant A4 Delivery Challan for Flexora ERP.
class DispatchChallanPdfGenerator {
  static Future<Uint8List> generateChallanPdf({
    required DispatchChallanModel challan,
    String companyName = 'FLEXORA PACKAGING PVT. LTD.',
    String companyAddress = 'Plot 42, Flexo Industrial Zone, Sector 58, Faridabad, Haryana - 121004',
    String companyGstin = '06AAAAF1234A1Z5',
    String companyPhone = '+91 98765 43210 / info@flexorapackaging.com',
    String transporterName = 'VRL Logistics / Direct Dispatch',
    String lrNumber = 'LR-884920',
    String eWayBillNo = '3410 9948 2011',
    String hsnCode = '48211010', // Standard Flexographic Printed Labels HSN
    double unitRate = 0.0,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd-MMM-yyyy');
    final formattedChallanDate = dateFormat.format(challan.dispatchDate);

    final totalValue = challan.dispatchedQtyPcs * unitRate;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        companyAddress,
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        'GSTIN: $companyGstin | Ph: $companyPhone',
                        style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo900,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'DELIVERY CHALLAN',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1.5, color: PdfColors.indigo900),
              pw.SizedBox(height: 6),

              // Meta Grid: Consignee Details & Dispatch Ref
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Consignee (Bill To / Ship To)
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CONSIGNEE / SHIP TO:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            challan.customerName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            challan.shippingAddress.isNotEmpty ? challan.shippingAddress : 'Default Registered Works',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),

                  // Dispatch & Transport Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _kvRow('CHALLAN NO:', challan.challanNo, isBold: true),
                          _kvRow('CHALLAN DATE:', formattedChallanDate),
                          _kvRow('PO NUMBER:', challan.poNumber.isNotEmpty ? challan.poNumber : 'N/A'),
                          _kvRow('JOB CARD NO:', challan.jobCardNo),
                          _kvRow('VEHICLE NO:', challan.vehicleNo.isNotEmpty ? challan.vehicleNo : 'N/A', isBold: true),
                          _kvRow('TRANSPORTER:', transporterName),
                          _kvRow('LR / DOCK NO:', lrNumber),
                          _kvRow('E-WAY BILL NO:', eWayBillNo),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Itemized Particulars Table
              pw.Text('PARTICULARS OF DISPATCHED GOODS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
              pw.SizedBox(height: 4),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(28),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(60),
                  3: const pw.FixedColumnWidth(65),
                  4: const pw.FixedColumnWidth(65),
                  5: const pw.FixedColumnWidth(60),
                  6: const pw.FixedColumnWidth(70),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                    children: [
                      _th('S.No'),
                      _th('Description of Goods / SKU Name'),
                      _th('HSN Code'),
                      _th('Order Qty'),
                      _th('Dispatched'),
                      _th('Balance Qty'),
                      _th('Est. Value (₹)'),
                    ],
                  ),
                  // Item Row
                  pw.TableRow(
                    children: [
                      _td('1', align: pw.TextAlign.center),
                      _td('Printed Self-Adhesive Labels (Job Ref: ${challan.jobCardNo})\nPO: ${challan.poNumber}'),
                      _td(hsnCode, align: pw.TextAlign.center),
                      _td('${challan.targetOrderQtyPcs.toInt()} Pcs', align: pw.TextAlign.right),
                      _td('${challan.dispatchedQtyPcs.toInt()} Pcs', align: pw.TextAlign.right, isBold: true),
                      _td('${challan.balanceQtyPcs.toInt()} Pcs', align: pw.TextAlign.right),
                      _td(unitRate > 0 ? '₹${totalValue.toStringAsFixed(2)}' : 'N/A (Job Work)', align: pw.TextAlign.right),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Total Summary Box
              pw.Container(
                color: PdfColors.grey100,
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL DISPATCH QUANTITY: ${challan.dispatchedQtyPcs.toInt()} PCS',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                    ),
                    pw.Text(
                      challan.isFullyDispatched ? 'STATUS: FULLY DISPATCHED' : 'STATUS: PARTIAL DISPATCH (BAL: ${challan.balanceQtyPcs.toInt()} PCS)',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: challan.isFullyDispatched ? PdfColors.green800 : PdfColors.orange900),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Declaration & Barcode
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Declaration / Terms & Conditions:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '1. Goods dispatched as per agreed customer specification and quality checks.\n'
                          '2. Received goods must be checked upon receipt. Shortages/damages must be reported within 24 hours.\n'
                          '3. This delivery challan is issued under GST Rules for transportation of goods.',
                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.SizedBox(
                    width: 140,
                    height: 45,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: challan.challanNo,
                      drawText: true,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signature Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text("Receiver's Signature & Stamp", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('For $companyName', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 30),
                      pw.Container(width: 160, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorised Signatory', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _kvRow(String key, String val, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(key, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(
              val,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _th(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: PdfColors.black),
      ),
    );
  }
}
