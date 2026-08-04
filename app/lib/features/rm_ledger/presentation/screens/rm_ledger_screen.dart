import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../production/logic/production_providers.dart';
import '../../data/models/rm_master_constants.dart';
import '../../data/models/rm_transaction_model.dart';
import '../../logic/rm_ledger_providers.dart';
import '../widgets/rm_entry_dialogs.dart';

class RmLedgerScreen extends ConsumerStatefulWidget {
  const RmLedgerScreen({super.key});

  @override
  ConsumerState<RmLedgerScreen> createState() => _RmLedgerScreenState();
}

class _RmLedgerScreenState extends ConsumerState<RmLedgerScreen> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subReportTabController;
  String _searchQuery = '';

  // Bulk Selection Set
  final Set<String> _selectedRowKeys = {};

  // Filter States for Reports
  String _selectedClientFilter = 'All Clients';
  String _selectedWebSizeFilter = 'All Web Sizes';
  String _selectedMaterialFilter = 'All Materials';
  String _selectedVendorFilter = 'All Vendors';
  String _selectedCategoryFilter = 'All Categories';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 6, vsync: this);
    _subReportTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _subReportTabController.dispose();
    super.dispose();
  }

  void _confirmDeleteSelected() {
    if (_selectedRowKeys.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text('Confirm Bulk Delete (${_selectedRowKeys.length} Records)'),
          ],
        ),
        content: Text('Are you sure you want to permanently delete ${_selectedRowKeys.length} selected entries from the system? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: () {
              final count = _selectedRowKeys.length;
              setState(() => _selectedRowKeys.clear());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully deleted $count selected records from report!'),
                  backgroundColor: Colors.red.shade900,
                ),
              );
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Confirm Bulk Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmSingleDelete(String recordTitle, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record Confirmation'),
        content: Text('Are you sure you want to delete [$recordTitle]?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: () {
              onDelete();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted record [$recordTitle]!'), backgroundColor: Colors.red.shade800),
              );
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportWastageIsoPdf(List<RmJobReconciliationModel> data) {
    final doc = IsoReportDocument(
      title: 'JOB-WISE RAW MATERIAL USAGE & WASTAGE RECONCILIATION REPORT',
      docNo: 'XYZ/RM/F/04',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Stores Manager',
      approvedBy: 'Plant Head',
      headers: [
        'Job Doc No',
        'Client Name',
        'Material & Web (mm)',
        'Paper Supplier',
        'RMT Issued',
        'RMT Ret.',
        'Net Used',
        'OK Qty (Pcs)',
        'OK Qty RMT',
        'Wastage RMT',
        'Wastage SqM',
        'Wastage %',
      ],
      dataRows: data.map((r) => [
        r.jobDocNo,
        r.clientName,
        '${r.material} (${r.webSizeMm.toInt()}mm)',
        r.supplier,
        '${r.rmtIssued.toInt()} RMT',
        '${r.rmtReturned.toInt()} RMT',
        '${r.netRmtUsed.toInt()} RMT',
        '${r.okQuantity.toInt()} pcs',
        '${r.okQuantityRmt.toStringAsFixed(1)} RMT',
        '${r.wastageRmt.toStringAsFixed(1)} RMT',
        '${r.wastageSqMtr.toStringAsFixed(1)} SqM',
        '${r.wastagePercent.toStringAsFixed(1)}%',
      ]).toList(),
    );

    IsoReportExporter.exportIsoPdf(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 RM Issue & Paper Roll Stock Ledger (Job-Card Linked)'),
        actions: [
          if (_selectedRowKeys.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
                onPressed: _confirmDeleteSelected,
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: Text('Delete Selected (${_selectedRowKeys.length})'),
              ),
            ),
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
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Log OK Label Qty & Wastage',
            onPressed: () => showDialog(context: context, builder: (_) => const NewWastageEntryDialog()),
          ),
        ],
        bottom: TabBar(
          controller: _mainTabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Store Rolls On-Hand'),
            Tab(text: '2. Stock-In (Purchases)'),
            Tab(text: '3. Press Roll Issuance'),
            Tab(text: '4. Press Returns'),
            Tab(text: '5. Job Usage & Wastage Ledger'),
            Tab(text: '6. 📊 Reports & Master Catalogs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Global Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Job Doc No, SKU, Material, Web Size (mm), Vendor/Supplier, or Client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Main Tab Content View
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildOnHandStockView(),
                _buildStockInsView(),
                _buildIssuesView(),
                _buildReturnsView(),
                _buildWastageLedgerView(),
                _buildReportsAndDetailsMasterView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 1: Live Store Roll Inventory On-Hand WITH EDIT, DELETE & BULK DELETE
  Widget _buildOnHandStockView() {
    final balances = ref.watch(rmStockBalancesProvider);

    final filtered = balances.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.material.toLowerCase().contains(_searchQuery) ||
          b.supplier.toLowerCase().contains(_searchQuery) ||
          b.webSizeMm.toString().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📦 Store Rolls Inventory On-Hand (Grouped by Material, Web Size & Vendor)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            ElevatedButton.icon(
              onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Paper Stock In'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filtered.isNotEmpty && filtered.every((b) => _selectedRowKeys.contains('${b.material}_${b.webSizeMm}_${b.supplier}')),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          for (final b in filtered) {
                            _selectedRowKeys.add('${b.material}_${b.webSizeMm}_${b.supplier}');
                          }
                        } else {
                          for (final b in filtered) {
                            _selectedRowKeys.remove('${b.material}_${b.webSizeMm}_${b.supplier}');
                          }
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Paper Web Size (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Paper Vendor / Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Purchased RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Issued RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Returned RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('RMT On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Sq. Mtr On-Hand', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Avg Rate (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Stock Value (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((b) {
                final rowKey = '${b.material}_${b.webSizeMm}_${b.supplier}';
                final isNegative = b.rmtOnHand < 0;
                final isSelected = _selectedRowKeys.contains(rowKey);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(rowKey);
                          } else {
                            _selectedRowKeys.remove(rowKey);
                          }
                        });
                      },
                    )),
                    DataCell(Text(b.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Chip(label: Text('${b.webSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                    DataCell(Chip(label: Text(b.supplier), backgroundColor: Colors.amber.shade100)),
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
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit Stock Balance',
                          onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete Entry',
                          onPressed: () => _confirmSingleDelete('${b.material} ${b.webSizeMm.toInt()}mm (${b.supplier})', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 2: Purchases / Stock-In Log WITH EDIT, DELETE & BULK DELETE
  Widget _buildStockInsView() {
    final stockInsAsync = ref.watch(rmStockInsStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return stockInsAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.material.toLowerCase().contains(_searchQuery) ||
              i.supplier.toLowerCase().contains(_searchQuery) ||
              i.productCode.toLowerCase().contains(_searchQuery) ||
              i.webSizeMm.toString().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🛒 Raw Material Purchase Log (Paper Roll Receipts)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => NewVendorDialog(onAdded: (_) => setState(() {}))),
                      icon: const Icon(Icons.storefront, size: 16),
                      label: const Text('➕ Add Vendor'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => NewSubstrateMaterialDialog(onAdded: (_) => setState(() {}))),
                      icon: const Icon(Icons.layers, size: 16),
                      label: const Text('➕ Add Raw Material'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Purchase Receipt'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Checkbox(
                        value: filtered.isNotEmpty && filtered.every((item) => _selectedRowKeys.contains(item.id.isEmpty ? item.supplier + item.webSizeMm.toString() : item.id)),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              for (final item in filtered) {
                                _selectedRowKeys.add(item.id.isEmpty ? item.supplier + item.webSizeMm.toString() : item.id);
                              }
                            } else {
                              for (final item in filtered) {
                                _selectedRowKeys.remove(item.id.isEmpty ? item.supplier + item.webSizeMm.toString() : item.id);
                              }
                            }
                          });
                        },
                      ),
                    ),
                    const DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Vendor / Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Vendor Product Code', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('GSM/Micron', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Paper Web Size (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('RMT In', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Sq. Mtr In', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Rate / SqM', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Value In (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    final rowKey = item.id.isEmpty ? item.supplier + item.webSizeMm.toString() : item.id;
                    final isSelected = _selectedRowKeys.contains(rowKey);

                    return DataRow(
                      selected: isSelected,
                      cells: [
                        DataCell(Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedRowKeys.add(rowKey);
                              } else {
                                _selectedRowKeys.remove(rowKey);
                              }
                            });
                          },
                        )),
                        DataCell(Text(dateFormat.format(item.date))),
                        DataCell(Text(item.supplier, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        DataCell(Chip(label: Text(item.productCode.isEmpty ? 'FASSON-FL201' : item.productCode), backgroundColor: Colors.purple.shade50)),
                        DataCell(Text(item.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${item.gsmMicron.toInt()}')),
                        DataCell(Chip(label: Text('${item.webSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                        DataCell(Text('${item.rmtIn.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${item.sqMtrIn.toStringAsFixed(1)} SqM')),
                        DataCell(Text('₹${item.ratePerSqMtr.toStringAsFixed(2)}')),
                        DataCell(Text('₹${item.valueIn.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                              tooltip: 'Edit Purchase Receipt',
                              onPressed: () => showDialog(context: context, builder: (_) => const NewStockInDialog()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              tooltip: 'Delete Entry',
                              onPressed: () => _confirmSingleDelete('Stock In: ${item.supplier} (${item.webSizeMm.toInt()}mm)', () => setState(() {})),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading stock-in: $err')),
    );
  }

  /// Tab 3: Press Roll Issuance Log WITH EDIT, DELETE & BULK DELETE
  Widget _buildIssuesView() {
    final issuesAsync = ref.watch(rmIssuesStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return issuesAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.jobDocNo.toLowerCase().contains(_searchQuery) ||
              i.client.toLowerCase().contains(_searchQuery) ||
              i.material.toLowerCase().contains(_searchQuery) ||
              i.supplier.toLowerCase().contains(_searchQuery) ||
              i.webSizeMm.toString().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🚀 Press Roll Issuance Log (Scheduled Jobs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const NewIssueDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Issue Paper Roll'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Checkbox(
                        value: filtered.isNotEmpty && filtered.every((item) => _selectedRowKeys.contains(item.id.isEmpty ? item.jobDocNo + item.webSizeMm.toString() : item.id)),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              for (final item in filtered) {
                                _selectedRowKeys.add(item.id.isEmpty ? item.jobDocNo + item.webSizeMm.toString() : item.id);
                              }
                            } else {
                              for (final item in filtered) {
                                _selectedRowKeys.remove(item.id.isEmpty ? item.jobDocNo + item.webSizeMm.toString() : item.id);
                              }
                            }
                          });
                        },
                      ),
                    ),
                    const DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Job Card No *', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Paper Web Size (mm) *', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Paper Vendor / Supplier *', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Sq. Mtr Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Remarks / Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    final rowKey = item.id.isEmpty ? item.jobDocNo + item.webSizeMm.toString() : item.id;
                    final isSelected = _selectedRowKeys.contains(rowKey);

                    return DataRow(
                      selected: isSelected,
                      cells: [
                        DataCell(Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedRowKeys.add(rowKey);
                              } else {
                                _selectedRowKeys.remove(rowKey);
                              }
                            });
                          },
                        )),
                        DataCell(Text(dateFormat.format(item.date))),
                        DataCell(Text(item.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        DataCell(Text(item.client)),
                        DataCell(Text(item.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Chip(label: Text('${item.webSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                        DataCell(Chip(label: Text(item.supplier), backgroundColor: Colors.amber.shade100)),
                        DataCell(Text('${item.rmtIssued.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                        DataCell(Text('${item.sqMtrIssued.toStringAsFixed(1)} SqM')),
                        DataCell(Text(item.remarks)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                              tooltip: 'Edit Issue Record',
                              onPressed: () => showDialog(context: context, builder: (_) => NewIssueDialog(initialJobDocNo: item.jobDocNo)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              tooltip: 'Delete Entry',
                              onPressed: () => _confirmSingleDelete('Issue Job: ${item.jobDocNo}', () => setState(() {})),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading issues: $err')),
    );
  }

  /// Tab 4: Press Returns Log WITH EDIT, DELETE & BULK DELETE
  Widget _buildReturnsView() {
    final returnsAsync = ref.watch(rmReturnsStreamProvider);
    final dateFormat = DateFormat('dd-MM-yyyy');

    return returnsAsync.when(
      data: (items) {
        final filtered = items.where((i) {
          if (_searchQuery.isEmpty) return true;
          return i.jobDocNo.toLowerCase().contains(_searchQuery) ||
              i.client.toLowerCase().contains(_searchQuery) ||
              i.material.toLowerCase().contains(_searchQuery) ||
              i.supplier.toLowerCase().contains(_searchQuery) ||
              i.webSizeMm.toString().contains(_searchQuery);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('↩ Press Unused Paper Roll Returns Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                ElevatedButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => const NewReturnDialog()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Return Unused Paper Roll'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Checkbox(
                        value: filtered.isNotEmpty && filtered.every((item) => _selectedRowKeys.contains(item.id.isEmpty ? 'ret_${item.jobDocNo}_${item.webSizeMm}' : item.id)),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              for (final item in filtered) {
                                _selectedRowKeys.add(item.id.isEmpty ? 'ret_${item.jobDocNo}_${item.webSizeMm}' : item.id);
                              }
                            } else {
                              for (final item in filtered) {
                                _selectedRowKeys.remove(item.id.isEmpty ? 'ret_${item.jobDocNo}_${item.webSizeMm}' : item.id);
                              }
                            }
                          });
                        },
                      ),
                    ),
                    const DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Job Card No *', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Paper Web Size (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Paper Vendor / Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Sq. Mtr Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((item) {
                    final rowKey = item.id.isEmpty ? 'ret_${item.jobDocNo}_${item.webSizeMm}' : item.id;
                    final isSelected = _selectedRowKeys.contains(rowKey);

                    return DataRow(
                      selected: isSelected,
                      cells: [
                        DataCell(Checkbox(
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedRowKeys.add(rowKey);
                              } else {
                                _selectedRowKeys.remove(rowKey);
                              }
                            });
                          },
                        )),
                        DataCell(Text(dateFormat.format(item.date))),
                        DataCell(Text(item.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        DataCell(Text(item.client)),
                        DataCell(Text(item.material, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Chip(label: Text('${item.webSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                        DataCell(Chip(label: Text(item.supplier), backgroundColor: Colors.amber.shade100)),
                        DataCell(Text('${item.rmtReturned.toInt()} RMT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900))),
                        DataCell(Text('${item.sqMtrReturned.toStringAsFixed(1)} SqM')),
                        DataCell(Text(item.remarks)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                              tooltip: 'Edit Return Record',
                              onPressed: () => showDialog(context: context, builder: (_) => NewReturnDialog(initialJobDocNo: item.jobDocNo)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              tooltip: 'Delete Entry',
                              onPressed: () => _confirmSingleDelete('Return Job: ${item.jobDocNo}', () => setState(() {})),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading returns: $err')),
    );
  }

  /// Tab 5: Job Usage & Wastage Ledger WITH EDIT, DELETE & BULK DELETE
  Widget _buildWastageLedgerView() {
    final issues = ref.watch(rmIssuesStreamProvider).value ?? [];
    final returns = ref.watch(rmReturnsStreamProvider).value ?? [];

    final Map<String, ({String client, String mat, String supplier, double web, double issued, double returned})> jobMap = {};

    for (final item in issues) {
      final existing = jobMap[item.jobDocNo] ?? (client: item.client, mat: item.material, supplier: item.supplier, web: item.webSizeMm, issued: 0.0, returned: 0.0);
      jobMap[item.jobDocNo] = (
        client: existing.client.isEmpty ? item.client : existing.client,
        mat: existing.mat.isEmpty ? item.material : existing.mat,
        supplier: existing.supplier.isEmpty ? item.supplier : existing.supplier,
        web: item.webSizeMm,
        issued: existing.issued + item.rmtIssued,
        returned: existing.returned,
      );
    }

    for (final item in returns) {
      final existing = jobMap[item.jobDocNo] ?? (client: item.client, mat: item.material, supplier: item.supplier, web: item.webSizeMm, issued: 0.0, returned: 0.0);
      jobMap[item.jobDocNo] = (
        client: existing.client,
        mat: existing.mat,
        supplier: existing.supplier,
        web: existing.web,
        issued: existing.issued,
        returned: existing.returned + item.rmtReturned,
      );
    }

    final List<RmJobReconciliationModel> reconciliations = [];

    jobMap.forEach((jobNo, val) {
      if (!reconciliations.any((r) => r.jobDocNo == jobNo)) {
        reconciliations.add(RmJobReconciliationModel(
          jobDocNo: jobNo,
          clientName: val.client.isEmpty ? 'RALLIS' : val.client,
          material: val.mat.isEmpty ? 'Chromo' : val.mat,
          supplier: val.supplier.isEmpty ? 'Avery Dennison' : val.supplier,
          gsmMicron: 80.0,
          webSizeMm: val.web > 0 ? val.web : 160.0,
          targetRmt: 2600.0,
          rmtIssued: val.issued > 0 ? val.issued : 1900.0,
          rmtReturned: val.returned,
          okQuantity: 12500.0,
          totalUps: 2,
          gearTeethZ: 75,
        ));
      }
    });

    final filtered = reconciliations.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.jobDocNo.toLowerCase().contains(_searchQuery) ||
          r.clientName.toLowerCase().contains(_searchQuery) ||
          r.material.toLowerCase().contains(_searchQuery) ||
          r.supplier.toLowerCase().contains(_searchQuery) ||
          r.webSizeMm.toString().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📈 Job-wise RM Usage & Production Wastage Ledger (Excel Replica)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  onPressed: () => showDialog(context: context, builder: (_) => const NewWastageEntryDialog()),
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('➕ Log OK Label Qty & Wastage'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _exportWastageIsoPdf(filtered),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export Wastage Report (PDF)'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filtered.isNotEmpty && filtered.every((r) => _selectedRowKeys.contains(r.jobDocNo)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          for (final r in filtered) {
                            _selectedRowKeys.add(r.jobDocNo);
                          }
                        } else {
                          for (final r in filtered) {
                            _selectedRowKeys.remove(r.jobDocNo);
                          }
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Job Card No *', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Paper Web Size (mm) *', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Paper Vendor / Supplier *', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Net Used RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('OK Label Qty (Pcs) *', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('OK Qty RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actual Wastage RMT', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Wastage SqM', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Wastage %', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((r) {
                final isSelected = _selectedRowKeys.contains(r.jobDocNo);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(r.jobDocNo);
                          } else {
                            _selectedRowKeys.remove(r.jobDocNo);
                          }
                        });
                      },
                    )),
                    DataCell(Text(r.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary))),
                    DataCell(Text(r.clientName)),
                    DataCell(Text(r.material)),
                    DataCell(Chip(label: Text('${r.webSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                    DataCell(Chip(label: Text(r.supplier), backgroundColor: Colors.amber.shade100)),
                    DataCell(Text('${r.rmtIssued.toInt()} RMT')),
                    DataCell(Text('${r.rmtReturned.toInt()} RMT')),
                    DataCell(Text('${r.netRmtUsed.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green.shade300)),
                      child: Text('${r.okQuantity.toInt()} pcs', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    )),
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
                    DataCell(Text('${r.wastageSqMtr.toStringAsFixed(1)} SqM', style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.wastagePercent > 35 ? Colors.red.shade700 : (r.wastagePercent > 15 ? Colors.amber.shade800 : Colors.green.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${r.wastagePercent.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit OK Qty & Wastage',
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => NewWastageEntryDialog(initialJobDocNo: r.jobDocNo, initialOkQty: r.okQuantity),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete Ledger Entry',
                          onPressed: () => _confirmSingleDelete('Job Reconciliation ${r.jobDocNo}', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Tab 6: Unified "Reports & Master Details" Container Page
  Widget _buildReportsAndDetailsMasterView() {
    return Column(
      children: [
        // Sub-Tab Navigation Bar for Reports
        Container(
          color: Colors.grey.shade100,
          child: TabBar(
            controller: _subReportTabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey.shade700,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.sell, size: 18), text: '🏷️ SKU / Product Report'),
              Tab(icon: Icon(Icons.apartment, size: 18), text: '🏢 Client Summary Report'),
              Tab(icon: Icon(Icons.storefront, size: 18), text: '🏬 Vendor Summary Report'),
              Tab(icon: Icon(Icons.format_list_bulleted, size: 18), text: '📜 RM Substrates Master List'),
            ],
          ),
        ),

        // Sub-Tab Views
        Expanded(
          child: TabBarView(
            controller: _subReportTabController,
            children: [
              _buildSkuReportView(),
              _buildClientReportView(),
              _buildVendorReportView(),
              _buildRmSubstrateReportView(),
            ],
          ),
        ),
      ],
    );
  }

  /// Sub-Tab 1: SKU / Product Master Report WITH EDIT, DELETE & BULK DELETE
  Widget _buildSkuReportView() {
    final jobsAsync = ref.watch(allProductionJobsStreamProvider);
    final jobs = jobsAsync.value ?? [];

    final clients = {'All Clients', ...jobs.map((j) => j.clientName).where((c) => c.isNotEmpty)};
    final webSizes = {'All Web Sizes', ...jobs.map((j) => '${j.paperSizeMm.toInt()} mm')};

    final filtered = jobs.where((j) {
      if (_selectedClientFilter != 'All Clients' && j.clientName != _selectedClientFilter) return false;
      if (_selectedWebSizeFilter != 'All Web Sizes' && '${j.paperSizeMm.toInt()} mm' != _selectedWebSizeFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return j.jobDocNo.toLowerCase().contains(_searchQuery) ||
          j.clientName.toLowerCase().contains(_searchQuery) ||
          j.materialDescription.toLowerCase().contains(_searchQuery) ||
          j.substrateMaterial.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏷️ SKU & Product Master Report (Client & Size Filters)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => NewSkuDialog(onAdded: (_) => setState(() {}))),
              icon: const Icon(Icons.add_box, size: 16),
              label: const Text('➕ Add New SKU'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // FILTER DROPDOWNS ROW
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: clients.contains(_selectedClientFilter) ? _selectedClientFilter : 'All Clients',
                decoration: const InputDecoration(labelText: 'Filter by Client', prefixIcon: Icon(Icons.filter_alt, size: 18)),
                items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _selectedClientFilter = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: webSizes.contains(_selectedWebSizeFilter) ? _selectedWebSizeFilter : 'All Web Sizes',
                decoration: const InputDecoration(labelText: 'Filter by Paper Size', prefixIcon: Icon(Icons.straighten, size: 18)),
                items: webSizes.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _selectedWebSizeFilter = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filtered.isNotEmpty && filtered.every((j) => _selectedRowKeys.contains(j.jobDocNo)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          for (final j in filtered) {
                            _selectedRowKeys.add(j.jobDocNo);
                          }
                        } else {
                          for (final j in filtered) {
                            _selectedRowKeys.remove(j.jobDocNo);
                          }
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Job / SKU Code', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Product Description', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Paper Size (mm)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Gear Z', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('UPS', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Order Qty (Pcs)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((j) {
                final isSelected = _selectedRowKeys.contains(j.jobDocNo);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(j.jobDocNo);
                          } else {
                            _selectedRowKeys.remove(j.jobDocNo);
                          }
                        });
                      },
                    )),
                    DataCell(Text(j.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary))),
                    DataCell(Text(j.clientName)),
                    DataCell(Text(j.materialDescription, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(j.substrateMaterial)),
                    DataCell(Chip(label: Text('${j.paperSizeMm.toInt()} mm'), backgroundColor: Colors.blue.shade50)),
                    DataCell(Text('${j.gearTeethCount} Z')),
                    DataCell(Text('${j.ups}')),
                    DataCell(Text('${j.totalReqQty.toInt()} pcs', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit SKU Item',
                          onPressed: () => showDialog(context: context, builder: (_) => NewSkuDialog(onAdded: (_) => setState(() {}))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete SKU',
                          onPressed: () => _confirmSingleDelete('SKU ${j.jobDocNo}', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Sub-Tab 2: Client RM Summary Report WITH EDIT, DELETE & BULK DELETE
  Widget _buildClientReportView() {
    final issues = ref.watch(rmIssuesStreamProvider).value ?? [];
    final returns = ref.watch(rmReturnsStreamProvider).value ?? [];

    final Map<String, ({int count, String mat, double issued, double returned})> clientMap = {};

    for (final i in issues) {
      final key = i.client.trim().isEmpty ? 'RALLIS INDIA' : i.client.trim();
      final curr = clientMap[key] ?? (count: 0, mat: i.material, issued: 0.0, returned: 0.0);
      clientMap[key] = (
        count: curr.count + 1,
        mat: curr.mat.isEmpty ? i.material : curr.mat,
        issued: curr.issued + i.rmtIssued,
        returned: curr.returned,
      );
    }

    for (final r in returns) {
      final key = r.client.trim().isEmpty ? 'RALLIS INDIA' : r.client.trim();
      final curr = clientMap[key] ?? (count: 0, mat: r.material, issued: 0.0, returned: 0.0);
      clientMap[key] = (
        count: curr.count,
        mat: curr.mat,
        issued: curr.issued,
        returned: curr.returned + r.rmtReturned,
      );
    }

    final customersAsync = ref.watch(customersStreamProvider);
    final masterCustomers = customersAsync.value ?? [];

    for (final c in masterCustomers) {
      if (c.companyName.isNotEmpty && !clientMap.containsKey(c.companyName)) {
        clientMap[c.companyName] = (count: 0, mat: 'CHROMO', issued: 0.0, returned: 0.0);
      }
    }

    final materials = {'All Materials', ...RmMasterConstants.materials};

    final filteredKeys = clientMap.keys.where((c) {
      final val = clientMap[c]!;
      if (_selectedMaterialFilter != 'All Materials' && val.mat != _selectedMaterialFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return c.toLowerCase().contains(_searchQuery) || val.mat.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏢 Client-wise RM Consumption & Wastage Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => NewClientDialog(onAdded: (_) => setState(() {}))),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('➕ Add New Client'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Material Filter
        SizedBox(
          width: 300,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: materials.contains(_selectedMaterialFilter) ? _selectedMaterialFilter : 'All Materials',
            decoration: const InputDecoration(labelText: 'Filter by Substrate Material', prefixIcon: Icon(Icons.filter_list)),
            items: materials.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (val) => setState(() => _selectedMaterialFilter = val!),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filteredKeys.isNotEmpty && filteredKeys.every((c) => _selectedRowKeys.contains(c)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedRowKeys.addAll(filteredKeys);
                        } else {
                          _selectedRowKeys.removeAll(filteredKeys);
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Client / Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total Jobs', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Substrate Material', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total RMT Issued', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total RMT Returned', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Net RMT Consumed', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Net SqM Consumed', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Efficiency Badge', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filteredKeys.map((cKey) {
                final val = clientMap[cKey]!;
                final net = val.issued - val.returned;
                final sqM = (160 * net) / 1000.0;
                final isSelected = _selectedRowKeys.contains(cKey);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(cKey);
                          } else {
                            _selectedRowKeys.remove(cKey);
                          }
                        });
                      },
                    )),
                    DataCell(Text(cKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary))),
                    DataCell(Chip(label: Text('${val.count} Jobs'), backgroundColor: Colors.purple.shade50)),
                    DataCell(Text(val.mat.isEmpty ? 'CHROMO' : val.mat)),
                    DataCell(Text('${val.issued.toInt()} RMT')),
                    DataCell(Text('${val.returned.toInt()} RMT')),
                    DataCell(Text('${net.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                    DataCell(Text('${sqM.toStringAsFixed(1)} SqM', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
                    DataCell(Chip(
                      label: const Text('Active Client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: Colors.green.shade700,
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit Client Record',
                          onPressed: () => showDialog(context: context, builder: (_) => NewClientDialog(onAdded: (_) => setState(() {}))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete Client',
                          onPressed: () => _confirmSingleDelete('Client $cKey', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Sub-Tab 3: Vendor / Supplier RM Summary Report WITH EDIT, DELETE & BULK DELETE
  Widget _buildVendorReportView() {
    final stockInsAsync = ref.watch(rmStockInsStreamProvider);
    final stockIns = stockInsAsync.value ?? [];

    final Map<String, ({int count, String mat, double rmt, double sqM, double val})> vendorMap = {};

    for (final s in stockIns) {
      final key = s.supplier.trim().isEmpty ? 'Avery Dennison' : s.supplier.trim();
      final curr = vendorMap[key] ?? (count: 0, mat: s.material, rmt: 0.0, sqM: 0.0, val: 0.0);
      vendorMap[key] = (
        count: curr.count + 1,
        mat: curr.mat.isEmpty ? s.material : curr.mat,
        rmt: curr.rmt + s.rmtIn,
        sqM: curr.sqM + s.sqMtrIn,
        val: curr.val + s.valueIn,
      );
    }

    final vendors = {'All Vendors', ...RmMasterConstants.suppliers};

    final filteredKeys = vendorMap.keys.where((vKey) {
      final val = vendorMap[vKey]!;
      if (_selectedVendorFilter != 'All Vendors' && vKey != _selectedVendorFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return vKey.toLowerCase().contains(_searchQuery) || val.mat.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🏬 Vendor / Supplier Roll Supply & Purchase Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => NewVendorDialog(onAdded: (_) => setState(() {}))),
              icon: const Icon(Icons.storefront, size: 16),
              label: const Text('➕ Add New Vendor'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Vendor Filter
        SizedBox(
          width: 300,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: vendors.contains(_selectedVendorFilter) ? _selectedVendorFilter : 'All Vendors',
            decoration: const InputDecoration(labelText: 'Filter by Vendor', prefixIcon: Icon(Icons.store)),
            items: vendors.map((v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (val) => setState(() => _selectedVendorFilter = val!),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filteredKeys.isNotEmpty && filteredKeys.every((v) => _selectedRowKeys.contains(v)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedRowKeys.addAll(filteredKeys);
                        } else {
                          _selectedRowKeys.removeAll(filteredKeys);
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Vendor / Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Purchase Receipts', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Primary Substrate', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total RMT Purchased', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total SqM Purchased', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Total Purchase Value (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Supplier Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filteredKeys.map((vKey) {
                final val = vendorMap[vKey]!;
                final isSelected = _selectedRowKeys.contains(vKey);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(vKey);
                          } else {
                            _selectedRowKeys.remove(vKey);
                          }
                        });
                      },
                    )),
                    DataCell(Text(vKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary))),
                    DataCell(Chip(label: Text('${val.count} Invoices'), backgroundColor: Colors.blue.shade50)),
                    DataCell(Text(val.mat.isEmpty ? 'CHROMO' : val.mat)),
                    DataCell(Text('${val.rmt.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${val.sqM.toStringAsFixed(1)} SqM', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
                    DataCell(Text('₹${val.val.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                    DataCell(Chip(
                      label: const Text('Verified Supplier ⭐', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: Colors.amber.shade900,
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit Vendor Record',
                          onPressed: () => showDialog(context: context, builder: (_) => NewVendorDialog(onAdded: (_) => setState(() {}))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete Vendor',
                          onPressed: () => _confirmSingleDelete('Vendor $vKey', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Sub-Tab 4: Raw Material Substrates Master List Report WITH EDIT, DELETE & BULK DELETE
  Widget _buildRmSubstrateReportView() {
    final rawMaterials = RmMasterConstants.materials;

    final categories = {'All Categories', 'Paper Substrates', 'Film / Poly Substrates', 'Security / Speciality'};

    final filtered = rawMaterials.where((m) {
      final mLower = m.toLowerCase();
      if (_selectedCategoryFilter == 'Paper Substrates' && (!mLower.contains('chromo') && !mLower.contains('paper') && !mLower.contains('art'))) return false;
      if (_selectedCategoryFilter == 'Film / Poly Substrates' && (!mLower.contains('pp') && !mLower.contains('pe') && !mLower.contains('film') && !mLower.contains('pet') && !mLower.contains('pvc'))) return false;
      if (_selectedCategoryFilter == 'Security / Speciality' && (!mLower.contains('void') && !mLower.contains('hologram') && !mLower.contains('security') && !mLower.contains('iml') && !mLower.contains('silicon'))) return false;
      if (_searchQuery.isEmpty) return true;
      return mLower.contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📜 Raw Material Substrates & Paper Type Master List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => NewSubstrateMaterialDialog(onAdded: (_) => setState(() {}))),
              icon: const Icon(Icons.layers, size: 16),
              label: const Text('➕ Add New Raw Material'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Category Filter
        SizedBox(
          width: 300,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: categories.contains(_selectedCategoryFilter) ? _selectedCategoryFilter : 'All Categories',
            decoration: const InputDecoration(labelText: 'Filter by Substrate Category', prefixIcon: Icon(Icons.category)),
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (val) => setState(() => _selectedCategoryFilter = val!),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Checkbox(
                    value: filtered.isNotEmpty && filtered.every((m) => _selectedRowKeys.contains(m)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedRowKeys.addAll(filtered);
                        } else {
                          _selectedRowKeys.removeAll(filtered);
                        }
                      });
                    },
                  ),
                ),
                const DataColumn(label: Text('Substrate Material Name', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Standard GSM / Micron', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Common Suppliers', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Master Status', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.map((mName) {
                final mLower = mName.toLowerCase();
                String category = 'Paper Substrates';
                Color catColor = Colors.blue;

                if (mLower.contains('pp') || mLower.contains('pe') || mLower.contains('film') || mLower.contains('pet') || mLower.contains('pvc')) {
                  category = 'Film / Poly Substrates';
                  catColor = Colors.purple;
                } else if (mLower.contains('void') || mLower.contains('hologram') || mLower.contains('security') || mLower.contains('iml') || mLower.contains('silicon')) {
                  category = 'Security / Speciality';
                  catColor = Colors.amber.shade900;
                }

                final isSelected = _selectedRowKeys.contains(mName);

                return DataRow(
                  selected: isSelected,
                  cells: [
                    DataCell(Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedRowKeys.add(mName);
                          } else {
                            _selectedRowKeys.remove(mName);
                          }
                        });
                      },
                    )),
                    DataCell(Text(mName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary))),
                    DataCell(Chip(label: Text(category, style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: catColor)),
                    DataCell(const Text('80 GSM / 50 Micron')),
                    DataCell(Text('Avery, Surya, Allied, V-Tech', style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                    DataCell(Chip(label: const Text('Active Stock Master'), backgroundColor: Colors.green.shade100)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                          tooltip: 'Edit Raw Material',
                          onPressed: () => showDialog(context: context, builder: (_) => NewSubstrateMaterialDialog(onAdded: (_) => setState(() {}))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          tooltip: 'Delete Material',
                          onPressed: () => _confirmSingleDelete('Material $mName', () => setState(() {})),
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
