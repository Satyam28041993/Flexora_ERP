import 'package:flutter/material.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';

class QcCalibrationScreen extends StatefulWidget {
  const QcCalibrationScreen({super.key});

  @override
  State<QcCalibrationScreen> createState() => _QcCalibrationScreenState();
}

class _QcCalibrationScreenState extends State<QcCalibrationScreen> {
  final List<Map<String, String>> _instruments = [
    {
      'srNo': '1',
      'name': 'Digital Vernier Caliper (0-150mm)',
      'make': 'Mitutoyo Japan',
      'idNo': 'QC-CAL-01',
      'leastCount': '0.01 mm',
      'location': 'QC Lab Table 1',
      'lastCalDate': '10/01/2025',
      'dueDate': '09/01/2026',
      'agency': 'Precision Calibration Lab (NABL Accredited)',
      'status': 'Valid / Calibrated',
    },
    {
      'srNo': '2',
      'name': 'GSM Measuring Cutter & Balance',
      'make': 'Texcare',
      'idNo': 'QC-CAL-02',
      'leastCount': '0.01 GSM',
      'location': 'Paper Testing Bench',
      'lastCalDate': '15/02/2025',
      'dueDate': '14/02/2026',
      'agency': 'NABL Calib Tech',
      'status': 'Valid / Calibrated',
    },
    {
      'srNo': '3',
      'name': 'Barcode Scanner Verification Gauge',
      'make': 'Honeywell',
      'idNo': 'QC-CAL-03',
      'leastCount': 'Grade A-F',
      'location': 'Final Inspection Line',
      'lastCalDate': '01/03/2025',
      'dueDate': '28/02/2026',
      'agency': 'Honeywell India Service',
      'status': 'Valid / Calibrated',
    },
  ];

  final List<Map<String, String>> _finalInspections = [
    {
      'srNo': '1',
      'jobCardNo': 'JC-2025-882',
      'customer': 'TEMPLE PACKAGING',
      'item': 'Pharma Self-Adhesive Labels',
      'inspectedQty': '100,000 Pcs',
      'passedQty': '100,000 Pcs',
      'rejectedQty': '0 Pcs',
      'inspector': 'Pravin QC',
      'status': 'PASSED (Fit for Dispatch)',
    },
  ];

