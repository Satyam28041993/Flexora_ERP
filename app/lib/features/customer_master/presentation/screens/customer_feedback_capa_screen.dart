import 'package:flutter/material.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';

class CustomerFeedbackCapaScreen extends StatefulWidget {
  const CustomerFeedbackCapaScreen({super.key});

  @override
  State<CustomerFeedbackCapaScreen> createState() => _CustomerFeedbackCapaScreenState();
}

class _CustomerFeedbackCapaScreenState extends State<CustomerFeedbackCapaScreen> {
  final List<Map<String, String>> _feedbacks = [
    {
      'srNo': '1',
      'customer': 'TEMPLE PACKAGING',
      'product': 'Pesticide Self-Adhesive Labels',
      'rating': '5 / 5 (Excellent)',
      'feedbackDate': '15/07/2025',
      'comments': 'Quality of print and die registration is highly satisfactory.',
      'status': 'Approved',
    },
    {
      'srNo': '2',
      'customer': 'RALLIS INDIA LTD',
      'product': 'Agro-Chemical Labels',
      'rating': '4 / 5 (Good)',
      'feedbackDate': '28/07/2025',
      'comments': 'Barcode readability pass rate 100%. Slight delay on dispatch slot.',
      'status': 'Under Review',
    },
  ];

  final List<Map<String, String>> _capaLogs = [
    {
      'srNo': '1',
      'docNo': 'XYZ/MR/F/17-001',
      'issue': 'Color shade variation on batch #2025-04',
      'rootCause': 'Ink viscosity fluctuation during extended night run.',
      'correctiveAction': 'Installed automatic ink viscosity controller on Lombardy press.',
      'preventiveAction': 'Hourly viscosity log mandatory in pre-flight checksheet.',
      'targetDate': '10/08/2025',
      'status': 'Completed',
    },
  ];

