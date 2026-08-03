import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/rm_transaction_model.dart';
import '../../logic/rm_ledger_providers.dart';
import '../widgets/rm_entry_dialogs.dart';

class RmLedgerScreen extends ConsumerStatefulWidget {
  const RmLedgerScreen({super.key});

  @override
  ConsumerState<RmLedgerScreen> createState() => _RmLedgerScreenState();
}

class _RmLedgerScreenState extends ConsumerState<RmLedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

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
        title: const Text('📊 RM Issue & Return Stock Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Add Stock-In Purchase',
            onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
          ),
          IconButton(
            icon: const Icon(Icons.launch),
            tooltip: 'Issue Roll to Job',
            onPressed: () => showDialog(context: context, builder: (_) => const NewIssueDialog()),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Return Roll to Store',
            onPressed: () => showDialog(context: context, builder: (_) => const NewReturnDialog()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Store Rolls On-Hand'),
            Tab(text: '2. Stock-In (Purchases)'),
            Tab(text: '3. Press Issuance'),
            Tab(text: '4. Press Returns'),
            Tab(text: '5. Job Wastage Ledger'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Material, Web Size, Job Doc No, Supplier, or Client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOnHandStockView(),
                _buildStockInsView(),
                _buildIssuesView(),
                _buildReturnsView(),
                _buildWastageLedgerView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 1: Live Store Roll Inventory On-Hand
  Widget _buildOnHandStockView() {
    final balances = ref.watch(rmStockBalancesProvider);

    final filtered = balances.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.material.toLowerCase().contains(_searchQuery) ||
          b.webSizeMm.toString().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No store roll inventory available.'));
    }

    final totalRmtOnHand = filtered.fold<double>(0, (sum, item) => sum + item.rmtOnHand);
    final totalSqMtrOnHand = filtered.fold<double>(0, (sum, item) => sum + item.sqMtrOnHand);
    final totalStockValue = filtered.fold<double>(0, (sum, item) => sum + item.stockValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Stock Value Summary Header
          Row(
            children: [
              _kpiCard('Total RMT On-Hand', '${totalRmtOnHand.toStringAsFixed(0)} RMT', Colors.blue.shade800),
              const SizedBox(width: 12),
              _kpiCard('Total Sq. Mtr On-Hand', '${totalSqMtrOnHand.toStringAsFixed(1)} SqM', Colors.teal.shade800),
              const SizedBox(width: 12),
              _kpiCard('Estimated Stock Value', '₹${totalStockValue.toStringAsFixed(0)}', Colors.green.shade800),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Web Size (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sq. Mtr On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Avg Rate (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Stock Value (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((b) {
                    final isNegative = b.rmtOnHand < 0;
                    return DataRow(
                      cells: [
                        DataCell(Text(b.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${b.webSizeMm.toInt()} mm')),
                        DataCell(Text('${b.rmtIn.toInt()} RMT')),
                        DataCell(Text('${b.rmtIssued.toInt()} RMT')),
                        DataCell(Text('${b.rmtReturned.toInt()} RMT')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isNegative ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${b.rmtOnHand.toInt()} RMT',
                              style: TextStyle(fontWeight: FontWeight.bold, color: isNegative ? Colors.red.shade900 : Colors.green.shade900),
                            ),
                          ),
                        ),
                        DataCell(Text('${b.sqMtrOnHand.toStringAsFixed(1)} SqM')),
                        DataCell(Text('₹${b.avgRate.toStringAsFixed(2)}')),
                        DataCell(Text('₹${b.stockValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 2: Purchases / Stock-In Log
  Widget _buildStockInsView() {
    final stockInsAsync = ref.watch(rmStockInsStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return stockInsAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.material.toLowerCase().contains(_searchQuery) ||
              i.supplier.toLowerCase().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🛒 Raw Material Purchase Log (Stock-In)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Purchase Receipt'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('GSM/Micron', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Web Size', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sq. Mtr In', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Rate / SqM', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Value In (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(dateFormat.format(item.date))),
                      DataCell(Text(item.supplier)),
                      DataCell(Text(item.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${item.gsmMicron.toInt()}')),
                      DataCell(Text('${item.webSizeMm.toInt()} mm')),
                      DataCell(Text('${item.rmtIn.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text('${item.sqMtrIn.toStringAsFixed(1)} SqM')),
                      DataCell(Text('₹${item.ratePerSqMtr.toStringAsFixed(2)}')),
                      DataCell(Text('₹${item.valueIn.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  /// Tab 3: Press Issuance Log
  Widget _buildIssuesView() {
    final issuesAsync = ref.watch(rmIssuesStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return issuesAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.jobDocNo.toLowerCase().contains(_searchQuery) ||
              i.material.toLowerCase().contains(_searchQuery) ||
              i.client.toLowerCase().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🚀 Paper Rolls Issued to Printing Press', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const NewIssueDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.launch, size: 16),
                  label: const Text('Issue Roll to Job'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Job Doc No', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Web Size', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sq. Mtr Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(dateFormat.format(item.date))),
                      DataCell(Text(item.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                      DataCell(Text(item.client)),
                      DataCell(Text(item.material)),
                      DataCell(Text('${item.webSizeMm.toInt()} mm')),
                      DataCell(Text('${item.rmtIssued.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      DataCell(Text('${item.sqMtrIssued.toStringAsFixed(1)} SqM')),
                      DataCell(Text(item.supplier)),
                      DataCell(Text(item.remarks)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  /// Tab 4: Press Returns Log
  Widget _buildReturnsView() {
    final returnsAsync = ref.watch(rmReturnsStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return returnsAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.jobDocNo.toLowerCase().contains(_searchQuery) ||
              i.material.toLowerCase().contains(_searchQuery) ||
              i.client.toLowerCase().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('↩ Unused Paper Rolls Returned to Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const NewReturnDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Return Roll to Store'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Job Doc No', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Web Size', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sq. Mtr Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    return DataRow(cells: [
                      DataCell(Text(dateFormat.format(item.date))),
                      DataCell(Text(item.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                      DataCell(Text(item.client)),
                      DataCell(Text(item.material)),
                      DataCell(Text('${item.webSizeMm.toInt()} mm')),
                      DataCell(Text('${item.rmtReturned.toInt()} RMT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900))),
                      DataCell(Text('${item.sqMtrReturned.toStringAsFixed(1)} SqM')),
                      DataCell(Text(item.supplier)),
                      DataCell(Text(item.remarks)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  /// Tab 5: Job Usage & Actual Production Wastage Ledger
  Widget _buildWastageLedgerView() {
    final issues = ref.watch(rmIssuesStreamProvider).value ?? [];
    final returns = ref.watch(rmReturnsStreamProvider).value ?? [];

    // Group by JobDocNo
    final Map<String, ({String client, String mat, double web, double issued, double returned})> jobMap = {};

    for (final item in issues) {
      final key = item.jobDocNo.trim();
      final existing = jobMap[key] ?? (client: item.client, mat: item.material, web: item.webSizeMm, issued: 0.0, returned: 0.0);
      jobMap[key] = (
        client: item.client.isNotEmpty ? item.client : existing.client,
        mat: item.material.isNotEmpty ? item.material : existing.mat,
        web: item.webSizeMm > 0 ? item.webSizeMm : existing.web,
        issued: existing.issued + item.rmtIssued,
        returned: existing.returned,
      );
    }

    for (final item in returns) {
      final key = item.jobDocNo.trim();
      final existing = jobMap[key] ?? (client: item.client, mat: item.material, web: item.webSizeMm, issued: 0.0, returned: 0.0);
      jobMap[key] = (
        client: existing.client,
        mat: existing.mat,
        web: existing.web,
        issued: existing.issued,
        returned: existing.returned + item.rmtReturned,
      );
    }

    final List<RmJobReconciliationModel> reconciliations = [];
    jobMap.forEach((jobNo, val) {
      // Mock / Default Ok Qty for demonstration
      reconciliations.add(RmJobReconciliationModel(
        jobDocNo: jobNo,
        clientName: val.client,
        material: val.mat,
        gsmMicron: 80.0,
        webSizeMm: val.web,
        targetRmt: 2600.0,
        rmtIssued: val.issued,
        rmtReturned: val.returned,
        okQuantity: 21500.0,
        totalUps: 2,
        gearTeethZ: 75,
      ));
    });

    final filtered = reconciliations.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.jobDocNo.toLowerCase().contains(_searchQuery) ||
          r.clientName.toLowerCase().contains(_searchQuery) ||
          r.material.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('📈 Job-wise Raw Material Usage & Actual Wastage Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Job Doc No', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Material', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Net Used RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ok Label Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Ok Qty RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actual Wastage RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Wastage %', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((r) {
                return DataRow(cells: [
                  DataCell(Text(r.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                  DataCell(Text(r.clientName)),
                  DataCell(Text(r.material)),
                  DataCell(Text('${r.rmtIssued.toInt()} RMT')),
                  DataCell(Text('${r.rmtReturned.toInt()} RMT')),
                  DataCell(Text('${r.netRmtUsed.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${r.okQuantity.toInt()} pcs')),
                  DataCell(Text('${r.okQuantityRmt.toStringAsFixed(1)} RMT')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '${r.wastageRmt.toStringAsFixed(1)} RMT',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900),
                      ),
                    ),
                  ),
                  DataCell(Text('${r.wastagePercent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