  void _exportInstrumentsIso() {
    final doc = IsoReportDocument(
      title: 'LIST OF MEASURING INSTRUMENTS / LAB EQUIPMENT',
      docNo: 'XYZ/QC/F/06',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Quality Inspector',
      approvedBy: 'QA Head',
      headers: ['Sr.', 'Instrument Name', 'Make', 'ID No.', 'Least Count', 'Last Calib Date', 'Next Due Date', 'Calibration Agency', 'Status'],
      dataRows: _instruments.map((i) => [
        i['srNo']!,
        i['name']!,
        i['make']!,
        i['idNo']!,
        i['leastCount']!,
        i['lastCalDate']!,
        i['dueDate']!,
        i['agency']!,
        i['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportFinalInspectionIso() {
    final doc = IsoReportDocument(
      title: 'FINAL INSPECTION & RELEASE REPORT',
      docNo: 'XYZ/QC/F/04',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Senior QC Inspector',
      approvedBy: 'QA Head',
      headers: ['Sr.', 'Job Card No.', 'Customer Name', 'Product Item', 'Inspected Qty', 'Passed Qty', 'Rejected Qty', 'Inspector', 'Release Status'],
      dataRows: _finalInspections.map((f) => [
        f['srNo']!,
        f['jobCardNo']!,
        f['customer']!,
        f['item']!,
        f['inspectedQty']!,
        f['passedQty']!,
        f['rejectedQty']!,
        f['inspector']!,
        f['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _showAddInstrumentDialog() {
    final nameCtrl = TextEditingController();
    final makeCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'QC-CAL-0${_instruments.length + 1}');
    final lcCtrl = TextEditingController(text: '0.01 mm');
    final locCtrl = TextEditingController(text: 'QC Lab');
    final agencyCtrl = TextEditingController(text: 'NABL Calib Lab');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔍 Register Measuring Instrument (XYZ/QC/F/06)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Instrument Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: makeCtrl, decoration: const InputDecoration(labelText: 'Make / Model', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Identification No. (e.g. QC-CAL-01) *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: lcCtrl, decoration: const InputDecoration(labelText: 'Least Count / Accuracy Range', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Lab Location', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: agencyCtrl, decoration: const InputDecoration(labelText: 'Calibration NABL Agency Name', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _instruments.add({
                    'srNo': '${_instruments.length + 1}',
                    'name': nameCtrl.text,
                    'make': makeCtrl.text.isEmpty ? 'Mitutoyo' : makeCtrl.text,
                    'idNo': idCtrl.text,
                    'leastCount': lcCtrl.text,
                    'location': locCtrl.text,
                    'lastCalDate': DateTime.now().toString().split(' ')[0],
                    'dueDate': '2026-08-01',
                    'agency': agencyCtrl.text,
                    'status': 'Valid / Calibrated',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Measuring Instrument Saved!')));
              }
            },
            label: const Text('Save Instrument'),
          ),
        ],
      ),
    );
  }

  void _showAddFinalInspectionDialog() {
    final jcCtrl = TextEditingController(text: 'JC-2025-0${_finalInspections.length + 1}');
    final custCtrl = TextEditingController();
    final itemCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '50,000 Pcs');
    final passCtrl = TextEditingController(text: '50,000 Pcs');
    final rejCtrl = TextEditingController(text: '0 Pcs');
    final inspectorCtrl = TextEditingController(text: 'Pravin QC');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ New Final Inspection Report (XYZ/QC/F/04)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: jcCtrl, decoration: const InputDecoration(labelText: 'Job Card No. *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: custCtrl, decoration: const InputDecoration(labelText: 'Customer Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Product / Item Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Inspected Quantity', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Passed Quantity', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: rejCtrl, decoration: const InputDecoration(labelText: 'Rejected Quantity', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: inspectorCtrl, decoration: const InputDecoration(labelText: 'QC Inspector Name', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, foregroundColor: Colors.white),
            icon: const Icon(Icons.verified),
            onPressed: () {
              if (custCtrl.text.isNotEmpty) {
                setState(() {
                  _finalInspections.add({
                    'srNo': '${_finalInspections.length + 1}',
                    'jobCardNo': jcCtrl.text,
                    'customer': custCtrl.text,
                    'item': itemCtrl.text.isEmpty ? 'Labels' : itemCtrl.text,
                    'inspectedQty': qtyCtrl.text,
                    'passedQty': passCtrl.text,
                    'rejectedQty': rejCtrl.text,
                    'inspector': inspectorCtrl.text,
                    'status': 'PASSED (Fit for Dispatch)',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Final Inspection Log Saved!')));
              }
            },
            label: const Text('Release & Save Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📏 QC Calibration & Final Inspection (XYZ/QC/F/01-06)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.straighten), text: 'Instruments Calibration (XYZ/QC/F/06)'),
              Tab(icon: Icon(Icons.fact_check), text: 'Final Inspection Release (XYZ/QC/F/04)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Calibration
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO 9001:2015 Measuring Equipment Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddInstrumentDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('+ New Instrument Entry'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportInstrumentsIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Calibration Register (PDF)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Sr.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Instrument Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Make', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('ID No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Least Count', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Last Calib Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Calibration Agency', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _instruments.map((i) => DataRow(cells: [
                              DataCell(Text(i['srNo']!)),
                              DataCell(Text(i['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(i['make']!)),
                              DataCell(Chip(label: Text(i['idNo']!), backgroundColor: Colors.purple.shade100)),
                              DataCell(Text(i['leastCount']!)),
                              DataCell(Text(i['lastCalDate']!)),
                              DataCell(Text(i['dueDate']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(i['agency']!)),
                              DataCell(Text(i['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Final Inspection
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO 9001:2015 Final Inspection & Release Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, foregroundColor: Colors.white),
                            onPressed: _showAddFinalInspectionDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('+ New Final Inspection Entry'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportFinalInspectionIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Final Inspection ISO (PDF)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Job Card', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Product Item', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Inspected Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Passed Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Inspector', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _finalInspections.map((f) => DataRow(cells: [
                              DataCell(Text(f['jobCardNo']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(f['customer']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(f['item']!)),
                              DataCell(Text(f['inspectedQty']!)),
                              DataCell(Text(f['passedQty']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              DataCell(Text(f['inspector']!)),
                              DataCell(Chip(label: Text(f['status']!), backgroundColor: Colors.green.shade100)),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
