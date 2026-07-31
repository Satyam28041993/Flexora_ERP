import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/roll_model.dart';
import '../../logic/material_providers.dart';

class MaterialReturnDialog extends ConsumerStatefulWidget {
  const MaterialReturnDialog({super.key, required this.roll});

  final RollModel roll;

  @override
  ConsumerState<MaterialReturnDialog> createState() => _MaterialReturnDialogState();
}

class _MaterialReturnDialogState extends ConsumerState<MaterialReturnDialog> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;
  late TextEditingController _returnRmtController;
  late TextEditingController _returnedByController;
  late TextEditingController _remarksController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _returnRmtController = TextEditingController(text: '150');
    _returnedByController = TextEditingController(text: 'Stores Incharge');
    _remarksController = TextEditingController(text: 'Leftover roll returned to stores');
  }

  @override
  void dispose() {
    _returnRmtController.dispose();
    _returnedByController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Job Card')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(materialRepositoryProvider);

      await repo.returnLeftoverRollToStores(
        rollId: widget.roll.id,
        jobCardId: _selectedJobCard!.id,
        jobCardNo: _selectedJobCard!.jobCardNo,
        returnedRmt: double.parse(_returnRmtController.text.trim()),
        performedBy: _returnedByController.text.trim(),
        remarks: _remarksController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leftover roll ${widget.roll.rollCode} returned to stock')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error returning roll: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(jobCardsStreamProvider);

    return AlertDialog(
      title: Text('Return Leftover Roll: ${widget.roll.rollCode}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Available Stock: ${widget.roll.availableRmt.toInt()} RMT',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
            const SizedBox(height: 12),
            jobCardsAsync.when(
              data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                value: _selectedJobCard,
                decoration: const InputDecoration(labelText: 'From Job Card *'),
                items: jobCards
                    .map((j) => DropdownMenuItem(value: j, child: Text('${j.jobCardNo} (${j.customerName})')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedJobCard = val),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _returnRmtController,
              decoration: const InputDecoration(labelText: 'Returned RMT Quantity *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _returnedByController,
              decoration: const InputDecoration(labelText: 'Returned By *'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(labelText: 'Remarks'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? 'Returning...' : 'Confirm Roll Return'),
        ),
      ],
    );
  }
}
