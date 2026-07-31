import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/production_log_model.dart';
import '../../data/models/production_schedule_model.dart';
import '../../logic/production_providers.dart';

class ProductionLogFormScreen extends ConsumerStatefulWidget {
  const ProductionLogFormScreen({super.key, required this.schedule});

  final ProductionScheduleModel schedule;

  @override
  ConsumerState<ProductionLogFormScreen> createState() => _ProductionLogFormScreenState();
}

class _ProductionLogFormScreenState extends ConsumerState<ProductionLogFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _operatorController;
  late TextEditingController _speedController;
  late TextEditingController _rmtPrintedController;
  late TextEditingController _labelsProducedController;
  late TextEditingController _setupMinutesController;
  late TextEditingController _setupWasteController;
  late TextEditingController _runningWasteController;
  late TextEditingController _downtimeMinutesController;
  late TextEditingController _downtimeReasonController;

  String _shift = 'Day';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _operatorController = TextEditingController();
    _speedController = TextEditingController(text: '45');
    _rmtPrintedController = TextEditingController(text: widget.schedule.plannedRmt.toString());
    _labelsProducedController = TextEditingController(text: widget.schedule.targetQuantity.toString());
    _setupMinutesController = TextEditingController(text: '30');
    _setupWasteController = TextEditingController(text: '50');
    _runningWasteController = TextEditingController(text: '20');
    _downtimeMinutesController = TextEditingController(text: '0');
    _downtimeReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _operatorController.dispose();
    _speedController.dispose();
    _rmtPrintedController.dispose();
    _labelsProducedController.dispose();
    _setupMinutesController.dispose();
    _setupWasteController.dispose();
    _runningWasteController.dispose();
    _downtimeMinutesController.dispose();
    _downtimeReasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(productionRepositoryProvider);
      final now = DateTime.now();

      final log = ProductionLogModel(
        id: '',
        plantId: DefaultPlant.id,
        scheduleId: widget.schedule.id,
        jobCardId: widget.schedule.jobCardId,
        jobCardNo: widget.schedule.jobCardNo,
        machineId: widget.schedule.machineId,
        machineName: widget.schedule.machineName,
        shift: _shift,
        operatorName: _operatorController.text.trim(),
        averageSpeedMpm: double.parse(_speedController.text.trim()),
        runStartTime: now.subtract(const Duration(hours: 4)),
        runEndTime: now,
        totalRmtPrinted: double.parse(_rmtPrintedController.text.trim()),
        totalLabelsProduced: double.parse(_labelsProducedController.text.trim()),
        setupTimeMinutes: int.parse(_setupMinutesController.text.trim()),
        setupWasteRmt: double.parse(_setupWasteController.text.trim()),
        runningWasteRmt: double.parse(_runningWasteController.text.trim()),
        downtimeMinutes: int.parse(_downtimeMinutesController.text.trim()),
        downtimeReason: _downtimeReasonController.text.trim().isEmpty ? null : _downtimeReasonController.text.trim(),
        createdAt: now,
        createdBy: 'operator',
      );

      await repo.createProductionLog(log);
      await repo.updateScheduleStatus(widget.schedule.id, 'Completed');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Production Run Output logged successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging production run: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Operator Production Log — ${widget.schedule.jobCardNo}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppTheme.primary.withAlpha(15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Machine: ${widget.schedule.machineName} | Product: ${widget.schedule.productName} (${widget.schedule.customerName})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _operatorController,
                    decoration: const InputDecoration(labelText: 'Operator Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _shift,
                    decoration: const InputDecoration(labelText: 'Shift'),
                    items: ['Day', 'Night'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _shift = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _speedController,
                    decoration: const InputDecoration(labelText: 'Machine Speed (m/min) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rmtPrintedController,
                    decoration: const InputDecoration(labelText: 'Total RMT Run *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _labelsProducedController,
                    decoration: const InputDecoration(labelText: 'Labels Produced *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Setup & Waste Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setupMinutesController,
                    decoration: const InputDecoration(labelText: 'Setup Time (Mins)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _setupWasteController,
                    decoration: const InputDecoration(labelText: 'Setup Waste (RMT)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _runningWasteController,
                    decoration: const InputDecoration(labelText: 'Running Waste (RMT)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Downtime Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _downtimeMinutesController,
                    decoration: const InputDecoration(labelText: 'Downtime (Mins)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _downtimeReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Downtime Reason',
                      hintText: 'e.g. Mechanical, Ink Change, Web Break, Material Delay',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.check_circle),
                label: Text(_isSaving ? 'Logging...' : 'Submit Production Output Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
