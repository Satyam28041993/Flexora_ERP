import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/shade_card_model.dart';
import '../../logic/shade_card_providers.dart';

class ShadeCardFormScreen extends ConsumerStatefulWidget {
  const ShadeCardFormScreen({super.key, this.shadeCard});

  final ShadeCardModel? shadeCard;

  @override
  ConsumerState<ShadeCardFormScreen> createState() => _ShadeCardFormScreenState();
}

class _ShadeCardFormScreenState extends ConsumerState<ShadeCardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;

  late TextEditingController _codeController;
  late TextEditingController _batchRunNoController;
  late TextEditingController _stdStoragePathController;
  late TextEditingController _darkStoragePathController;
  late TextEditingController _lightStoragePathController;
  late TextEditingController _remarksController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.shadeCard;

    _codeController = TextEditingController(
      text: s?.shadeCardCode ?? 'SC-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
    );
    _batchRunNoController = TextEditingController(text: s?.productionBatchRunNo ?? 'BATCH-01');
    _stdStoragePathController = TextEditingController(text: s?.standardShadeStoragePath ?? '');
    _darkStoragePathController = TextEditingController(text: s?.darkShadeStoragePath ?? '');
    _lightStoragePathController = TextEditingController(text: s?.lightShadeStoragePath ?? '');
    _remarksController = TextEditingController(text: s?.remarks ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _batchRunNoController.dispose();
    _stdStoragePathController.dispose();
    _darkStoragePathController.dispose();
    _lightStoragePathController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCard == null && widget.shadeCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Job Card')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(shadeCardRepositoryProvider);

      final shadeCardData = ShadeCardModel(
        id: widget.shadeCard?.id ?? '',
        plantId: DefaultPlant.id,
        shadeCardCode: _codeController.text.trim().toUpperCase(),
        customerId: _selectedJobCard?.customerId ?? widget.shadeCard!.customerId,
        customerName: _selectedJobCard?.customerName ?? widget.shadeCard!.customerName,
        productId: _selectedJobCard?.productId ?? widget.shadeCard!.productId,
        internalSkuCode: _selectedJobCard?.internalSkuCode ?? widget.shadeCard!.internalSkuCode,
        productName: _selectedJobCard?.productName ?? widget.shadeCard!.productName,
        jobCardId: _selectedJobCard?.id ?? widget.shadeCard!.jobCardId,
        jobCardNo: _selectedJobCard?.jobCardNo ?? widget.shadeCard!.jobCardNo,
        artworkVersionId: widget.shadeCard?.artworkVersionId ?? '',
        artworkVersionLabel: 'v1',
        dateCreated: DateTime.now(),
        productionBatchRunNo: _batchRunNoController.text.trim(),
        standardShadeStoragePath: _stdStoragePathController.text.trim().isNotEmpty
            ? _stdStoragePathController.text.trim()
            : 'shades/${_codeController.text.trim()}_standard.jpg',
        darkShadeStoragePath: _darkStoragePathController.text.trim().isEmpty ? null : _darkStoragePathController.text.trim(),
        lightShadeStoragePath: _lightStoragePathController.text.trim().isEmpty ? null : _lightStoragePathController.text.trim(),
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        status: widget.shadeCard?.status ?? ShadeCardStatus.pending,
        createdAt: widget.shadeCard?.createdAt ?? DateTime.now(),
        createdBy: widget.shadeCard?.createdBy ?? 'system',
        updatedAt: widget.shadeCard != null ? DateTime.now() : null,
        updatedBy: widget.shadeCard != null ? 'system' : null,
      );

      if (widget.shadeCard == null) {
        await repo.createShadeCard(shadeCardData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.shadeCard == null ? 'Shade Card registered' : 'Shade Card updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Shade Card: $e'), backgroundColor: AppTheme.danger),
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
      appBar: AppBar(title: Text(widget.shadeCard == null ? 'Record New Shade Card' : 'Edit Shade Card')),
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
                    decoration: const InputDecoration(labelText: 'Shade Card Code *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _batchRunNoController,
                    decoration: const InputDecoration(labelText: 'Batch / Run No. *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.shadeCard == null)
              jobCardsAsync.when(
                data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                  value: _selectedJobCard,
                  decoration: const InputDecoration(labelText: 'Link Active Job Card *'),
                  items: jobCards
                      .map((j) => DropdownMenuItem(value: j, child: Text('${j.jobCardNo} — ${j.productName} (${j.customerName})')))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedJobCard = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading Job Cards: $err'),
              ),
            const SizedBox(height: 20),
            const Text('Shade Samples Storage References (Images / Files)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            TextFormField(
              controller: _stdStoragePathController,
              decoration: const InputDecoration(
                labelText: 'Standard Shade Sample Path (Primary) *',
                hintText: 'Firebase Storage reference path for Standard Shade',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _darkStoragePathController,
              decoration: const InputDecoration(
                labelText: 'Dark Shade Sample Path (Optional)',
                hintText: 'Firebase Storage reference path for Dark Shade tolerance',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lightStoragePathController,
              decoration: const InputDecoration(
                labelText: 'Light Shade Sample Path (Optional)',
                hintText: 'Firebase Storage reference path for Light Shade tolerance',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Production / Shade Remarks',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Shade Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
