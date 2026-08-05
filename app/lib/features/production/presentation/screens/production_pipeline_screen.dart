import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/production_job_model.dart';
import '../../logic/production_providers.dart';
import '../dialogs/schedule_job_dialog.dart';
import '../widgets/new_production_job_dialog.dart';

class ProductionPipelineScreen extends ConsumerStatefulWidget {
  const ProductionPipelineScreen({super.key});

  @override
  ConsumerState<ProductionPipelineScreen> createState() => _ProductionPipelineScreenState();
}

class _ProductionPipelineScreenState extends ConsumerState<ProductionPipelineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedPendingFilter; // null = All, or PendingSubStatus values
  DateTime? _selectedScheduleDateFilter = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Checkbox Selection Set for Batch Move / Status Updates
  final Set<String> _selectedJobIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _selectedJobIds.clear(); // Clear selections when switching tabs
        });
      }
    });
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
        title: const Text('🏭 Production Tracking & Status Control Center'),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            onPressed: () => _openNewJobDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New Order Entry'),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '1. Pending Queue (Pre-Press)'),
            Tab(text: '2. Printing Schedule'),
            Tab(text: '3. Postpress (Slitting/Die)'),
            Tab(text: '4. Dispatched Orders'),
            Tab(text: '5. FG Stock Inventory'),
          ],
        ),
      ),
      floatingActionButton: _selectedJobIds.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _openNewJobDialog(context),
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Order Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null, // Hide FAB when batch selection bar is visible to prevent overlap
      body: Stack(
        children: [
          Column(
            children: [
              // Search & Pending Sub-Status Filter Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by Job Doc No, Client Name, PO No, or Material...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          ),
                        ),
                        if (_selectedJobIds.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedJobIds.clear()),
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: Text('Clear (${_selectedJobIds.length})'),
                          ),
                        ],
                      ],
                    ),

                    // Filter chips specifically for Tab 0 (Pending Stage)
                    if (_tabController.index == 0) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              selected: _selectedPendingFilter == null,
                              label: const Text('All Pending'),
                              onSelected: (_) => setState(() => _selectedPendingFilter = null),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              selected: _selectedPendingFilter == PendingSubStatus.newPending,
                              label: const Text('🔵 New Pending'),
                              selectedColor: Colors.blue.shade100,
                              onSelected: (_) => setState(() => _selectedPendingFilter = PendingSubStatus.newPending),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              selected: _selectedPendingFilter == PendingSubStatus.underApproval,
                              label: const Text('🔴 Under Approval'),
                              selectedColor: Colors.red.shade100,
                              onSelected: (_) => setState(() => _selectedPendingFilter = PendingSubStatus.underApproval),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              selected: _selectedPendingFilter == PendingSubStatus.approvalReceived,
                              label: const Text('🟢 Approval Recd'),
                              selectedColor: Colors.green.shade100,
                              onSelected: (_) => setState(() => _selectedPendingFilter = PendingSubStatus.approvalReceived),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              selected: _selectedPendingFilter == PendingSubStatus.underPlate,
                              label: const Text('🟡 Under Plate'),
                              selectedColor: Colors.amber.shade100,
                              onSelected: (_) => setState(() => _selectedPendingFilter = PendingSubStatus.underPlate),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              selected: _selectedPendingFilter == PendingSubStatus.holdJob,
                              label: const Text('⛔ Hold Job'),
                              selectedColor: Colors.purple.shade100,
                              onSelected: (_) => setState(() => _selectedPendingFilter = PendingSubStatus.holdJob),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStageView(ProductionStage.pending, pendingSubStatus: _selectedPendingFilter),
                    _buildStageView(ProductionStage.schedule),
                    _buildStageView(ProductionStage.postpress),
                    _buildStageView(ProductionStage.dispatched),
                    _buildFgStockView(),
                  ],
                ),
              ),
            ],
          ),

          // BATCH SELECTION FLOATING ACTION BAR (ZERO OVERLAP WITH FAB)
          if (_selectedJobIds.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Card(
                elevation: 8,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                            child: Text('${_selectedJobIds.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          const Text('Jobs Selected for Batch Status Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (_tabController.index == 0) ...[
                            ElevatedButton.icon(
                              onPressed: () => _applyBatchSubStatus(PendingSubStatus.underApproval),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                              icon: const Icon(Icons.send, size: 14),
                              label: const Text('Send Approval'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _applyBatchSubStatus(PendingSubStatus.approvalReceived),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                              icon: const Icon(Icons.check_circle, size: 14),
                              label: const Text('Mark Approved'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _applyBatchSubStatus(PendingSubStatus.underPlate),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                              icon: const Icon(Icons.layers, size: 14),
                              label: const Text('Order Plate'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _applyBatchStage(ProductionStage.schedule),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                              icon: const Icon(Icons.arrow_forward, size: 14),
                              label: const Text('Move to Schedule ➔'),
                            ),
                          ] else if (_tabController.index == 1) ...[
                            ElevatedButton.icon(
                              onPressed: () => _applyBatchStage(ProductionStage.postpress),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                              icon: const Icon(Icons.precision_manufacturing, size: 14),
                              label: const Text('Move to Postpress ➔'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageView(String stage, {String? pendingSubStatus}) {
    final jobsAsync = ref.watch(productionJobsStreamProvider((stage: stage, subStatus: pendingSubStatus)));

    return jobsAsync.when(
      data: (jobs) {
        final filtered = jobs.where((j) {
          if (_searchQuery.isEmpty) return true;
          return j.jobDocNo.toLowerCase().contains(_searchQuery) ||
              j.clientName.toLowerCase().contains(_searchQuery) ||
              j.poNumber.toLowerCase().contains(_searchQuery) ||
              j.materialDescription.toLowerCase().contains(_searchQuery);
        }).toList();

        if (stage == ProductionStage.schedule) {
          return _buildPrintingScheduleView(filtered);
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('No production jobs in [$stage] stage.', style: const TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        final isAllSelected = filtered.every((j) => _selectedJobIds.contains(j.id));

        return Column(
          children: [
            // Select All Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: isAllSelected && filtered.isNotEmpty,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedJobIds.addAll(filtered.map((j) => j.id));
                        } else {
                          for (final j in filtered) {
                            _selectedJobIds.remove(j.id);
                          }
                        }
                      });
                    },
                  ),
                  Text('Select All (${filtered.length} Jobs in view)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final job = filtered[index];
                  final isSelected = _selectedJobIds.contains(job.id);
                  return _JobCard(
                    job: job,
                    isSelected: isSelected,
                    onToggleSelect: () {
                      setState(() {
                        if (isSelected) {
                          _selectedJobIds.remove(job.id);
                        } else {
                          _selectedJobIds.add(job.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading production jobs: $err')),
    );
  }

  Widget _buildPrintingScheduleView(List<ProductionJobModel> allJobs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<DateTime> weekDates = List.generate(7, (i) => today.add(Duration(days: i)));

    bool isSameDay(DateTime? a, DateTime b) {
      if (a == null) return false;
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    final filteredJobs = allJobs.where((j) {
      if (_selectedScheduleDateFilter == null) return true;
      if (j.scheduledDate == null) {
        return isSameDay(_selectedScheduleDateFilter, today);
      }
      return isSameDay(j.scheduledDate, _selectedScheduleDateFilter!);
    }).toList();

    return Column(
      children: [
        // 7-DAY HORIZONTAL WEEKLY PLANNING STRIP
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withAlpha(120),
            border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '📅 1-Week Printing Execution Plan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedScheduleDateFilter = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear_all,
                      size: 16,
                      color: _selectedScheduleDateFilter == null ? AppTheme.primary : Colors.grey.shade700,
                    ),
                    label: Text(
                      _selectedScheduleDateFilter == null ? '✓ All Dates View' : 'Show All Dates',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _selectedScheduleDateFilter == null ? FontWeight.bold : FontWeight.normal,
                        color: _selectedScheduleDateFilter == null ? AppTheme.primary : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weekDates.map((date) {
                    final isSel = _selectedScheduleDateFilter != null && isSameDay(_selectedScheduleDateFilter, date);
                    final isTodayDate = isSameDay(date, today);

                    final dayJobs = allJobs.where((j) {
                      if (j.scheduledDate == null) return isTodayDate;
                      return isSameDay(j.scheduledDate, date);
                    }).toList();

                    final dayJobCount = dayJobs.length;
                    final dayRmt = dayJobs.fold<double>(0.0, (sum, j) => sum + j.totalRmtWithWastage);

                    final dayName = isTodayDate ? 'TODAY' : DateFormat('EEE').format(date).toUpperCase();
                    final dateStr = DateFormat('dd MMM').format(date);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedScheduleDateFilter = date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.primary
                                : (isTodayDate ? Colors.blue.shade100 : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel ? AppTheme.primary : (isTodayDate ? AppTheme.primary : Colors.grey.shade300),
                              width: isSel || isTodayDate ? 2 : 1,
                            ),
                            boxShadow: isSel
                                ? [BoxShadow(color: AppTheme.primary.withAlpha(60), blurRadius: 4, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : (isTodayDate ? AppTheme.primary : Colors.grey.shade700),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? Colors.white.withAlpha(50)
                                      : (dayJobCount > 0 ? Colors.green.shade100 : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$dayJobCount Jobs | ${dayRmt.toInt()} RMT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : (dayJobCount > 0 ? Colors.green.shade900 : Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // FILTERED JOBS LIST FOR PRINTING SCHEDULE
        Expanded(
          child: filteredJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        _selectedScheduleDateFilter != null
                            ? 'No jobs scheduled for Printing on [${DateFormat('dd-MMM-yyyy').format(_selectedScheduleDateFilter!)}].'
                            : 'No production jobs in Printing Schedule stage.',
                        style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select another date above or schedule jobs from Pending Queue (Pre-Press).',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    final isSelected = _selectedJobIds.contains(job.id);
                    return _JobCard(
                      job: job,
                      isSelected: isSelected,
                      onToggleSelect: () {
                        setState(() {
                          if (isSelected) {
                            _selectedJobIds.remove(job.id);
                          } else {
                            _selectedJobIds.add(job.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFgStockView() {
    final jobsAsync = ref.watch(productionJobsStreamProvider((stage: ProductionStage.dispatched, subStatus: null)));

    return jobsAsync.when(
      data: (jobs) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📦 Finished Goods (FG) Stock Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade200),
                          children: const [
                            Padding(padding: EdgeInsets.all(8), child: Text('Job Doc No', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Product Description', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(8), child: Text('Dispatched Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        ...jobs.map((j) => TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(8), child: Text(j.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(8), child: Text(j.materialDescription)),
                                Padding(padding: const EdgeInsets.all(8), child: Text(j.clientName)),
                                Padding(padding: const EdgeInsets.all(8), child: Text('${j.dispatchQty.toInt()} pcs', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Future<void> _applyBatchSubStatus(String newSubStatus) async {
    final repo = ref.read(productionRepositoryProvider);
    for (final id in _selectedJobIds) {
      await repo.updateJobPendingSubStatus(id, newSubStatus);
    }
    setState(() => _selectedJobIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated status to [$newSubStatus] for selected jobs'), backgroundColor: Colors.green.shade800),
      );
    }
  }

  Future<void> _applyBatchStage(String newStage) async {
    final repo = ref.read(productionRepositoryProvider);
    for (final id in _selectedJobIds) {
      await repo.updateJobStage(id, newStage);
    }
    setState(() => _selectedJobIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved selected jobs to [$newStage] stage'), backgroundColor: Colors.green.shade800),
      );
    }
  }

  void _openNewJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const NewProductionJobDialog(),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({
    required this.job,
    required this.isSelected,
    required this.onToggleSelect,
  });

  final ProductionJobModel job;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Card(
      elevation: isSelected ? 4.0 : 2.0,
      color: isSelected ? Colors.blue.shade50.withAlpha(150) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : _getBadgeColor().withAlpha(120),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Checkbox + Job Doc No, Client, Sub-Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: isSelected, onChanged: (_) => onToggleSelect()),
                    Text(job.jobDocNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBadgeColor().withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _getBadgeColor().withAlpha(150)),
                      ),
                      child: Text(
                        job.currentStage == ProductionStage.pending ? job.pendingSubStatus : job.currentStage,
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getBadgeColor(), fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Text('Date: ${dateFormat.format(job.orderDate)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),

            // Material Description & Customer
            Text(job.materialDescription, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('Client: ${job.clientName} | PO No: ${job.poNumber.isNotEmpty ? job.poNumber : 'N/A'} | Plant: ${job.plantLocation}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 10),

            // INTERACTIVE WORKFLOW STEPPER BAR
            _buildInteractiveWorkflowStepper(context, ref),

            const Divider(height: 20),

            // Key Specs & Live Formulas
            Row(
              children: [
                _specBox('Req Qty', '${job.totalReqQty.toInt()} pcs'),
                _specBox('Gear (Z)', '${job.gearTeethCount} Z'),
                _specBox('UPS', '${job.ups} UPS'),
                _specBox('L.P. Meter', job.lpMeter.toStringAsFixed(2)),
                _specBox('Net RMT', '${job.reqRmt.toStringAsFixed(1)} mtr'),
                _specBox('Wastage', '+${job.wastageRmt.toInt()} mtr'),
                _specBox('Total RMT w/ Wastage', '${job.totalRmtWithWastage.toStringAsFixed(1)} RMT', isHighlight: true),
              ],
            ),
            const SizedBox(height: 8),

            // Substrate & Label Size
            Row(
              children: [
                Text('Material: ${job.substrateMaterial}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Text('Label Size: ${job.labelSize}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Text('Paper Size: ${job.paperSizeMm.toInt()} mm', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Stage Action Buttons & Sub-Status Selector Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit & Delete Buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
                      tooltip: 'Edit Job Details',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => NewProductionJobDialog(initialJob: job),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.danger),
                      tooltip: 'Delete Production Job',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
                                const SizedBox(width: 8),
                                Text('Delete Production Job [${job.jobDocNo}]'),
                              ],
                            ),
                            content: Text(
                              'Are you sure you want to delete Production Job "${job.jobDocNo}" (${job.materialDescription})?\n\nThis action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  try {
                                    final repo = ref.read(productionRepositoryProvider);
                                    await repo.deleteProductionJob(job.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Production Job [${job.jobDocNo}] deleted successfully!'),
                                          backgroundColor: Colors.green.shade800,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error deleting job: $e'),
                                          backgroundColor: AppTheme.danger,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.delete_forever, size: 16),
                                label: const Text('Delete Permanently'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Active Pipeline Movement Controls & Sub-Status Selector
                Row(
                  children: [
                    if (job.currentStage == ProductionStage.pending) ...[
                      // Prominent Interactive Dropdown for Pre-Press Sub-Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _getBadgeColor().withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _getBadgeColor()),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: job.pendingSubStatus,
                            icon: Icon(Icons.arrow_drop_down, color: _getBadgeColor()),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getBadgeColor()),
                            onChanged: (String? newSubStatus) async {
                              if (newSubStatus != null) {
                                final repo = ref.read(productionRepositoryProvider);
                                await repo.updateJobPendingSubStatus(job.id, newSubStatus);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Job ${job.jobDocNo} status changed to [$newSubStatus]'), backgroundColor: Colors.green.shade800),
                                  );
                                }
                              }
                            },
                            items: PendingSubStatus.values.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text('Status: $status', style: const TextStyle(color: Colors.black87)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ScheduleJobDialog(job: job),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('Move to Schedule ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ] else if (job.currentStage == ProductionStage.schedule) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final repo = ref.read(productionRepositoryProvider);
                          await repo.updateJobStage(job.id, ProductionStage.pending);
                        },
                        icon: const Icon(Icons.arrow_back, size: 14),
                        label: const Text('◀ Back to Pending', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ScheduleJobDialog(job: job),
                          );
                        },
                        icon: const Icon(Icons.calendar_month, size: 14),
                        label: const Text('Reschedule', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final repo = ref.read(productionRepositoryProvider);
                          await repo.updateJobStage(job.id, ProductionStage.postpress);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Job ${job.jobDocNo} moved to Postpress (Slitting/Die) ➔'), backgroundColor: Colors.green.shade800),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                        icon: const Icon(Icons.precision_manufacturing, size: 14),
                        label: const Text('Move to Postpress ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ] else if (job.currentStage == ProductionStage.postpress) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final repo = ref.read(productionRepositoryProvider);
                          await repo.updateJobStage(job.id, ProductionStage.schedule);
                        },
                        icon: const Icon(Icons.arrow_back, size: 14),
                        label: const Text('◀ Back to Schedule', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _openDispatchDialog(context, ref),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, foregroundColor: Colors.white),
                        icon: const Icon(Icons.local_shipping, size: 14),
                        label: const Text('Mark Dispatched ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ] else if (job.currentStage == ProductionStage.dispatched) ...[
                      Text('Dispatch Qty: ${job.dispatchQty.toInt()} | Bill: ${job.billNo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// INTERACTIVE WORKFLOW STEPPER BAR
  /// Users can click ANY step to immediately transition status!
  Widget _buildInteractiveWorkflowStepper(BuildContext context, WidgetRef ref) {
    final steps = [
      {
        'label': '1. New',
        'active': job.pendingSubStatus == PendingSubStatus.newPending && job.currentStage == ProductionStage.pending,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          if (job.currentStage != ProductionStage.pending) {
            await repo.updateJobStage(job.id, ProductionStage.pending);
          }
          await repo.updateJobPendingSubStatus(job.id, PendingSubStatus.newPending);
        },
      },
      {
        'label': '2. Approval',
        'active': job.pendingSubStatus == PendingSubStatus.underApproval && job.currentStage == ProductionStage.pending,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          if (job.currentStage != ProductionStage.pending) {
            await repo.updateJobStage(job.id, ProductionStage.pending);
          }
          await repo.updateJobPendingSubStatus(job.id, PendingSubStatus.underApproval);
        },
      },
      {
        'label': '3. Approved',
        'active': job.pendingSubStatus == PendingSubStatus.approvalReceived && job.currentStage == ProductionStage.pending,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          if (job.currentStage != ProductionStage.pending) {
            await repo.updateJobStage(job.id, ProductionStage.pending);
          }
          await repo.updateJobPendingSubStatus(job.id, PendingSubStatus.approvalReceived);
        },
      },
      {
        'label': '4. Under Plate',
        'active': job.pendingSubStatus == PendingSubStatus.underPlate && job.currentStage == ProductionStage.pending,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          if (job.currentStage != ProductionStage.pending) {
            await repo.updateJobStage(job.id, ProductionStage.pending);
          }
          await repo.updateJobPendingSubStatus(job.id, PendingSubStatus.underPlate);
        },
      },
      {
        'label': '5. Printing',
        'active': job.currentStage == ProductionStage.schedule,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          await repo.updateJobStage(job.id, ProductionStage.schedule);
        },
      },
      {
        'label': '6. Postpress',
        'active': job.currentStage == ProductionStage.postpress,
        'action': () async {
          final repo = ref.read(productionRepositoryProvider);
          await repo.updateJobStage(job.id, ProductionStage.postpress);
        },
      },
      {
        'label': '7. Dispatched',
        'active': job.currentStage == ProductionStage.dispatched,
        'action': () {
          _openDispatchDialog(context, ref);
        },
      },
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text('Workflow Step Pipeline (Click any step to set status directly):', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.map((s) {
                final active = s['active'] as bool;
                final action = s['action'] as VoidCallback;
                return InkWell(
                  onTap: action,
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? _getBadgeColor() : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: active ? _getBadgeColor() : Colors.grey.shade400, width: active ? 1.5 : 1),
                      boxShadow: active ? [BoxShadow(color: _getBadgeColor().withAlpha(80), blurRadius: 4)] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (active) const Icon(Icons.check_circle, color: Colors.white, size: 12),
                        if (active) const SizedBox(width: 4),
                        Text(
                          s['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active ? FontWeight.bold : FontWeight.w500,
                            color: active ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor() {
    if (job.currentStage == ProductionStage.pending) {
      switch (job.pendingSubStatus) {
        case PendingSubStatus.underApproval:
          return Colors.red.shade700;
        case PendingSubStatus.approvalReceived:
          return Colors.green.shade800;
        case PendingSubStatus.underPlate:
          return Colors.amber.shade800;
        case PendingSubStatus.holdJob:
          return Colors.purple.shade700;
        default:
          return Colors.blue.shade800;
      }
    } else if (job.currentStage == ProductionStage.schedule) {
      return Colors.indigo.shade800;
    } else if (job.currentStage == ProductionStage.postpress) {
      return Colors.amber.shade900;
    } else if (job.currentStage == ProductionStage.dispatched) {
      return Colors.green.shade800;
    }
    return AppTheme.primary;
  }

  Widget _specBox(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isHighlight ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: isHighlight ? Border.all(color: Colors.green.shade300) : null,
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isHighlight ? Colors.green.shade900 : Colors.black)),
          ],
        ),
      ),
    );
  }

  void _openDispatchDialog(BuildContext context, WidgetRef ref) {
    final dispatchQtyCtrl = TextEditingController(text: job.totalReqQty.toInt().toString());
    final deliveryByCtrl = TextEditingController(text: 'Self Pickup / Local Courier');
    final billNoCtrl = TextEditingController(text: 'INV-2026-${job.jobDocNo.replaceAll('/', '')}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Dispatch Entry (${job.jobDocNo})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dispatchQtyCtrl,
              decoration: const InputDecoration(labelText: 'Dispatch Quantity (Pcs)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deliveryByCtrl,
              decoration: const InputDecoration(labelText: 'Delivery Transporter / Person'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: billNoCtrl,
              decoration: const InputDecoration(labelText: 'Bill / Invoice No'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(productionRepositoryProvider);
              final updatedJob = ProductionJobModel(
                id: job.id,
                plantId: job.plantId,
                jobDocNo: job.jobDocNo,
                clientName: job.clientName,
                orderDate: job.orderDate,
                poNumber: job.poNumber,
                poDate: job.poDate,
                materialDescription: job.materialDescription,
                totalReqQty: job.totalReqQty,
                gearTeethCount: job.gearTeethCount,
                ups: job.ups,
                paperSizeMm: job.paperSizeMm,
                substrateMaterial: job.substrateMaterial,
                labelSize: job.labelSize,
                plantLocation: job.plantLocation,
                pendingSubStatus: job.pendingSubStatus,
                paperStatus: job.paperStatus,
                lamination: job.lamination,
                foil: job.foil,
                currentStage: ProductionStage.dispatched,
                dispatchQty: double.parse(dispatchQtyCtrl.text.trim()),
                balanceQty: job.totalReqQty - double.parse(dispatchQtyCtrl.text.trim()),
                dispatchDate: DateTime.now(),
                deliveryBy: deliveryByCtrl.text.trim(),
                billNo: billNoCtrl.text.trim(),
                createdAt: job.createdAt,
                createdBy: job.createdBy,
              );

              await repo.updateProductionJob(updatedJob);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Confirm Dispatch'),
          ),
        ],
      ),
    );
  }
}
