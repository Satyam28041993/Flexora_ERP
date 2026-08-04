import 'package:flutter/material.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';

class MaintenanceLogsScreen extends StatefulWidget {
  const MaintenanceLogsScreen({super.key});

  @override
  State<MaintenanceLogsScreen> createState() => _MaintenanceLogsScreenState();
}

class _MaintenanceLogsScreenState extends State<MaintenanceLogsScreen> {
  final List<Map<String, String>> _equipments = [
    {
      'srNo': '1',
      'name': 'Lombardy 8-Color Flexo Printing Press',
      'make': 'Lombardy Italy',
      'capacity': '370mm Web / 150m/min',
      'idNo': 'MC-01',
      'remarks': 'Annual Maintenance Schedule (Frequency: Yearly)',
    },
    {
      'srNo': '2',
      'name': 'RM Storage Tank / Unwinder',
      'make': 'Flexora Custom',
      'capacity': '31.93 MTS',
      'idNo': 'RM-01',
      'remarks': 'Quarterly Mechanical Inspection (Frequency: Yearly)',
    },
    {
      'srNo': '3',
      'name': 'High Speed Slitter Rewinder Machine',
      'make': 'Khyati Engg',
      'capacity': '450mm Roll Width',
      'idNo': 'SLT-01',
      'remarks': 'Monthly Blade Alignment & Tension Calibration',
    },
  ];

  final List<Map<String, String>> _breakdowns = [
    {
      'srNo': '1',
      'date': '12/06/2025',
      'equipment': 'Lombardy Flexo Press',
      'idNo': 'MC-01',
      'nature': 'UV Curing Lamp Overheating',
      'cause': 'Exhaust duct dust accumulation.',
      'corrective': 'Cleaned exhaust fan filter and replaced UV lamp module #2.',
      'downtime': '2.5 Hours',
      'preventive': 'Bi-weekly duct cleaning added to PM check sheet.',
    },
  ];

  final List<Map<String, String>> _toolings = [
    {
      'srNo': '1',
      'usedInMachine': 'Lombardy Press 1',
      'idNo': 'DIE-MAG-370-01',
      'description': '370mm Magnetic Cylinder (Z-88 Pitch)',
      'location': 'Tool Room Cabinet A-2',
      'remarks': 'Good Condition',
    },
    {
      'srNo': '2',
      'usedInMachine': 'Slitter Rewinder',
      'idNo': 'BLD-SLT-04',
      'description': 'Circular Rotary Slitting Shear Blades',
      'location': 'Tool Room Drawer B-1',
      'remarks': 'Sharpened on 01.07.2025',
    },
  ];

