import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/packing_list_model.dart';
import '../../logic/dispatch_providers.dart';

class PackingFormScreen extends ConsumerStatefulWidget {
  const PackingFormScreen({super.key});

  @override
  ConsumerState<PackingFormScreen> createState() => _PackingFormScreenState();
}

class _PackingFormScreenState extends ConsumerState<PackingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;

  late TextEditingController _codeController;
  late TextEditingController _boxesController;
  late TextEditingController _rollsController;
  late TextEditingController _qtyController;
  late TextEditingController _packedByController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: 'PL-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
    );
    _boxesController = TextEditingController(text: '5');
    _rollsController = TextEditingController(text: '20');
    _qtyController = TextEditingController(text: '10000');
    _packedByController = TextEditingController(text: 'Packing Inspector');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _boxesController.dispose();
    _rollsController.dispose();
    _qtyController.dispose();
    _packedByController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Job Card')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(dispatchRepositoryProvider);

      final packingList = PackingListModel(
        id: '',
        plantId: DefaultPlant.id,
        packingListNo: _codeController.text.trim().toUpperCase(),
        jobCardId: _selectedJobCard!.id,
        jobCardNo: _selectedJobCard!.jobCardNo,
        customerName: _selectedJobCard!.customerName,
        productName: _selectedJobCard!.productName,
        totalBoxes: int.parse(_boxesController.text.trim()),
        totalRolls: int.parse(_rollsController.text.trim()),
        totalQuantityPcs: double.parse(_qtyController.text.trim()),
        packedBy: _packedByController.text.trim(),
        packingDate: DateTime.now(),
        createdAt: DateTime.now(),
        createdBy: 'packing',
      );

      await repo.createPackingList(packingList);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Packing List generated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Packing List: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(jobCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Packing List')),
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
                    decoration: const InputDecoration(labelText: 'Packing List No. *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _packedByController,
                    decoration: const InputDecoration(labelText: 'Packed By (Inspector) *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            jobCardsAsync.when(
              data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                value: _selectedJobCard,
                decoration: const InputDecoration(labelText: 'Link Job Card *'),
                items: jobCards
                    .map((j) => DropdownMenuItem(value: j, child: Text('${j.jobCardNo} (${j.productName})')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedJobCard = val;
                    if (val != null) {
                      _qtyController.text = val.targetOrderQty.toString();
                    }
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _boxesController,
                    decoration: const InputDecoration(labelText: 'Total Boxes *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rollsController,
                    decoration: const InputDecoration(labelText: 'Total Rolls *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: 'Total Quantity (Pcs) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Packing List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
