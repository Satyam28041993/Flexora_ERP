import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/production_job_model.dart';
import '../../logic/production_providers.dart';

/// Modal Dialog to schedule a Production Job for Printing.
/// Allows selecting Target Production Date (Today, Tomorrow, Custom Date), Press Machine, & Shift.
class ScheduleJobDialog extends ConsumerStatefulWidget {
  const ScheduleJobDialog({
    super.key,
    required this.job,
  });

  final ProductionJobModel job;

  @override
  ConsumerState<ScheduleJobDialog> createState() => _ScheduleJobDialogState();
}

class _ScheduleJobDialogState extends ConsumerState<ScheduleJobDialog> {
  late DateTime _selectedDate;
  late String _selectedShift;

  bool _isSaving = false;

  // Only one press machine exists at PGPL today, so it is auto-assigned
  // (not shown as a picker) rather than inventing a machine list.
  final List<String> _shiftOptions = [
    ProductionJobModel.dayShift,
    ProductionJobModel.nightShift,
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.job.scheduledDate ?? DateTime.now();
    _selectedShift = _shiftOptions.contains(widget.job.scheduledShift)
        ? widget.job.scheduledShift
        : _shiftOptions.first;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateFormat = DateFormat('EEEE, dd-MMM-yyyy');

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Job [${widget.job.jobDocNo}]',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Client: ${widget.job.clientName} | ${widget.job.materialDescription}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary Badge Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Qty: ${widget.job.totalReqQty.toInt()} pcs',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Substrate: ${widget.job.substrateMaterial} (${widget.job.paperSizeMm.toInt()} mm)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Req RMT: ${widget.job.totalRmtWithWastage.toStringAsFixed(1)} RMT',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                        Text('Gear Z: ${widget.job.gearTeethCount} Z | UPS: ${widget.job.ups}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 1: Target Date Selector
              const Text('1. Target Printing Execution Date *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Today'),
                    selected: _isSameDay(_selectedDate, today),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDate = today);
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: _isSameDay(_selectedDate, today) ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Tomorrow'),
                    selected: _isSameDay(_selectedDate, tomorrow),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDate = tomorrow);
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: _isSameDay(_selectedDate, tomorrow) ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: today.subtract(const Duration(days: 7)),
                        lastDate: today.add(const Duration(days: 60)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Selected Date Text Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Scheduled Date: ${dateFormat.format(_selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Press machine — only one exists today, so it's shown as an
              // informational line, not a picker.
              Row(
                children: [
                  const Icon(Icons.print, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Press: ${ProductionJobModel.defaultPress}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 2: Shift Selection
              const Text('2. Target Production Shift',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Row(
                children: _shiftOptions.map((s) {
                  final isSel = _selectedShift == s;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedShift = s),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primary.withAlpha(20) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSel ? AppTheme.primary : Colors.grey.shade300,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSel ? AppTheme.primary : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    color: isSel ? AppTheme.primary : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  setState(() => _isSaving = true);
                  try {
                    final repo = ref.read(productionRepositoryProvider);

                    final updatedJob = ProductionJobModel(
                      id: widget.job.id,
                      plantId: widget.job.plantId,
                      jobDocNo: widget.job.jobDocNo,
                      clientName: widget.job.clientName,
                      orderDate: widget.job.orderDate,
                      materialDescription: widget.job.materialDescription,
                      totalReqQty: widget.job.totalReqQty,
                      gearTeethCount: widget.job.gearTeethCount,
                      ups: widget.job.ups,
                      paperSizeMm: widget.job.paperSizeMm,
                      substrateMaterial: widget.job.substrateMaterial,
                      labelSize: widget.job.labelSize,
                      createdAt: widget.job.createdAt,
                      createdBy: widget.job.createdBy,
                      wastageRmt: widget.job.wastageRmt,
                      poNumber: widget.job.poNumber,
                      poDate: widget.job.poDate,
                      pendingPoQty: widget.job.pendingPoQty,
                      approvalDate: widget.job.approvalDate,
                      approvedDate: widget.job.approvedDate,
                      plantLocation: widget.job.plantLocation,
                      pendingSubStatus: widget.job.pendingSubStatus,
                      paperStatus: widget.job.paperStatus,
                      fromOrder: widget.job.fromOrder,
                      stockRm: widget.job.stockRm,
                      remarkFromPurchase: widget.job.remarkFromPurchase,
                      lamination: widget.job.lamination,
                      foil: widget.job.foil,
                      plateStatus: widget.job.plateStatus,
                      punchStatus: widget.job.punchStatus,
                      remark: widget.job.remark,
                      currentStage: ProductionStage.schedule, // Move to Printing Schedule
                      scheduledDate: _selectedDate,
                      assignedPress: ProductionJobModel.defaultPress,
                      scheduledShift: _selectedShift,
                      dispatchQty: widget.job.dispatchQty,
                      balanceQty: widget.job.balanceQty,
                      dispatchDate: widget.job.dispatchDate,
                      deliveryBy: widget.job.deliveryBy,
                      shortQty: widget.job.shortQty,
                      boxQty: widget.job.boxQty,
                      billNo: widget.job.billNo,
                      updatedAt: DateTime.now(),
                      updatedBy: 'planner',
                    );

                    await repo.updateProductionJob(updatedJob);

                    if (mounted) {
                      final fmt = DateFormat('dd-MMM');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Job [${widget.job.jobDocNo}] scheduled for Printing on ${fmt.format(_selectedDate)} (${_selectedShift})!',
                          ),
                          backgroundColor: Colors.green.shade800,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error scheduling job: $e'),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Confirm & Schedule Printing'),
        ),
      ],
    );
  }
}
