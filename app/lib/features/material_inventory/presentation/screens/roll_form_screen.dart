import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/roll_model.dart';
import '../../logic/material_providers.dart';

class RollFormScreen extends ConsumerStatefulWidget {
  const RollFormScreen({super.key, this.roll});

  final RollModel? roll;

  @override
  ConsumerState<RollFormScreen> createState() => _RollFormScreenState();
}

class _RollFormScreenState extends ConsumerState<RollFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _substrateController;
  late TextEditingController _widthController;
  late TextEditingController _rmtController;
  late TextEditingController _vendorController;
  late TextEditingController _lotController;
  late TextEditingController _locationController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.roll;
    _codeController = TextEditingController(
      text: r?.rollCode ?? 'ROLL-CHR-${DateTime.now().millisecondsSinceEpoch % 1000}',
    );
    _substrateController = TextEditingController(text: r?.substrateMaterial ?? 'Chromo Paper');
    _widthController = TextEditingController(text: r != null ? r.widthMm.toInt().toString() : '220');
    _rmtController = TextEditingController(text: r != null ? r.availableRmt.toInt().toString() : '1000');
    _vendorController = TextEditingController(text: r?.vendorName ?? 'Avery Dennison');
    _lotController = TextEditingController(text: r?.vendorBatchLot ?? 'LOT-2026-99');
    _locationController = TextEditingController(text: r?.storageLocation ?? 'Stores Rack R-1');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _substrateController.dispose();
    _widthController.dispose();
    _rmtController.dispose();
    _vendorController.dispose();
    _lotController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(materialRepositoryProvider);
      final rmt = double.parse(_rmtController.text.trim());

      final isEdit = widget.roll != null;
      final roll = RollModel(
        id: isEdit ? widget.roll!.id : '',
        plantId: isEdit ? widget.roll!.plantId : DefaultPlant.id,
        rollCode: _codeController.text.trim().toUpperCase(),
        substrateMaterial: _substrateController.text.trim(),
        widthMm: double.parse(_widthController.text.trim()),
        originalRmt: isEdit ? widget.roll!.originalRmt : rmt,
        availableRmt: rmt,
        status: isEdit ? widget.roll!.status : RollStatus.available,
        vendorName: _vendorController.text.trim(),
        vendorBatchLot: _lotController.text.trim(),
        receiptDate: isEdit ? widget.roll!.receiptDate : DateTime.now(),
        storageLocation: _locationController.text.trim(),
        createdAt: isEdit ? widget.roll!.createdAt : DateTime.now(),
        createdBy: isEdit ? widget.roll!.createdBy : 'stores',
      );

      if (isEdit) {
        await repo.updateRoll(roll);
      } else {
        await repo.createRoll(roll);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Roll [${roll.rollCode}] updated successfully!' : 'Roll receipt logged & stock updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving roll: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.roll != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Roll Details [${widget.roll!.rollCode}]' : 'Goods Receipt — New Material Roll')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Roll ID / Barcode *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _substrateController,
                    decoration: const InputDecoration(labelText: 'Substrate Material *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(labelText: 'Web Width (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rmtController,
                    decoration: const InputDecoration(labelText: 'Original RMT *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vendorController,
                    decoration: const InputDecoration(labelText: 'Vendor Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lotController,
                    decoration: const InputDecoration(labelText: 'Vendor Batch / Lot'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Storage Location / Rack'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.check),
                label: Text(_isSaving ? 'Logging Receipt...' : 'Save Goods Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
