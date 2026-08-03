import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../production/data/models/production_job_model.dart';
import '../../../production/logic/production_providers.dart';
import '../../../rm_ledger/logic/rm_ledger_providers.dart';
import '../../../tooling_master/logic/tooling_providers.dart';

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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📈 Executive Reports & Business Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Executive Summary Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Generating Executive PDF Report...'), backgroundColor: Colors.blue.shade800),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export All Reports to Excel (CSV)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Exporting All Parameters to Excel...'), backgroundColor: Colors.green.shade800),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Production & Pipeline'),
            Tab(text: '2. RM Stock & Wastage'),
            Tab(text: '3. Polymer Plates & Dies'),
            Tab(text: '4. QC Yield & ISO'),
            Tab(text: '5. Dispatch & Revenue'),
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
        const Text('🏭 Production Pipeline Executive Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 12),

        // KPI Summary Cards
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

        // Stage Breakdown Table
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

  /// Tab 2: Raw Material Stock & Wastage Report
  Widget _buildRmReport() {
    final balances = ref.watch(rmStockBalancesProvider);
    final totalRmtOnHand = balances.fold<double>(0, (sum, b) => sum + b.rmtOnHand);
    final totalSqMtrOnHand = balances.fold<double>(0, (sum, b) => sum + b.sqMtrOnHand);
    final totalStockVal = balances.fold<double>(0, (sum, b) => sum + b.stockValue);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('📊 Raw Material Consumption & Wastage Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
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
        const Text('🛠️ Polymer Plates & Die Tooling Master Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Registered Flexo Plates', '$plateCount Sets', Colors.blue.shade800, Icons.layers),
            const SizedBox(width: 12),
            _kpiBox('Registered Punch/Dies', '$dieCount Dies', Colors.amber.shade900, Icons.cut),
            const SizedBox(width: 12),
            _kpiBox('Revisions & Remakes', '3 Revisions', Colors.purple.shade800, Icons.replay),
            const SizedBox(width: 12),
            _kpiBox('Tooling Asset Value', '₹4,85,000', Colors.green.shade800, Icons.payments),
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
                    _tableRow3('Flexible Magnetic Die', 'Inline Rotary Die Cutting', '4 Sets'),
                    _tableRow3('Solid Cylinder Die', 'Heavy GSM High Speed Punching', '2 Sets'),
                    _tableRow3('Offline Die (Punch)', 'Offline Inspection & Sheet Punching', '3 Sets'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🔍 Quality Assurance, Yield & ISO Audit Compliance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('First-Pass Yield (FPY)', '98.2%', Colors.green.shade800, Icons.check_circle),
            const SizedBox(width: 12),
            _kpiBox('QC Gate 1 Inspection', '100% Passed', Colors.blue.shade800, Icons.fact_check),
            const SizedBox(width: 12),
            _kpiBox('QC Gate 2 Start-Up', '100% Passed', Colors.teal.shade800, Icons.verified_user),
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
                    _tableRow3('Art Work & Proof Verification', 'PGPL/QC/F-01', '100% Passed'),
                    _tableRow3('Printing Start-Up & Shade Match', 'PGPL/QC/F-02', '99.1% Passed'),
                    _tableRow3('Die Registration & Cut Quality', 'PGPL/QC/F-03', '98.8% Passed'),
                    _tableRow3('Final Dispatch Box Labeling', 'PGPL/QC/F-04', '100% Passed'),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('🚚 Dispatch & Order Value Summary Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
        const SizedBox(height: 12),

        Row(
          children: [
            _kpiBox('Monthly Order Intake Qty', '1.85 Million Pcs', Colors.blue.shade800, Icons.receipt_long),
            const SizedBox(width: 12),
            _kpiBox('Dispatched Order Qty', '1.42 Million Pcs', Colors.green.shade800, Icons.local_shipping),
            const SizedBox(width: 12),
            _kpiBox('Pending PO Order Qty', '430,000 Pcs', Colors.amber.shade900, Icons.pending_actions),
            const SizedBox(width: 12),
            _kpiBox('On-Time Delivery Rate', '99.4%', Colors.teal.shade800, Icons.speed),
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
                    _tableRow('TEMPLE', '600,000 Pcs', '0 Pcs', '600,000 Pcs'),
                    _tableRow('RALLIS INDIA', '350,000 Pcs', '250,000 Pcs', '100,000 Pcs'),
                    _tableRow('ARIES AGRO', '180,000 Pcs', '130,000 Pcs', '50,000 Pcs'),
                    _tableRow('OCTAGREEN', '120,000 Pcs', '100,000 Pcs', '20,000 Pcs'),
                    _tableRow('BIRLA GROUP', '40,000 Pcs', '40,000 Pcs', '0 Pcs'),
                  ],
                ),
              ],
            ),
          ),
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
