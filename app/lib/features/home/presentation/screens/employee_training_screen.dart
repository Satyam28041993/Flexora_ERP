import 'package:flutter/material.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';

class EmployeeTrainingScreen extends StatefulWidget {
  const EmployeeTrainingScreen({super.key});

  @override
  State<EmployeeTrainingScreen> createState() => _EmployeeTrainingScreenState();
}

class _EmployeeTrainingScreenState extends State<EmployeeTrainingScreen> {
  final List<Map<String, String>> _employees = [
    {
      'empId': 'EMP-01',
      'name': 'Ramesh Kumar',
      'department': 'Production (Printing)',
      'designation': 'Senior Press Operator',
      'competencySkill': 'Lombardy 8-Color UV Printing & Registration',
      'trainingNeeded': 'Advanced UV Curing & Ink Viscosity Control',
      'status': 'Qualified',
    },
    {
      'empId': 'EMP-02',
      'name': 'Pravin Jadhav',
      'department': 'Quality Control',
      'designation': 'QC Inspector',
      'competencySkill': 'Barcode Verification & Shade Card Matching',
      'trainingNeeded': 'ISO 9001:2015 Internal Auditor Training',
      'status': 'Qualified',
    },
    {
      'empId': 'EMP-03',
      'name': 'Sunil Varma',
      'department': 'Maintenance',
      'designation': 'Electrician / Maintenance Tech',
      'competencySkill': 'Electrical Controls & Breakdown Servicing',
      'trainingNeeded': 'Safety & Emergency Display Protocols',
      'status': 'Training Scheduled',
    },
  ];

  final List<Map<String, String>> _trainings = [
    {
      'srNo': '1',
      'topic': 'Flexo Ink Viscosity & Color Matching Accuracy',
      'plannedDate': '15/08/2025',
      'faculty': 'Flint Group Technical Trainer',
      'attendees': '5 Operators & 2 QC Inspectors',
      'status': 'Completed',
    },
    {
      'srNo': '2',
      'topic': 'ISO 9001:2015 Internal Audit Standard & Quality Manual',
      'plannedDate': '25/08/2025',
      'faculty': 'Management Representative (MR)',
      'attendees': 'All Department Heads',
      'status': 'Scheduled',
    },
  ];

  void _exportEmployeeMatrixIso() {
    final doc = IsoReportDocument(
      title: 'LIST OF EMPLOYEES & COMPETENCY MATRIX',
      docNo: 'XYZ/TRG/F/01',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'HR / Training Manager',
      approvedBy: 'Managing Director',
      headers: ['Emp ID', 'Employee Name', 'Department', 'Designation', 'Key Competency Skill', 'Training Requirement', 'Status'],
      dataRows: _employees.map((e) => [
        e['empId']!,
        e['name']!,
        e['department']!,
        e['designation']!,
        e['competencySkill']!,
        e['trainingNeeded']!,
        e['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportTrainingPlanIso() {
    final doc = IsoReportDocument(
      title: 'ANNUAL TRAINING PLAN & CALENDAR',
      docNo: 'XYZ/TRG/F/02',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Training Coordinator',
      approvedBy: 'Managing Director',
      headers: ['Sr.', 'Training Topic / Module', 'Planned Date', 'Trainer / Faculty', 'Target Attendees', 'Status'],
      dataRows: _trainings.map((t) => [
        t['srNo']!,
        t['topic']!,
        t['plannedDate']!,
        t['faculty']!,
        t['attendees']!,
        t['status']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _showAddEmployeeDialog() {
    final idCtrl = TextEditingController(text: 'EMP-0${_employees.length + 1}');
    final nameCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final desigCtrl = TextEditingController();
    final skillCtrl = TextEditingController();
    final trgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎓 New Employee Competency Record (XYZ/TRG/F/01)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Employee ID *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Employee Full Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: desigCtrl, decoration: const InputDecoration(labelText: 'Designation', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: skillCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Key Competency / Skill Matrix *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: trgCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Identified Training Need', border: OutlineInputBorder())),
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
                  _employees.add({
                    'empId': idCtrl.text,
                    'name': nameCtrl.text,
                    'department': deptCtrl.text.isEmpty ? 'Operations' : deptCtrl.text,
                    'designation': desigCtrl.text.isEmpty ? 'Operator' : desigCtrl.text,
                    'competencySkill': skillCtrl.text.isEmpty ? 'General Equipment Operating' : skillCtrl.text,
                    'trainingNeeded': trgCtrl.text.isEmpty ? 'Safety Training' : trgCtrl.text,
                    'status': 'Qualified',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee Competency Saved!')));
              }
            },
            label: const Text('Save Employee Record'),
          ),
        ],
      ),
    );
  }

  void _showAddTrainingDialog() {
    final topicCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0]);
    final facultyCtrl = TextEditingController();
    final attendeesCtrl = TextEditingController();
    String status = 'Scheduled';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📅 New Training Session Schedule (XYZ/TRG/F/02)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: topicCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Training Topic / Module Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Planned Date (YYYY-MM-DD)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: facultyCtrl, decoration: const InputDecoration(labelText: 'Faculty / Trainer Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: attendeesCtrl, decoration: const InputDecoration(labelText: 'Target Attendees Group', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Session Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Postponed', child: Text('Postponed')),
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
            icon: const Icon(Icons.event),
            onPressed: () {
              if (topicCtrl.text.isNotEmpty) {
                setState(() {
                  _trainings.add({
                    'srNo': '${_trainings.length + 1}',
                    'topic': topicCtrl.text,
                    'plannedDate': dateCtrl.text,
                    'faculty': facultyCtrl.text.isEmpty ? 'Internal Expert' : facultyCtrl.text,
                    'attendees': attendeesCtrl.text.isEmpty ? 'All Staff' : attendeesCtrl.text,
                    'status': status,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Training Schedule Saved!')));
              }
            },
            label: const Text('Save Training Session'),
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
          title: const Text('🎓 HR Training & Competency Matrix (XYZ/TRG/F/01-04)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.badge), text: 'Competency Matrix (XYZ/TRG/F/01)'),
              Tab(icon: Icon(Icons.event_note), text: 'Training Calendar (XYZ/TRG/F/02)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Employee Competency Matrix
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO Employee Competency Matrix Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddEmployeeDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('+ New Competency Record'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportEmployeeMatrixIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Matrix ISO Report (PDF)'),
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
                              DataColumn(label: Text('Emp ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Competency Skill', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Training Need', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _employees.map((e) => DataRow(cells: [
                              DataCell(Text(e['empId']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(e['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(e['department']!)),
                              DataCell(Text(e['designation']!)),
                              DataCell(Text(e['competencySkill']!)),
                              DataCell(Text(e['trainingNeeded']!)),
                              DataCell(Chip(label: Text(e['status']!), backgroundColor: Colors.teal.shade100)),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Training Calendar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO Training Calendar & Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddTrainingDialog,
                            icon: const Icon(Icons.event),
                            label: const Text('+ New Training Schedule'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportTrainingPlanIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Training Plan (PDF)'),
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
                              DataColumn(label: Text('Training Topic', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Planned Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Faculty / Trainer', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Target Attendees', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _trainings.map((t) => DataRow(cells: [
                              DataCell(Text(t['srNo']!)),
                              DataCell(Text(t['topic']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(t['plannedDate']!)),
                              DataCell(Text(t['faculty']!)),
                              DataCell(Text(t['attendees']!)),
                              DataCell(Chip(label: Text(t['status']!), backgroundColor: Colors.blue.shade100)),
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
