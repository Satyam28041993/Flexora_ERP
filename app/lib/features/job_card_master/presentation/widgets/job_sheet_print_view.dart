import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/job_card_model.dart';
import '../../logic/job_sheet_pdf_generator.dart';
import 'roll_winding_diagram_widget.dart';

/// Pixel-perfect PGPL Excel-style Job Sheet View.
/// Renders the exact table layout, header, grid borders, winding direction diagrams,
/// and production/dispatch tables matching "JOB CARD JULY 2026.xlsx".
class JobSheetPrintView extends StatelessWidget {
  const JobSheetPrintView({super.key, required this.jobCard});

  final JobCardModel jobCard;

  static const TextStyle cellStyle = TextStyle(fontSize: 11, color: Colors.black);
  static const TextStyle headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black);

  Widget _buildCell(
    String text, {
    bool isHeader = false,
    int flex = 1,
    TextAlign align = TextAlign.left,
    Color? bg,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: bg ?? (isHeader ? Colors.grey.shade200 : Colors.white),
          border: Border.all(color: Colors.black, width: 0.5),
        ),
        child: Text(
          text,
          style: isHeader ? headerStyle : cellStyle,
          textAlign: align,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Print / Download PDF Action Bar
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => JobSheetPdfGenerator.printOrDownloadPdf(jobCard),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Print / Download PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Company Header
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
              child: const Text('PRAKRUTI GRAPHICS PVT LTD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
              child: const Text('JOB SHEET', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
              child: Text(jobCard.machineName.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),

            // Metadata grid
            _buildRow([
              _buildCell('Job Sheet No', isHeader: true, flex: 2),
              _buildCell(jobCard.jobCardNo, flex: 3, bg: Colors.amber.shade50),
              _buildCell('Date:', isHeader: true, flex: 2),
              _buildCell(jobCard.dateStr.isNotEmpty ? jobCard.dateStr : '01-07-2026', flex: 3),
            ]),
            _buildRow([
              _buildCell('PO No:', isHeader: true, flex: 2),
              _buildCell(jobCard.poNumber, flex: 3),
              _buildCell('PO Date:', isHeader: true, flex: 2),
              _buildCell(jobCard.poDateStr, flex: 3),
            ]),
            _buildRow([
              _buildCell('JOB CODE', isHeader: true, flex: 2),
              _buildCell(jobCard.jobCode.isNotEmpty ? jobCard.jobCode : '208280', flex: 3, bg: Colors.grey.shade100),
              _buildCell('NO', isHeader: true, flex: 1),
              _buildCell('', flex: 2),
              _buildCell('u', isHeader: true, flex: 1),
              _buildCell('', flex: 1),
            ]),
            _buildRow([
              _buildCell('Customer Name', isHeader: true, flex: 2),
              _buildCell(jobCard.customerName, flex: 8),
            ]),
            _buildRow([
              _buildCell('Job Name', isHeader: true, flex: 2),
              _buildCell(jobCard.productName, flex: 5),
              _buildCell('CQAL No', isHeader: true, flex: 1),
              _buildCell(jobCard.cqalNo, flex: 2),
            ]),
            _buildRow([
              _buildCell('Label Size', isHeader: true, flex: 2),
              _buildCell(jobCard.labelSize, flex: 3),
              _buildCell('LABLE/MTR', isHeader: true, flex: 2),
              _buildCell(jobCard.labelPerMtr.toString(), flex: 3),
            ]),
            _buildRow([
              _buildCell('Stock Label Qty', isHeader: true, flex: 2),
              _buildCell(jobCard.stockLabelQty > 0 ? jobCard.stockLabelQty.toInt().toString() : '', flex: 8),
            ]),
            _buildRow([
              _buildCell('Art Work No:', isHeader: true, flex: 2),
              _buildCell(jobCard.artWorkNo, flex: 2),
              _buildCell('Direction:', isHeader: true, flex: 2),
              _buildCell(jobCard.rollWindingDirection, flex: 1, bg: Colors.amber.shade100),
              _buildCell('Gear Size:', isHeader: true, flex: 1),
              _buildCell(jobCard.gearSize, flex: 2),
            ]),
            _buildRow([
              _buildCell('Numbering', isHeader: true, flex: 2),
              _buildCell(jobCard.numbering, flex: 2),
              _buildCell('Punch Online', isHeader: true, flex: 2),
              _buildCell(jobCard.punchOnline, flex: 1),
              _buildCell('Punch', isHeader: true, flex: 1),
              _buildCell(jobCard.punchType, flex: 2),
            ]),
            _buildRow([
              _buildCell('Special Info', isHeader: true, flex: 2),
              _buildCell(jobCard.specialInfo, flex: 3),
              _buildCell('Plate Old/New', isHeader: true, flex: 2),
              _buildCell(jobCard.plateOldNew, flex: 3),
            ]),
            _buildRow([
              _buildCell('Reslam / Delam', isHeader: true, flex: 2),
              _buildCell(jobCard.reslamDelam, flex: 2),
              _buildCell('No of color', isHeader: true, flex: 2),
              _buildCell(jobCard.noOfColors, flex: 2),
              _buildCell('Material & Code', isHeader: true, flex: 1),
              _buildCell(jobCard.materialAndCode, flex: 1),
            ]),
            _buildRow([
              _buildCell('As per shade Card', isHeader: true, flex: 2),
              _buildCell(jobCard.asPerShadeCard, flex: 1),
              _buildCell('Special Color:', isHeader: true, flex: 2),
              _buildCell(jobCard.specialColors, flex: 3),
              _buildCell('Product:', isHeader: true, flex: 1),
              _buildCell(jobCard.productMaterialType, flex: 1),
            ]),
            _buildRow([
              _buildCell('UV Gloss/Lamination', isHeader: true, flex: 2),
              _buildCell(jobCard.uvGlossLamination, flex: 2),
              _buildCell('Order Qty', isHeader: true, flex: 2),
              _buildCell(jobCard.targetOrderQty.toInt().toString(), flex: 2),
              _buildCell('Paper Size', isHeader: true, flex: 1),
              _buildCell(jobCard.paperSize.toString(), flex: 1),
            ]),
            _buildRow([
              _buildCell('UV Mat', isHeader: true, flex: 2),
              _buildCell(jobCard.uvMat, flex: 2),
              _buildCell('Screen Details :', isHeader: true, flex: 2),
              _buildCell(jobCard.screenDetails, flex: 2),
              _buildCell('UPS', isHeader: true, flex: 1),
              _buildCell(jobCard.ups.toString(), flex: 1),
            ]),
            _buildRow([
              _buildCell('Texture Varnish', isHeader: true, flex: 2),
              _buildCell(jobCard.textureVarnish, flex: 2),
              _buildCell('Stamping Details:', isHeader: true, flex: 2),
              _buildCell(jobCard.stampingDetails, flex: 2),
              _buildCell('RMT', isHeader: true, flex: 1),
              _buildCell(jobCard.rmt > 0 ? jobCard.rmt.toInt().toString() : '', flex: 1, bg: Colors.amber.shade50),
            ]),
            _buildRow([
              _buildCell('Remarks', isHeader: true, flex: 2),
              _buildCell(jobCard.remarks, flex: 8),
            ]),

            const SizedBox(height: 12),

            // Roll Winding Direction visualizer
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Roll Winding Direction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            RollWindingDiagramWidget(
              selectedDirection: jobCard.rollWindingDirection,
              onDirectionSelected: (_) {},
            ),

            const SizedBox(height: 12),

            // Production Details Table
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Production Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildRow([
              _buildCell('Date', isHeader: true, flex: 2),
              _buildCell('Operator', isHeader: true, flex: 2),
              _buildCell('Print RMT', isHeader: true, flex: 2),
              _buildCell('Print Qty', isHeader: true, flex: 2),
              _buildCell('Wastage', isHeader: true, flex: 2),
              _buildCell('Total Prod.Time Used', isHeader: true, flex: 3),
            ]),
            for (int i = 0; i < 3; i++)
              _buildRow([
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 3),
              ]),
            _buildRow([
              _buildCell('Total RMT=', isHeader: true, flex: 4),
              _buildCell('', flex: 9),
            ]),

            const SizedBox(height: 12),

            // Actual Production Details Table
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Actual Production Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildRow([
              _buildCell('Roll Id', isHeader: true, flex: 2),
              _buildCell('From Store', isHeader: true, flex: 2),
              _buildCell('Printing Rmt', isHeader: true, flex: 2),
              _buildCell('Setting Rmt', isHeader: true, flex: 2),
              _buildCell('Wastage Rmt', isHeader: true, flex: 2),
              _buildCell('Leftover', isHeader: true, flex: 2),
            ]),
            for (int i = 0; i < 3; i++)
              _buildRow([
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
              ]),
            _buildRow([
              _buildCell('Total RMT=', isHeader: true, flex: 4),
              _buildCell('', flex: 8),
            ]),

            const SizedBox(height: 12),

            // Post Production Details Table
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Post Production Details At Final Inspection & Dispatch Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildRow([
              _buildCell('Date', isHeader: true, flex: 2),
              _buildCell('Inspected', isHeader: true, flex: 2),
              _buildCell('Ok Quantity', isHeader: true, flex: 2),
              _buildCell('Rejected Quantity', isHeader: true, flex: 2),
              _buildCell('% Rejection', isHeader: true, flex: 2),
              _buildCell('Sign Dh (PTG)', isHeader: true, flex: 2),
            ]),
            for (int i = 0; i < 2; i++)
              _buildRow([
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
                _buildCell('', flex: 2),
              ]),

            const SizedBox(height: 12),

            // Raw Material Issue & Tooling
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Raw Material Issue Sheet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildRow([
              _buildCell('Paper : Chroma/ MirrorCoat', isHeader: true, flex: 4),
              _buildCell('Paper Size:', isHeader: true, flex: 3),
              _buildCell('R/M:', isHeader: true, flex: 3),
            ]),
            _buildRow([
              _buildCell('Plate :', isHeader: true, flex: 4),
              _buildCell('No. Of Plate :', isHeader: true, flex: 6),
            ]),
            _buildRow([
              _buildCell('Die :', isHeader: true, flex: 4),
              _buildCell('Online', isHeader: true, flex: 2),
              _buildCell('u', isHeader: true, flex: 2),
              _buildCell('Offline', isHeader: true, flex: 2),
            ]),

            const SizedBox(height: 12),

            // Dispatch Details
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade300, border: Border.all(color: Colors.black, width: 0.5)),
              alignment: Alignment.center,
              child: const Text('Despatch Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            _buildRow([
              _buildCell('DC/Invoice NO. PGPL/22-23/', isHeader: true, flex: 4),
              _buildCell('Date:', isHeader: true, flex: 2),
              _buildCell('Despatched Qty', isHeader: true, flex: 4),
            ]),
            _buildRow([
              _buildCell('DC/Invoice NO. PGPL/22-23/', isHeader: true, flex: 4),
              _buildCell('Date:', isHeader: true, flex: 2),
              _buildCell('', flex: 4),
            ]),
            _buildRow([
              _buildCell('DC/Invoice NO. PGPL/22-23/', isHeader: true, flex: 4),
            ]),
          ],
        ),
      ),
    ],
  ),
);
  }
}
