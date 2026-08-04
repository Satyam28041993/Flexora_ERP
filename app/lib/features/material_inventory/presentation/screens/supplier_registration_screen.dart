import 'package:flutter/material.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';

class SupplierRegistrationScreen extends StatefulWidget {
  const SupplierRegistrationScreen({super.key});

  @override
  State<SupplierRegistrationScreen> createState() => _SupplierRegistrationScreenState();
}

class _SupplierRegistrationScreenState extends State<SupplierRegistrationScreen> {
  final List<Map<String, String>> _suppliers = [
    {
      'code': 'SUP-001',
      'name': 'Avery Dennison India Pvt Ltd',
      'category': 'Self-Adhesive Paper & Film Stock',
      'contactPerson': 'Rajesh Sharma',
      'mobile': '+91 98765 43210',
      'email': 'rajesh.sharma@avery.com',
      'address': 'Plot No 42, Phase-II, GIDC, Thane, MH',
      'gstin': '27AAACA1234F1Z5',
      'pan': 'AAACA1234F',
      'isoCertified': 'Yes (ISO 9001:2015)',
      'rating': '95% (Grade A)',
      'status': 'Approved Supplier',
    },
    {
      'code': 'SUP-002',
      'name': 'Flint Group Inks India',
      'category': 'Flexo UV & Water-based Inks',
      'contactPerson': 'Amit Patel',
      'mobile': '+91 98220 11223',
      'email': 'amit.patel@flintgrp.com',
      'address': 'Sector 15, Industrial Area, Navi Mumbai, MH',
      'gstin': '27AABCF5678G2Z9',
      'pan': 'AABCF5678G',
      'isoCertified': 'Yes (ISO 9001:2015)',
      'rating': '92% (Grade A)',
      'status': 'Approved Supplier',
    },
    {
      'code': 'SUP-003',
      'name': 'Dupont Cyrel Polymer Plates',
      'category': 'Flexographic Photopolymer Plates',
      'contactPerson': 'Sanjay Mehta',
      'mobile': '+91 99300 88776',
      'email': 'sanjay.m@dupont.com',
      'address': 'GIDC Estate, Ankleshwar, Gujarat',
      'gstin': '27AAACD9988H1Z1',
      'pan': 'AAACD9988H',
      'isoCertified': 'Yes',
      'rating': '88% (Grade B)',
      'status': 'Approved Supplier',
    },
  ];

  final List<Map<String, String>> _evaluations = [
    {
      'srNo': '1',
      'supplierName': 'Avery Dennison India',
      'evalDate': '01/07/2025',
      'qualityScore': '98 / 100',
      'deliveryScore': '95 / 100',
      'priceScore': '90 / 100',
      'overallGrade': 'Grade A (Preferred)',
      'evaluator': 'Purchase Head',
    },
  ];

