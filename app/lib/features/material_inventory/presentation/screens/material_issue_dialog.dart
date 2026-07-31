import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/roll_model.dart';
import '../../logic/material_providers.dart';

class MaterialIssueDialog extends ConsumerStatefulWidget {
  const MaterialIssueDialog({super.key, required this.roll});

  final RollModel roll;

  @override
  ConsumerState<MaterialIssueDialog> createState() => _MaterialIssueDialogState();
}

class _MaterialIssueDialogState extends ConsumerState<MaterialIssueDialog> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;
  late TextEditingController _issueRmtController;
  late TextEditingController _issuedByController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _issueRmtController = TextEditingController(text: widget.roll.availableRmt.toString());
    _issuedByController = TextEditingController(text: 'Stores Incharge');
  }

  @override
  void dispose() {
    _issueRmtController.dispose();
    _issuedByController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Job Card')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(materialRepositoryProvider);

      await repo.issueRollToJob(
        rollId: widget.roll.id,
        jobCardId: _selectedJobCard!.id,
        jobCardNo: _selectedJobCard!.jobCardNo,
        customerName: _selectedJobCard!.customerName,
        productName: _selectedJobCard!.productName,
        issuedRmt: double.parse(_issueRmtController.text.trim()),
        performedBy: _issuedByController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Roll ${widget.roll.rollCode} issued to Job ${_selectedJobCard!.jobCardNo}')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error issuing roll: $e'), backgroundColor: AppTheme.danger),
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
      title: Text('Issue Roll: ${widget.roll.rollCode}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Stock: ${widget.roll.availableRmt.toInt()} RMT (${widget.roll.substrateMaterial})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
            const SizedBox(height: 12),
            jobCardsAsync.when(
              data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                value: _selectedJobCard,
                decoration: const InputDecoration(labelText: 'Select Job Card *'),
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
              controller: _issueRmtController,
              decoration: const InputDecoration(labelText: 'Issued RMT Quantity *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || double.tryParse(v) == null) return 'Required';
                final val = double.parse(v);
                if (val > widget.roll.availableRmt) return 'Exceeds available roll RMT';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _issuedByController,
              decoration: const InputDecoration(labelText: 'Issued By (User) *'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? 'Issuing...' : 'Confirm Material Issue'),
        ),
      ],
    );
  }
}
