import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/dispatch_challan_model.dart';
import '../../logic/dispatch_challan_pdf_generator.dart';
import '../../logic/dispatch_providers.dart';

class DispatchFormScreen extends ConsumerStatefulWidget {
  const DispatchFormScreen({super.key});

  @override
  ConsumerState<DispatchFormScreen> createState() => _DispatchFormScreenState();
}

class _DispatchFormScreenState extends ConsumerState<DispatchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;

  late TextEditingController _challanNoController;
  late TextEditingController _vehicleNoController;
  late TextEditingController _addressController;
  late TextEditingController _targetQtyController;
  late TextEditingController _dispatchQtyController;
  late TextEditingController _dispatchedByController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _challanNoController = TextEditingController(
      text: 'DC-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
    );
    _vehicleNoController = TextEditingController(text: 'MH-04-AB-1234');
    _addressController = TextEditingController(text: 'Customer Works / Shipping Location');
    _targetQtyController = TextEditingController(text: '10000');
    _dispatchQtyController = TextEditingController(text: '10000');
    _dispatchedByController = TextEditingController(text: 'Dispatch Manager');
  }

  @override
  void dispose() {
    _challanNoController.dispose();
    _vehicleNoController.dispose();
    _addressController.dispose();
    _targetQtyController.dispose();
    _dispatchQtyController.dispose();
    _dispatchedByController.dispose();
    super.dispose();
  }

  Future<void> _save({bool printPdfAfterSave = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedJobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Job Card')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(dispatchRepositoryProvider);
      final target = double.parse(_targetQtyController.text.trim());
      final dispatched = double.parse(_dispatchQtyController.text.trim());
      final balance = (target - dispatched).clamp(0.0, double.infinity);

      final challan = DispatchChallanModel(
        id: '',
        plantId: DefaultPlant.id,
        challanNo: _challanNoController.text.trim().toUpperCase(),
        jobCardId: _selectedJobCard!.id,
        jobCardNo: _selectedJobCard!.jobCardNo,
        poNumber: _selectedJobCard!.poNumber,
        customerName: _selectedJobCard!.customerName,
        shippingAddress: _addressController.text.trim(),
        vehicleNo: _vehicleNoController.text.trim().toUpperCase(),
        targetOrderQtyPcs: target,
        dispatchedQtyPcs: dispatched,
        balanceQtyPcs: balance,
        dispatchDate: DateTime.now(),
        dispatchedBy: _dispatchedByController.text.trim(),
        createdAt: DateTime.now(),
        createdBy: 'dispatch',
      );

      await repo.createDispatchChallan(challan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispatch Challan issued & finished stock updated!')),
        );

        if (printPdfAfterSave) {
          final pdfBytes = await DispatchChallanPdfGenerator.generateChallanPdf(challan: challan);
          await Printing.layoutPdf(onLayout: (_) => pdfBytes, name: 'Dispatch_Challan_${challan.challanNo}.pdf');
        }

        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error issuing Dispatch Challan: $e'), backgroundColor: AppTheme.danger),
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
      appBar: AppBar(title: const Text('Issue Dispatch Challan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _challanNoController,
                    decoration: const InputDecoration(labelText: 'Challan No. *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _vehicleNoController,
                    decoration: const InputDecoration(labelText: 'Vehicle No. *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            jobCardsAsync.when(
              data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                value: _selectedJobCard,
                decoration: const InputDecoration(labelText: 'Link Job Card / Order *'),
                items: jobCards
                    .map((j) => DropdownMenuItem(value: j, child: Text('${j.jobCardNo} — ${j.customerName} (${j.productName})')))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedJobCard = val;
                    if (val != null) {
                      _targetQtyController.text = val.targetOrderQty.toString();
                      _dispatchQtyController.text = val.targetOrderQty.toString();
                    }
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Shipping Address *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetQtyController,
                    decoration: const InputDecoration(labelText: 'Target Order Qty (Pcs) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dispatchQtyController,
                    decoration: const InputDecoration(labelText: 'Dispatched Qty (Pcs) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dispatchedByController,
              decoration: const InputDecoration(labelText: 'Dispatched By (User) *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () => _save(printPdfAfterSave: false),
                      icon: const Icon(Icons.save),
                      label: Text(_isSaving ? 'Issuing...' : 'Save Challan'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _save(printPdfAfterSave: true),
                      icon: const Icon(Icons.print),
                      label: Text(_isSaving ? 'Issuing...' : 'Save & Print GST Challan'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
