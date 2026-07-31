import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../../shade_card_master/logic/shade_card_providers.dart';

class RepeatOrderDialog extends ConsumerStatefulWidget {
  const RepeatOrderDialog({super.key});

  @override
  ConsumerState<RepeatOrderDialog> createState() => _RepeatOrderDialogState();
}

class _RepeatOrderDialogState extends ConsumerState<RepeatOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  ProductModel? _selectedProduct;

  late TextEditingController _poNumberController;
  late TextEditingController _orderQtyController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _poNumberController = TextEditingController(text: 'REPEAT-PO-2026');
    _orderQtyController = TextEditingController(text: '10000');
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _orderQtyController.dispose();
    super.dispose();
  }

  Future<void> _createRepeatJobCard() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Product SKU')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(jobCardRepositoryProvider);
      final targetQty = double.parse(_orderQtyController.text.trim());

      final newJobCard = JobCardModel(
        id: '',
        plantId: DefaultPlant.id,
        jobCardNo: 'JC-R-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
        orderId: 'repeat-order-po',
        poNumber: _poNumberController.text.trim().toUpperCase(),
        customerId: _selectedProduct!.customerId,
        customerName: _selectedProduct!.customerName,
        productId: _selectedProduct!.id,
        internalSkuCode: _selectedProduct!.internalSkuCode,
        productName: _selectedProduct!.productName,
        targetOrderQty: targetQty,
        plannedProductionQty: targetQty * 1.05, // 5% setup/running waste allowance
        processRoute: _selectedProduct!.processRoute,
        status: JobCardStatus.draft,
        createdAt: DateTime.now(),
        createdBy: 'repeat_engine',
      );

      await repo.createJobCard(newJobCard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Repeat Job Card issued for ${_selectedProduct!.internalSkuCode}')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating repeat job: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(null));

    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.autorenew, color: AppTheme.primary),
          SizedBox(width: 8),
          Text('Repeat Order Automation'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auto-link approved artwork, flexo specs, tooling, and shade references from previous runs:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              productsAsync.when(
                data: (products) => DropdownButtonFormField<ProductModel>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(labelText: 'Select Approved SKU *'),
                  items: products
                      .map((p) => DropdownMenuItem(value: p, child: Text('${p.productName} (${p.internalSkuCode})')))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading SKUs: $err'),
              ),
              if (_selectedProduct != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inherited Technical Specs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade900)),
                      const SizedBox(height: 4),
                      Text('• Dimensions: ${_selectedProduct!.labelSpec.dimensionsText}', style: const TextStyle(fontSize: 12)),
                      Text('• Material: ${_selectedProduct!.labelSpec.substrateMaterial}', style: const TextStyle(fontSize: 12)),
                      Text('• Colors: ${_selectedProduct!.printSpec.colorCount} Colors (${_selectedProduct!.printSpec.printMethod})', style: const TextStyle(fontSize: 12)),
                      Text('• Route: ${_selectedProduct!.processRoute.join(" -> ")}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final approvedShadeAsync = ref.watch(approvedShadeForProductFutureProvider(_selectedProduct!.id));
                    return approvedShadeAsync.when(
                      data: (shade) {
                        if (shade == null) {
                          return const Text('Note: No approved permanent Shade Reference found for this SKU yet.',
                              style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic));
                        }
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified, color: Colors.green, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'APPROVED SHADE REFERENCE AVAILABLE',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => const SizedBox.shrink(),
                    );
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _poNumberController,
                decoration: const InputDecoration(labelText: 'New Repeat PO Number *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orderQtyController,
                decoration: const InputDecoration(labelText: 'Repeat Order Quantity (Pcs) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _createRepeatJobCard,
          icon: const Icon(Icons.autorenew),
          label: Text(_isSaving ? 'Issuing...' : 'Issue Repeat Job Card'),
        ),
      ],
    );
  }
}
