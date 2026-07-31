import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../../tooling_master/data/models/die_model.dart';
import '../../../tooling_master/data/models/plate_model.dart';
import '../../../tooling_master/logic/tooling_providers.dart';
import '../../data/models/job_card_model.dart';
import '../../logic/job_card_providers.dart';

class JobCardFormScreen extends ConsumerStatefulWidget {
  const JobCardFormScreen({super.key, this.jobCard});

  final JobCardModel? jobCard;

  @override
  ConsumerState<JobCardFormScreen> createState() => _JobCardFormScreenState();
}

class _JobCardFormScreenState extends ConsumerState<JobCardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerModel? _selectedCustomer;
  ProductModel? _selectedProduct;
  PlateModel? _selectedPlate;
  DieModel? _selectedDie;

  late TextEditingController _jobCardNoController;
  late TextEditingController _poNumberController;
  late TextEditingController _targetQtyController;
  late TextEditingController _plannedQtyController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final j = widget.jobCard;

    _jobCardNoController = TextEditingController(
      text: j?.jobCardNo ?? 'JC-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
    );
    _poNumberController = TextEditingController(text: j?.poNumber ?? '');
    _targetQtyController = TextEditingController(text: j?.targetOrderQty.toString() ?? '10000');
    _plannedQtyController = TextEditingController(text: j?.plannedProductionQty.toString() ?? '10500');
  }

  @override
  void dispose() {
    _jobCardNoController.dispose();
    _poNumberController.dispose();
    _targetQtyController.dispose();
    _plannedQtyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null && widget.jobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Customer')));
      return;
    }
    if (_selectedProduct == null && widget.jobCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Product SKU')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(jobCardRepositoryProvider);

      final jobCardData = JobCardModel(
        id: widget.jobCard?.id ?? '',
        plantId: DefaultPlant.id,
        jobCardNo: _jobCardNoController.text.trim().toUpperCase(),
        orderId: widget.jobCard?.orderId ?? 'order-manual',
        poNumber: _poNumberController.text.trim(),
        customerId: _selectedCustomer?.id ?? widget.jobCard!.customerId,
        customerName: _selectedCustomer?.companyName ?? widget.jobCard!.customerName,
        productId: _selectedProduct?.id ?? widget.jobCard!.productId,
        internalSkuCode: _selectedProduct?.internalSkuCode ?? widget.jobCard!.internalSkuCode,
        productName: _selectedProduct?.productName ?? widget.jobCard!.productName,
        targetOrderQty: double.parse(_targetQtyController.text.trim()),
        plannedProductionQty: double.parse(_plannedQtyController.text.trim()),
        plateId: _selectedPlate?.id ?? widget.jobCard?.plateId ?? '',
        plateCode: _selectedPlate?.plateCode ?? widget.jobCard?.plateCode ?? '',
        dieId: _selectedDie?.id ?? widget.jobCard?.dieId ?? '',
        dieCode: _selectedDie?.dieCode ?? widget.jobCard?.dieCode ?? '',
        processRoute: _selectedProduct?.processRoute ?? widget.jobCard?.processRoute ?? StandardProcessSteps.defaultRoute,
        status: widget.jobCard?.status ?? JobCardStatus.draft,
        createdAt: widget.jobCard?.createdAt ?? DateTime.now(),
        createdBy: widget.jobCard?.createdBy ?? 'system',
        updatedAt: widget.jobCard != null ? DateTime.now() : null,
        updatedBy: widget.jobCard != null ? 'system' : null,
      );

      if (widget.jobCard == null) {
        await repo.createJobCard(jobCardData);
      } else {
        await repo.updateJobCard(jobCardData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.jobCard == null ? 'Job Card issued successfully' : 'Job Card updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Job Card: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(activeCustomersFutureProvider);
    final productsAsync = ref.watch(productsStreamProvider(_selectedCustomer?.id));
    final platesAsync = ref.watch(platesStreamProvider(_selectedProduct?.id));
    final diesAsync = ref.watch(diesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.jobCard == null ? 'Issue New Job Card' : 'Edit Job Card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jobCardNoController,
                    decoration: const InputDecoration(labelText: 'Job Card No. *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _poNumberController,
                    decoration: const InputDecoration(labelText: 'PO Number *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.jobCard == null) ...[
              customersAsync.when(
                data: (customers) => DropdownButtonFormField<CustomerModel>(
                  value: _selectedCustomer,
                  decoration: const InputDecoration(labelText: 'Select Customer *'),
                  items: customers
                      .map((c) => DropdownMenuItem(value: c, child: Text('${c.companyName} (${c.customerCode})')))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedCustomer = val;
                    _selectedProduct = null;
                  }),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading customers: $err'),
              ),
              const SizedBox(height: 12),
              productsAsync.when(
                data: (products) => DropdownButtonFormField<ProductModel>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(labelText: 'Select Product SKU *'),
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text('${p.productName} (${p.internalSkuCode})')))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading products: $err'),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetQtyController,
                    decoration: const InputDecoration(labelText: 'Target Order Qty *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _plannedQtyController,
                    decoration: const InputDecoration(labelText: 'Planned Prod Qty (with Waste) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tooling Handover Allocation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            platesAsync.when(
              data: (plates) => DropdownButtonFormField<PlateModel>(
                value: _selectedPlate,
                decoration: const InputDecoration(labelText: 'Assign Plate Code'),
                items: plates
                    .map((p) => DropdownMenuItem(value: p, child: Text('${p.plateCode} (${p.colorCount} Colors, ${p.condition})')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPlate = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading plates: $err'),
            ),
            const SizedBox(height: 12),
            diesAsync.when(
              data: (dies) => DropdownButtonFormField<DieModel>(
                value: _selectedDie,
                decoration: const InputDecoration(labelText: 'Assign Punch/Die Code'),
                items: dies
                    .map((d) => DropdownMenuItem(value: d, child: Text('${d.dieCode} (${d.specLabel})')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDie = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading dies: $err'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Issue Job Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
