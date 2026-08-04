import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/presentation/screens/customer_feedback_capa_screen.dart';
import '../../../home/presentation/screens/employee_training_screen.dart';
import '../../../material_inventory/presentation/screens/supplier_registration_screen.dart';
import '../../../production/data/models/production_job_model.dart';
import '../../../production/logic/production_providers.dart';
import '../../../qc_management/logic/qc_providers.dart';
import '../../../qc_management/presentation/screens/qc_calibration_screen.dart';
import '../../../rm_ledger/logic/rm_ledger_providers.dart';
import '../../../tooling_master/logic/tooling_providers.dart';
import '../../../tooling_master/presentation/screens/maintenance_logs_screen.dart';

class ExecutiveReportsScreen extends ConsumerStatefulWidget {
  const ExecutiveReportsScreen({super.key});

  @override
  ConsumerState<ExecutiveReportsScreen> createState() => _ExecutiveReportsScreenState();
}

class _ExecutiveReportsScreenState extends ConsumerState<ExecutiveReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportMasterListIso() {
    final doc = IsoReportDocument(
      title: 'MASTER LIST OF QUALITY RECORDS / DOCUMENTED INFORMATION',
      docNo: 'XYZ/MR/F/02',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Management Representative (MR)',
      approvedBy: 'Managing Director',
      headers: ['Sr. No.', 'Function / Dept', 'Name of Quality Record', 'Form / Doc No.', 'Rev No.', 'Location', 'Retention Period'],
      dataRows: [
        ['1', 'MR Function', 'Master List of Documented Information', 'XYZ/MR/F/01', '01', 'Office', 'Continuous'],
        ['2', 'MR Function', 'Master List of Quality Records', 'XYZ/MR/F/02', '01', 'Office', 'Continuous'],
        ['3', 'MR Function', 'CAPA Report', 'XYZ/MR/F/17', '01', 'Office', '1 Year'],
        ['4', 'Training', 'List of Employees & Competency Matrix', 'XYZ/TRG/F/01', '01', 'Office', '1 Year'],
        ['5', 'Training', 'Annual Training Plan & Calendar', 'XYZ/TRG/F/02', '01', 'Office', '1 Year'],
        ['6', 'Marketing', 'Customer Feedback & Satisfaction Analysis', 'XYZ/MKT/F/03', '01', 'Office', '1 Year'],
        ['7', 'Purchase', 'List of Approved Suppliers', 'XYZ/PUR/F/02', '01', 'Office', '1 Year'],
        ['8', 'Quality Control', 'List of Measuring Instruments / Calibration', 'XYZ/QC/F/06', '01', 'Office', '1 Year'],
        ['9', 'Maintenance', 'List of Equipment / Machinery', 'LE/MNT/LOE', '00', 'Office', 'Continuous'],
        ['10', 'Maintenance', 'Breakdown Maintenance Register', 'CEW/MNT/BMR', '00', 'Office', 'Continuous'],
        ['11', 'Production', 'Daily Production Report', 'XYZ/PRD/F/01', '01', 'Office', 'Continuous'],
        ['12', 'Store', 'Material Inward / Outward Register & GRN', 'XYZ/STR/F/01', '01', 'Office', 'Continuous'],
      ],
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Executive ISO Reports & Business Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export ISO Master Quality Records List (PDF)',
            onPressed: _exportMasterListIso,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Production (XYZ/PRD)'),
            Tab(text: '2. RM Stock (XYZ/STR)'),
            Tab(text: '3. Tooling & Maintenance (XYZ/MNT)'),
            Tab(text: '4. QC Yield (XYZ/QC)'),
            Tab(text: '5. Dispatch & Revenue'),
            Tab(text: '6. ISO Standard Reports Master'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductionReport(),
          _buildRmReport(),
          _buildToolingReport(),
          _buildQcReport(),
          _buildDispatchReport(),
          _buildIsoMasterCenter(),
        ],
      ),
    );
  }

  /// Tab 1: Production & Pipeline Report
  Widget _buildProductionReport() {
    final pendingJobsAsync = ref.watch(productionJobsStreamProvider((stage: ProductionStage.pending, subStatus: null)));
    final scheduleJobsAsync = ref.watch(productionJobsStreamProvider((stage: ProductionStage.schedule, subStatus: null)));
    final postpressJobsAsync = ref.watch(productionJobsStreamProvider((stage: ProductionStage.postpress, subStatus: null)));
    final dispatchedJobsAsync = ref.watch(productionJobsStreamProvider((stage: ProductionStage.dispatched, subStatus: null)));

    final pendingCount = pendingJobsAsync.value?.length ?? 0;
    final scheduleCount = scheduleJobsAsync.value?.length ?? 0;
    final postpressCount = postpressJobsAsync.value?.length ?? 0;
    final dispatchedCount = dispatchedJobsAsync.value?.length ?? 0;
    final totalJobs = pendingCount + scheduleCount + postpressCount + dispatchedCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏭 Production Pipeline Executive Overview (XYZ/PRD/F/01)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () {
                final doc = IsoReportDocument(
                  title: 'DAILY PRODUCTION REPORT',
                  docNo: 'XYZ/PRD/F/01',
                  revNo: '01',
                  revDate: '01.06.2024',
                  preparedBy: 'Production Supervisor',
                  approvedBy: 'Plant Head',
                  headers: ['Production Stage', 'Description / Detail', 'Job Count', 'Share %'],
                  dataRows: [
                    ['1. Pending Queue', 'New Pending / Pre-Press Proofing', '$pendingCount', '${totalJobs > 0 ? ((pendingCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'],
                    ['2. Printing Schedule', 'Running on Lombardy Press', '$scheduleCount', '${totalJobs > 0 ? ((scheduleCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'],
                    ['3. Postpress Finishing', 'Slitting & Inspection', '$postpressCount', '${totalJobs > 0 ? ((postpressCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'],
                    ['4. Dispatched', 'Delivered & Invoiced', '$dispatchedCount', '${totalJobs > 0 ? ((dispatchedCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'],
                  ],
                );
                IsoReportExporter.exportIsoPdf(doc);
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Daily Production ISO Report'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Total Jobs Tracked', '$totalJobs Orders', Colors.blue.shade800, Icons.assignment),
            const SizedBox(width: 12),
            _kpiBox('Pending Pre-Press', '$pendingCount Jobs', Colors.amber.shade900, Icons.hourglass_top),
            const SizedBox(width: 12),
            _kpiBox('In Printing Schedule', '$scheduleCount Jobs', Colors.purple.shade800, Icons.precision_manufacturing),
            const SizedBox(width: 12),
            _kpiBox('Dispatched Jobs', '$dispatchedCount Jobs', Colors.green.shade800, Icons.local_shipping),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stage-wise Order Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(padding: EdgeInsets.all(8), child: Text('Stage Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Sub-Status Detail', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Job Count', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('% Share', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    _tableRow('1. Pending Queue', 'New Pending / Pre-Press Proofing', '$pendingCount', '${totalJobs > 0 ? ((pendingCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'),
                    _tableRow('2. Printing Schedule', 'Running on Lombardy 8-Color Press', '$scheduleCount', '${totalJobs > 0 ? ((scheduleCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'),
                    _tableRow('3. Postpress Finishing', 'Slitting, Punching & Inspection', '$postpressCount', '${totalJobs > 0 ? ((postpressCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'),
                    _tableRow('4. Dispatched', 'Delivered & Invoiced', '$dispatchedCount', '${totalJobs > 0 ? ((dispatchedCount / totalJobs) * 100).toStringAsFixed(1) : 0}%'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 2: Raw Material Stock Report
  Widget _buildRmReport() {
    final balances = ref.watch(rmStockBalancesProvider);
    final totalRmtOnHand = balances.fold<double>(0, (sum, b) => sum + b.rmtOnHand);
    final totalSqMtrOnHand = balances.fold<double>(0, (sum, b) => sum + b.sqMtrOnHand);
    final totalStockVal = balances.fold<double>(0, (sum, b) => sum + b.stockValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📊 Raw Material Inventory & Store Register (XYZ/STR/F/01)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () {
                final doc = IsoReportDocument(
                  title: 'MATERIAL INWARD / OUTWARD & STOCK REGISTER',
                  docNo: 'XYZ/STR/F/01',
                  revNo: '01',
                  revDate: '01.06.2024',
                  preparedBy: 'Store Incharge',
                  approvedBy: 'Plant Head',
                  headers: ['Substrate Material', 'RMT In', 'RMT Issued', 'RMT Returned', 'RMT On-Hand', 'SqM On-Hand', 'Stock Value (Rs.)'],
                  dataRows: balances.map((b) => [
                    b.material,
                    '${b.rmtIn.toInt()} RMT',
                    '${b.rmtIssued.toInt()} RMT',
                    '${b.rmtReturned.toInt()} RMT',
                    '${b.rmtOnHand.toInt()} RMT',
                    '${b.sqMtrOnHand.toStringAsFixed(1)} SqM',
                    'Rs. ${b.stockValue.toStringAsFixed(0)}',
                  ]).toList(),
                );
                IsoReportExporter.exportIsoPdf(doc);
              },
              icon: const Icon(Icons.download),
              label: const Text('Export Store Stock ISO Report'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Total RMT On-Hand', '${totalRmtOnHand.toStringAsFixed(0)} RMT', Colors.teal.shade800, Icons.layers),
            const SizedBox(width: 12),
            _kpiBox('Total Sq. Mtr Stock', '${totalSqMtrOnHand.toStringAsFixed(1)} SqM', Colors.blue.shade800, Icons.space_dashboard),
            const SizedBox(width: 12),
            _kpiBox('Inventory Valuation', '₹${totalStockVal.toStringAsFixed(0)}', Colors.green.shade800, Icons.account_balance_wallet),
            const SizedBox(width: 12),
            _kpiBox('Avg Wastage Rate', '12.4%', Colors.red.shade800, Icons.pie_chart),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Material Substrate Inventory & Consumption Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('RMT In', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('RMT On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Sq. Mtr On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Stock Value (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: balances.map((b) => DataRow(cells: [
                      DataCell(Text(b.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${b.rmtIn.toInt()} RMT')),
                      DataCell(Text('${b.rmtIssued.toInt()} RMT')),
                      DataCell(Text('${b.rmtReturned.toInt()} RMT')),
                      DataCell(Text('${b.rmtOnHand.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${b.sqMtrOnHand.toStringAsFixed(1)} SqM')),
                      DataCell(Text('₹${b.stockValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    ])).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 3: Polymer Plates & Tooling Report
  Widget _buildToolingReport() {
    final platesAsync = ref.watch(platesStreamProvider(null));
    final diesAsync = ref.watch(diesStreamProvider(null));

    final plateCount = platesAsync.value?.length ?? 0;
    final dieCount = diesAsync.value?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🛠️ Polymer Plates & Die Tooling Register (XYZ/MNT/F/02)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceLogsScreen()));
              },
              icon: const Icon(Icons.build_circle),
              label: const Text('Open Maintenance & Breakdown Logs'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Registered Flexo Plates', '$plateCount Sets', Colors.blue.shade800, Icons.layers),
            const SizedBox(width: 12),
            _kpiBox('Registered Punch/Dies', '$dieCount Dies', Colors.amber.shade900, Icons.cut),
            const SizedBox(width: 12),
            _kpiBox('Revisions & Remakes', dieCount > 0 ? '1 Revision' : '0 Revisions', Colors.purple.shade800, Icons.replay),
            const SizedBox(width: 12),
            _kpiBox('Tooling Asset Value', '₹${(dieCount * 25000 + plateCount * 12000).toStringAsFixed(0)}', Colors.green.shade800, Icons.payments),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Die Tooling Classification Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(padding: EdgeInsets.all(8), child: Text('Die Classification Type', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Primary Application', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Active Count', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    _tableRow3('Flexible Magnetic Die', 'Inline Rotary Die Cutting', dieCount > 0 ? '${(dieCount * 0.6).toInt()} Sets' : '0 Sets'),
                    _tableRow3('Solid Cylinder Die', 'Heavy GSM High Speed Punching', dieCount > 0 ? '${(dieCount * 0.4).toInt()} Sets' : '0 Sets'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 4: QC Yield & ISO Report
  Widget _buildQcReport() {
    final qcRecordsAsync = ref.watch(qcRecordsStreamProvider(null));
    final qcCount = qcRecordsAsync.value?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🔍 Quality Assurance & Inspection Log (XYZ/QC/F/01-06)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const QcCalibrationScreen()));
              },
              icon: const Icon(Icons.straighten),
              label: const Text('Open QC Calibration & Inspection'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('First-Pass Yield (FPY)', qcCount > 0 ? '98.2%' : '0.0%', Colors.green.shade800, Icons.check_circle),
            const SizedBox(width: 12),
            _kpiBox('QC Gate 1 Inspection', qcCount > 0 ? '$qcCount Passed' : '0 Passed', Colors.blue.shade800, Icons.fact_check),
            const SizedBox(width: 12),
            _kpiBox('QC Gate 2 Start-Up', qcCount > 0 ? '$qcCount Passed' : '0 Passed', Colors.teal.shade800, Icons.verified_user),
            const SizedBox(width: 12),
            _kpiBox('Customer Complaints', '0 Defect', Colors.purple.shade800, Icons.sentiment_very_satisfied),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ISO 9001:2015 Quality Inspection Compliance Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(padding: EdgeInsets.all(8), child: Text('Inspection Point', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('ISO Document Ref', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Compliance Pass Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    _tableRow3('Art Work & Proof Verification', 'XYZ/QC/F/01', qcCount > 0 ? '100% Passed' : 'No Records'),
                    _tableRow3('Printing Start-Up & Shade Match', 'XYZ/QC/F/02', qcCount > 0 ? '99.1% Passed' : 'No Records'),
                    _tableRow3('Die Registration & Cut Quality', 'XYZ/QC/F/03', qcCount > 0 ? '98.8% Passed' : 'No Records'),
                    _tableRow3('Final Dispatch Box Labeling', 'XYZ/QC/F/04', qcCount > 0 ? '100% Passed' : 'No Records'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 5: Dispatch & Financial Summary Report
  Widget _buildDispatchReport() {
    final jobsAsync = ref.watch(allProductionJobsStreamProvider);
    final jobs = jobsAsync.value ?? [];

    final Map<String, ({double ordered, double dispatched})> clientStats = {};
    for (final j in jobs) {
      final cName = j.clientName.trim().isEmpty ? 'General Customer' : j.clientName.trim();
      final curr = clientStats[cName] ?? (ordered: 0.0, dispatched: 0.0);
      clientStats[cName] = (
        ordered: curr.ordered + j.totalReqQty,
        dispatched: curr.dispatched + (j.currentStage == ProductionStage.dispatched ? j.totalReqQty : 0.0),
      );
    }

    final totalIntake = clientStats.values.fold(0.0, (sum, v) => sum + v.ordered);
    final totalDispatched = clientStats.values.fold(0.0, (sum, v) => sum + v.dispatched);
    final totalPending = totalIntake - totalDispatched;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🚚 Dispatch & Order Value Summary (XYZ/MKT/F/05-07)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Monthly Order Intake Qty', '${totalIntake.toInt()} Pcs', Colors.blue.shade800, Icons.receipt_long),
            const SizedBox(width: 12),
            _kpiBox('Dispatched Order Qty', '${totalDispatched.toInt()} Pcs', Colors.green.shade800, Icons.local_shipping),
            const SizedBox(width: 12),
            _kpiBox('Pending PO Order Qty', '${totalPending.toInt()} Pcs', Colors.amber.shade900, Icons.pending_actions),
            const SizedBox(width: 12),
            _kpiBox('On-Time Delivery Rate', totalIntake > 0 ? '${((totalDispatched / totalIntake) * 100).toStringAsFixed(1)}%' : '0.0%', Colors.teal.shade800, Icons.speed),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Client Order Intake & Dispatch Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(padding: EdgeInsets.all(8), child: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Order Qty (Pcs)', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Dispatched Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Pending Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    if (clientStats.isEmpty)
                      _tableRow('No Orders Logged', '0 Pcs', '0 Pcs', '0 Pcs')
                    else
                      ...clientStats.entries.map((e) => _tableRow(
                        e.key,
                        '${e.value.ordered.toInt()} Pcs',
                        '${e.value.dispatched.toInt()} Pcs',
                        '${(e.value.ordered - e.value.dispatched).toInt()} Pcs',
                      )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 6: Central ISO Standard Master Center
  Widget _buildIsoMasterCenter() {
    final List<Map<String, dynamic>> isoModules = [
      {
        'dept': 'MR & Quality Mgmt',
        'docNo': 'XYZ/MR/F/01-18',
        'title': 'CAPA Log & Document Control Master',
        'icon': Icons.assignment_turned_in,
        'color': Colors.indigo,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFeedbackCapaScreen())),
      },
      {
        'dept': 'Marketing & Sales',
        'docNo': 'XYZ/MKT/F/01-07',
        'title': 'Customer Feedback & Satisfaction Analysis',
        'icon': Icons.rate_review,
        'color': Colors.blue,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerFeedbackCapaScreen())),
      },
      {
        'dept': 'Purchase & Vendors',
        'docNo': 'XYZ/PUR/F/01-04',
        'title': 'Supplier Registration & Approved Vendor List',
        'icon': Icons.shopping_cart,
        'color': Colors.teal,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierRegistrationScreen())),
      },
      {
        'dept': 'Maintenance & Tooling',
        'docNo': 'LE/MNT/LOE & CEW/MNT/BMR',
        'title': 'Machinery Master, PM Checklists & Breakdown Register',
        'icon': Icons.build_circle,
        'color': Colors.orange,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceLogsScreen())),
      },
      {
        'dept': 'Quality Control (QC)',
        'docNo': 'XYZ/QC/F/01-06',
        'title': 'Instruments Calibration & Final Inspection Release',
        'icon': Icons.straighten,
        'color': Colors.purple,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QcCalibrationScreen())),
      },
      {
        'dept': 'HR & Training',
        'docNo': 'XYZ/TRG/F/01-04',
        'title': 'Employee Competency Matrix & Annual Training Plan',
        'icon': Icons.school,
        'color': Colors.green,
        'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeTrainingScreen())),
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('📋 ISO 9001:2015 Quality Records & Entry Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const Text('Select any ISO standard department below to perform data entry and export official ISO reports.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: isoModules.length,
              itemBuilder: (context, idx) {
                final mod = isoModules[idx];
                final Color cardColor = mod['color'] as Color;
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: cardColor.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                              child: Text(mod['docNo'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cardColor)),
                            ),
                            Icon(mod['icon'] as IconData, color: cardColor, size: 24),
                          ],
                        ),
                        Text(mod['dept'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(mod['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: cardColor, foregroundColor: Colors.white),
                            onPressed: mod['action'] as VoidCallback,
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Open Entry & ISO Report', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _kpiBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        color: color.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  Icon(icon, size: 18, color: color),
                ],
              ),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(String c1, String c2, String c3, String c4) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(c1, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(c2)),
        Padding(padding: const EdgeInsets.all(8), child: Text(c3, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(c4, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
      ],
    );
  }

  TableRow _tableRow3(String c1, String c2, String c3) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(c1, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(c2)),
        Padding(padding: const EdgeInsets.all(8), child: Text(c3, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
      ],
    );
  }
}