  void _exportFeedbackIso() {
    final doc = IsoReportDocument(
      title: 'CUSTOMER FEEDBACK ANALYSIS REPORT',
      docNo: 'XYZ/MKT/F/03',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Marketing Executive',
      approvedBy: 'Managing Director / MR',
      headers: ['Sr. No.', 'Customer Name', 'Product Supplied', 'Satisfaction Rating', 'Feedback Date', 'Comments & Action', 'Status'],
      dataRows: _feedbacks.map((f) => [
        f['srNo']!,
        f['customer']!,
        f['product']!,
        f['rating']!,
        f['feedbackDate']!,
        f['comments']!,
        f['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportCapaIso() {
    final doc = IsoReportDocument(
      title: 'CORRECTIVE AND PREVENTIVE ACTION (CAPA) REPORT',
      docNo: 'XYZ/MR/F/17',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Quality Assurance Head',
      approvedBy: 'Managing Director / MR',
      headers: ['Sr.', 'CAPA Doc No.', 'Non-Conformance Issue', 'Root Cause Analysis', 'Corrective Action', 'Preventive Action', 'Status'],
      dataRows: _capaLogs.map((c) => [
        c['srNo']!,
        c['docNo']!,
        c['issue']!,
        c['rootCause']!,
        c['correctiveAction']!,
        c['preventiveAction']!,
        c['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _showAddFeedbackDialog() {
    final custCtrl = TextEditingController();
    final prodCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    String rating = '5 / 5 (Excellent)';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📝 New Customer Feedback Entry (XYZ/MKT/F/02)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: custCtrl, decoration: const InputDecoration(labelText: 'Customer Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: prodCtrl, decoration: const InputDecoration(labelText: 'Product / Job Reference', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: rating,
                decoration: const InputDecoration(labelText: 'Satisfaction Rating', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '5 / 5 (Excellent)', child: Text('5 / 5 (Excellent)')),
                  DropdownMenuItem(value: '4 / 5 (Good)', child: Text('4 / 5 (Good)')),
                  DropdownMenuItem(value: '3 / 5 (Satisfactory)', child: Text('3 / 5 (Satisfactory)')),
                  DropdownMenuItem(value: '2 / 5 (Needs Improvement)', child: Text('2 / 5 (Needs Improvement)')),
                ],
                onChanged: (v) => rating = v!,
              ),
              const SizedBox(height: 12),
              TextField(controller: commentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Feedback Comments / Remarks', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            onPressed: () {
              if (custCtrl.text.isNotEmpty) {
                setState(() {
                  _feedbacks.add({
                    'srNo': '${_feedbacks.length + 1}',
                    'customer': custCtrl.text,
                    'product': prodCtrl.text.isEmpty ? 'Labels' : prodCtrl.text,
                    'rating': rating,
                    'feedbackDate': DateTime.now().toString().split(' ')[0],
                    'comments': commentCtrl.text.isEmpty ? 'N/A' : commentCtrl.text,
                    'status': 'Approved',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Feedback Entry Saved!')));
              }
            },
            label: const Text('Save Feedback Entry'),
          ),
        ],
      ),
    );
  }

  void _showAddCapaDialog() {
    final docNoCtrl = TextEditingController(text: 'XYZ/MR/F/17-00${_capaLogs.length + 1}');
    final issueCtrl = TextEditingController();
    final causeCtrl = TextEditingController();
    final correctiveCtrl = TextEditingController();
    final preventiveCtrl = TextEditingController();
    final targetDateCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0]);
    String status = 'In Progress';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🛠️ New CAPA Log Entry (XYZ/MR/F/17)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: docNoCtrl, decoration: const InputDecoration(labelText: 'CAPA Document No. *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: issueCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Non-Conformance Issue Description *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: causeCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Root Cause Analysis *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: correctiveCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Corrective Action Taken', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: preventiveCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Preventive Action Implemented', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: targetDateCtrl, decoration: const InputDecoration(labelText: 'Target Completion Date (YYYY-MM-DD)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'CAPA Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Pending Review', child: Text('Pending Review')),
                ],
                onChanged: (v) => status = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              if (issueCtrl.text.isNotEmpty) {
                setState(() {
                  _capaLogs.add({
                    'srNo': '${_capaLogs.length + 1}',
                    'docNo': docNoCtrl.text,
                    'issue': issueCtrl.text,
                    'rootCause': causeCtrl.text.isEmpty ? 'Under Analysis' : causeCtrl.text,
                    'correctiveAction': correctiveCtrl.text.isEmpty ? 'Pending' : correctiveCtrl.text,
                    'preventiveAction': preventiveCtrl.text.isEmpty ? 'Pending' : preventiveCtrl.text,
                    'targetDate': targetDateCtrl.text,
                    'status': status,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CAPA Log Entry Saved Successfully!')));
              }
            },
            label: const Text('Save CAPA Log'),
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
          title: const Text('⭐ Customer Feedback & ISO CAPA Register'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.rate_review), text: 'Customer Feedback (XYZ/MKT/F/02-03)'),
              Tab(icon: Icon(Icons.build_circle), text: 'CAPA Log (XYZ/MR/F/17)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Feedback
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO 9001:2015 Customer Feedback Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddFeedbackDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('New Feedback Entry'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportFeedbackIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Feedback ISO Report (PDF)'),
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
                              DataColumn(label: Text('Sr. No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Feedback Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _feedbacks.map((f) => DataRow(cells: [
                              DataCell(Text(f['srNo']!)),
                              DataCell(Text(f['customer']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(f['product']!)),
                              DataCell(Chip(label: Text(f['rating']!), backgroundColor: Colors.green.shade100)),
                              DataCell(Text(f['feedbackDate']!)),
                              DataCell(Text(f['comments']!)),
                              DataCell(Text(f['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: CAPA
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Corrective & Preventive Action (CAPA) Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade800, foregroundColor: Colors.white),
                            onPressed: _showAddCapaDialog,
                            icon: const Icon(Icons.add_task),
                            label: const Text('+ New CAPA Log Entry'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportCapaIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export CAPA ISO Report (PDF)'),
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
                              DataColumn(label: Text('Doc No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Issue Description', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Root Cause Analysis', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Corrective Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Preventive Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _capaLogs.map((c) => DataRow(cells: [
                              DataCell(Text(c['docNo']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(c['issue']!)),
                              DataCell(Text(c['rootCause']!)),
                              DataCell(Text(c['correctiveAction']!)),
                              DataCell(Text(c['preventiveAction']!)),
                              DataCell(Chip(
                                label: Text(c['status']!),
                                backgroundColor: c['status'] == 'Completed' ? Colors.green.shade100 : Colors.amber.shade100,
                              )),
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