  void _exportEquipmentsIso() {
    final doc = IsoReportDocument(
      title: 'LIST OF EQUIPMENTS / MACHINERY (XYZ/MNT/F/01)',
      docNo: 'LE/MNT/LOE',
      revNo: '00',
      revDate: '01.02.2025',
      preparedBy: 'Maintenance Engineer',
      approvedBy: 'Plant Head',
      headers: ['Sr. No.', 'Equipment Name', 'Make', 'Capacity', 'Identification No.', 'Remarks & Frequency'],
      dataRows: _equipments.map((e) => [
        e['srNo']!,
        e['name']!,
        e['make']!,
        e['capacity']!,
        e['idNo']!,
        e['remarks']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportBreakdownsIso() {
    final doc = IsoReportDocument(
      title: 'BREAKDOWN MAINTENANCE REGISTER',
      docNo: 'CEW/MNT/BMR',
      revNo: '00',
      revDate: '01.06.2024',
      preparedBy: 'Maintenance Supervisor',
      approvedBy: 'Plant Head',
      headers: ['Sr.', 'Date', 'Equipment Name', 'ID No.', 'Nature of Breakdown', 'Cause', 'Corrective Action', 'Downtime', 'Preventive Action'],
      dataRows: _breakdowns.map((b) => [
        b['srNo']!,
        b['date']!,
        b['equipment']!,
        b['idNo']!,
        b['nature']!,
        b['cause']!,
        b['corrective']!,
        b['downtime']!,
        b['preventive']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _exportToolingsIso() {
    final doc = IsoReportDocument(
      title: 'MASTER LIST OF TOOLING / DIES & FIXTURES',
      docNo: 'XYZ/MNT/F/02',
      revNo: '00',
      revDate: '01.06.2024',
      preparedBy: 'Tool Room Incharge',
      approvedBy: 'Plant Head',
      headers: ['Sr. No.', 'Used In Machine', 'Identification No.', 'Tooling Description', 'Storage Location', 'Remarks'],
      dataRows: _toolings.map((t) => [
        t['srNo']!,
        t['usedInMachine']!,
        t['idNo']!,
        t['description']!,
        t['location']!,
        t['remarks']!,
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  void _showAddEquipmentDialog() {
    final nameCtrl = TextEditingController();
    final makeCtrl = TextEditingController();
    final capCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'MC-0${_equipments.length + 1}');
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚙️ Register New Equipment (LE/MNT/LOE)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Equipment Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: makeCtrl, decoration: const InputDecoration(labelText: 'Make / Manufacturer', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: capCtrl, decoration: const InputDecoration(labelText: 'Capacity / Specifications', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Identification No. (e.g. MC-01)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: remarksCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Maintenance Schedule & Frequency', border: OutlineInputBorder())),
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
                  _equipments.add({
                    'srNo': '${_equipments.length + 1}',
                    'name': nameCtrl.text,
                    'make': makeCtrl.text.isEmpty ? 'Custom' : makeCtrl.text,
                    'capacity': capCtrl.text.isEmpty ? 'Standard' : capCtrl.text,
                    'idNo': idCtrl.text,
                    'remarks': remarksCtrl.text.isEmpty ? 'Regular Servicing' : remarksCtrl.text,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipment Master Saved!')));
              }
            },
            label: const Text('Save Equipment'),
          ),
        ],
      ),
    );
  }

  void _showAddBreakdownDialog() {
    final eqCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'MC-01');
    final natureCtrl = TextEditingController();
    final causeCtrl = TextEditingController();
    final corrCtrl = TextEditingController();
    final downtimeCtrl = TextEditingController(text: '1.0 Hour');
    final prevCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ New Breakdown Log Entry (CEW/MNT/BMR)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: eqCtrl, decoration: const InputDecoration(labelText: 'Equipment Name *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Equipment ID No.', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: natureCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Nature of Breakdown *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: causeCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Cause of Breakdown', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: corrCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Corrective Action Taken', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: downtimeCtrl, decoration: const InputDecoration(labelText: 'Equipment Downtime Hours', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: prevCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Preventive Action Plan', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            icon: const Icon(Icons.warning),
            onPressed: () {
              if (eqCtrl.text.isNotEmpty) {
                setState(() {
                  _breakdowns.add({
                    'srNo': '${_breakdowns.length + 1}',
                    'date': DateTime.now().toString().split(' ')[0],
                    'equipment': eqCtrl.text,
                    'idNo': idCtrl.text,
                    'nature': natureCtrl.text,
                    'cause': causeCtrl.text.isEmpty ? 'Under Investigation' : causeCtrl.text,
                    'corrective': corrCtrl.text.isEmpty ? 'Repaired' : corrCtrl.text,
                    'downtime': downtimeCtrl.text,
                    'preventive': prevCtrl.text.isEmpty ? 'N/A' : prevCtrl.text,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Breakdown Maintenance Log Saved!')));
              }
            },
            label: const Text('Save Breakdown Log'),
          ),
        ],
      ),
    );
  }

  void _showAddToolingDialog() {
    final machineCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'TOOL-0${_toolings.length + 1}');
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Tool Room');
    final remarksCtrl = TextEditingController(text: 'Good Condition');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🛠️ New Tooling / Die Master Entry (XYZ/MNT/F/02)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: machineCtrl, decoration: const InputDecoration(labelText: 'Used In Machine *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Tooling / Die ID No. *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Tool Description & Specs *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Storage Location', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Status / Remarks', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            icon: const Icon(Icons.check),
            onPressed: () {
              if (descCtrl.text.isNotEmpty) {
                setState(() {
                  _toolings.add({
                    'srNo': '${_toolings.length + 1}',
                    'usedInMachine': machineCtrl.text.isEmpty ? 'General' : machineCtrl.text,
                    'idNo': idCtrl.text,
                    'description': descCtrl.text,
                    'location': locCtrl.text,
                    'remarks': remarksCtrl.text,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tooling Master Entry Saved!')));
              }
            },
            label: const Text('Save Tooling Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('⚙️ Equipment & Maintenance Register (XYZ/MNT/F/01-04)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.precision_manufacturing), text: 'Equipments List (LE/MNT/LOE)'),
              Tab(icon: Icon(Icons.warning), text: 'Breakdown Log (CEW/MNT/BMR)'),
              Tab(icon: Icon(Icons.handyman), text: 'Master Tooling List (XYZ/MNT/F/02)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Equipment
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISO Equipment Master Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddEquipmentDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('+ New Equipment'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportEquipmentsIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Equipment List (PDF)'),
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
                              DataColumn(label: Text('Equipment Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Make', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('ID No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Remarks & Maintenance Frequency', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _equipments.map((e) => DataRow(cells: [
                              DataCell(Text(e['srNo']!)),
                              DataCell(Text(e['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(e['make']!)),
                              DataCell(Text(e['capacity']!)),
                              DataCell(Chip(label: Text(e['idNo']!), backgroundColor: Colors.blue.shade100)),
                              DataCell(Text(e['remarks']!)),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: Breakdown
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Breakdown Maintenance Register', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
                            onPressed: _showAddBreakdownDialog,
                            icon: const Icon(Icons.build),
                            label: const Text('+ New Breakdown Log'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportBreakdownsIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Breakdown ISO Log (PDF)'),
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
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nature of Breakdown', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Cause', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Corrective Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Downtime', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _breakdowns.map((b) => DataRow(cells: [
                              DataCell(Text(b['date']!)),
                              DataCell(Text(b['equipment']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(b['nature']!)),
                              DataCell(Text(b['cause']!)),
                              DataCell(Text(b['corrective']!)),
                              DataCell(Chip(label: Text(b['downtime']!), backgroundColor: Colors.red.shade100)),
                            ])).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 3: Tooling
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Master List of Tooling & Dies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: _showAddToolingDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('+ New Tooling Entry'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: _exportToolingsIso,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Tooling List (PDF)'),
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
                              DataColumn(label: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Identification No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _toolings.map((t) => DataRow(cells: [
                              DataCell(Text(t['srNo']!)),
                              DataCell(Text(t['usedInMachine']!)),
                              DataCell(Chip(label: Text(t['idNo']!), backgroundColor: Colors.amber.shade100)),
                              DataCell(Text(t['description']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(t['location']!)),
                              DataCell(Text(t['remarks']!)),
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