  void _exportApprovedSuppliersIso() {
    final doc = IsoReportDocument(
      title: 'LIST OF APPROVED SUPPLIERS',
      docNo: 'XYZ/PUR/F/02',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Purchase Manager',
      approvedBy: 'Managing Director',
      headers: ['Supplier Code', 'Supplier Name', 'Material Category', 'Contact Person & Mobile', 'Email & Address', 'GSTIN', 'ISO Status', 'Status'],
      dataRows: _suppliers.map((s) => [
        s['code']!,
        s['name']!,
        s['category']!,
        '${s['contactPerson']} (${s['mobile']})',
        '${s['email']}\n${s['address']}',
        s['gstin']!,
        s['isoCertified']!,
        s['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportSupplierEvaluationIso() {
    final doc = IsoReportDocument(
      title: 'SUPPLIER PERFORMANCE EVALUATION REPORT',
      docNo: 'XYZ/PUR/F/03',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Purchase Head',
      approvedBy: 'Managing Director',
      headers: ['Sr.', 'Supplier Name', 'Evaluation Date', 'Quality Score', 'Delivery Score', 'Price Score', 'Overall Grade', 'Evaluator'],
      dataRows: _evaluations.map((e) => [
        e['srNo']!,
        e['supplierName']!,
        e['evalDate']!,
        e['qualityScore']!,
        e['deliveryScore']!,
        e['priceScore']!,
        e['overallGrade']!,
        e['evaluator']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _showAddSupplierDialog() {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final contactNameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final panCtrl = TextEditingController();
    String isoStatus = 'Yes (ISO 9001:2015)';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📋 Detailed Supplier Registration Form (XYZ/PUR/F/01)'),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Supplier Company Name *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Material Category (Paper/Ink/Die/Film)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: contactNameCtrl, decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile / Phone No. *', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Registered Office Address & City/State *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: gstinCtrl, decoration: const InputDecoration(labelText: 'GSTIN No. *', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: panCtrl, decoration: const InputDecoration(labelText: 'PAN Card No.', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: isoStatus,
                  decoration: const InputDecoration(labelText: 'ISO 9001 Certification Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Yes (ISO 9001:2015)', child: Text('Yes (ISO 9001:2015 Accredited)')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress / Under Audit')),
                    DropdownMenuItem(value: 'No', child: Text('No')),
                  ],
                  onChanged: (v) => isoStatus = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _suppliers.add({
                    'code': 'SUP-00${_suppliers.length + 1}',
                    'name': nameCtrl.text,
                    'category': catCtrl.text.isEmpty ? 'General Material' : catCtrl.text,
                    'contactPerson': contactNameCtrl.text.isEmpty ? 'N/A' : contactNameCtrl.text,
                    'mobile': mobileCtrl.text.isEmpty ? 'N/A' : mobileCtrl.text,
                    'email': emailCtrl.text.isEmpty ? 'N/A' : emailCtrl.text,
                    'address': addressCtrl.text.isEmpty ? 'N/A' : addressCtrl.text,
                    'gstin': gstinCtrl.text.isEmpty ? 'N/A' : gstinCtrl.text,
                    'pan': panCtrl.text.isEmpty ? 'N/A' : panCtrl.text,
                    'isoCertified': isoStatus,
                    'rating': '90% (Grade A)',
                    'status': 'Approved Supplier',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detailed Supplier Registration Saved Successfully!')));
              }
            },
            label: const Text('Register Supplier'),
          ),
        ],
      ),
    );
  }

  void _showAddEvaluationDialog() {
    final suppCtrl = TextEditingController();
    final qCtrl = TextEditingController(text: '95');
    final dCtrl = TextEditingController(text: '90');
    final pCtrl = TextEditingController(text: '92');
    String grade = 'Grade A (Preferred)';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📊 New Supplier Evaluation Entry (XYZ/PUR/F/03)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: suppCtrl, decoration: const InputDecoration(labelText: 'Supplier Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Quality Rating Score (out of 100)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Delivery Score (out of 100)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: pCtrl, decoration: const InputDecoration(labelText: 'Commercial / Price Score (out of 100)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: grade,
                decoration: const InputDecoration(labelText: 'Overall Grade Rating', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Grade A (Preferred)', child: Text('Grade A (Preferred)')),
                  DropdownMenuItem(value: 'Grade B (Satisfactory)', child: Text('Grade B (Satisfactory)')),
                  DropdownMenuItem(value: 'Grade C (Under Review)', child: Text('Grade C (Under Review)')),
                ],
                onChanged: (v) => grade = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.star),
            onPressed: () {
              if (suppCtrl.text.isNotEmpty) {
                setState(() {
                  _evaluations.add({
                    'srNo': '${_evaluations.length + 1}',
                    'supplierName': suppCtrl.text,
                    'evalDate': DateTime.now().toString().split(' ')[0],
                    'qualityScore': '${qCtrl.text} / 100',
                    'deliveryScore': '${dCtrl.text} / 100',
                    'priceScore': '${pCtrl.text} / 100',
                    'overallGrade': grade,
                    'evaluator': 'Purchase Head',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier Evaluation Log Saved!')));
              }
            },
            label: const Text('Save Evaluation'),
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
          title: const Text('🏭 Approved Supplier Master & Registration (XYZ/PUR/F/01-03)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.badge), text: 'Approved Suppliers (XYZ/PUR/F/01-02)'),
              Tab(icon: Icon(Icons.star_half), text: 'Supplier Evaluation (XYZ/PUR/F/03)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Approved Suppliers
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO 9001:2015 Approved Supplier Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddSupplierDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('New Supplier Registration Form'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportApprovedSuppliersIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Approved Suppliers (PDF)'),
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
                              DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Material Category', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Contact & Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Email & Registered Address', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('GSTIN & PAN', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('ISO Certified', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _suppliers.map((s) => DataRow(cells: [
                              DataCell(Text(s['code']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(s['category']!)),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(s['contactPerson']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(s['mobile']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(s['email']!, style: const TextStyle(fontSize: 11, color: Colors.blue)),
                                  Text(s['address']!, style: const TextStyle(fontSize: 11)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('GST: ${s['gstin']}'),
                                  if (s['pan'] != null) Text('PAN: ${s['pan']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              )),
                              DataCell(Text(s['isoCertified']!)),
                              DataCell(Text(s['status']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Evaluation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO 9001:2015 Supplier Evaluation Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddEvaluationDialog,
                            icon: const Icon(Icons.rate_review),
                            label: const Text('+ New Supplier Evaluation'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportSupplierEvaluationIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Evaluation Report (PDF)'),
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
                              DataColumn(label: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Eval Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Quality Score', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Delivery Score', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Price Score', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Overall Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Evaluator', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _evaluations.map((e) => DataRow(cells: [
                              DataCell(Text(e['srNo']!)),
                              DataCell(Text(e['supplierName']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(e['evalDate']!)),
                              DataCell(Text(e['qualityScore']!)),
                              DataCell(Text(e['deliveryScore']!)),
                              DataCell(Text(e['priceScore']!)),
                              DataCell(Chip(label: Text(e['overallGrade']!), backgroundColor: Colors.teal.shade100)),
                              DataCell(Text(e['evaluator']!)),
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
