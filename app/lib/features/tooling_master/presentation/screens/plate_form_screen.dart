import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../data/models/plate_model.dart';
import '../../logic/tooling_providers.dart';

class PlateFormScreen extends ConsumerStatefulWidget {
  const PlateFormScreen({super.key, this.plate});

  final PlateModel? plate;

  @override
  ConsumerState<PlateFormScreen> createState() => _PlateFormScreenState();
}

class _PlateFormScreenState extends ConsumerState<PlateFormScreen> {
  final _formKey = GlobalKey<FormState>();

  ProductModel? _selectedProduct;

  late TextEditingController _codeController;
  late TextEditingController _colorCountController;
  late TextEditingController _colorDetailsController;
  late TextEditingController _revisionTagController;
  late TextEditingController _remadeColorsController;
  late TextEditingController _thicknessController;
  late TextEditingController _repeatController;
  late TextEditingController _rackBinController;

  String _condition = PlateCondition.good;
  String _status = PlateStatus.available;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.plate;

    _codeController = TextEditingController(text: p?.plateCode ?? '');
    _colorCountController = TextEditingController(text: p?.colorCount.toString() ?? '4');
    _colorDetailsController = TextEditingController(text: p?.colorDetails ?? 'Cyan, Magenta, Yellow, Black');
    _revisionTagController = TextEditingController(text: p?.revisionTag ?? 'Rev 1');
    _remadeColorsController = TextEditingController(text: p?.remadeColors ?? '');
    _thicknessController = TextEditingController(text: p?.polymerThicknessMm.toString() ?? '1.14');
    _repeatController = TextEditingController(text: p?.cylinderRepeatMm.toString() ?? '300');
    _rackBinController = TextEditingController(text: p?.storageRackBin ?? 'Rack P-1');

    _condition = p?.condition ?? PlateCondition.good;
    _status = p?.status ?? PlateStatus.available;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _colorCountController.dispose();
    _colorDetailsController.dispose();
    _revisionTagController.dispose();
    _remadeColorsController.dispose();
    _thicknessController.dispose();
    _repeatController.dispose();
    _rackBinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null && widget.plate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Product SKU for this Plate')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(toolingRepositoryProvider);

      final plateData = PlateModel(
        id: widget.plate?.id ?? '',
        plantId: DefaultPlant.id,
        plateCode: _codeController.text.trim().toUpperCase(),
        customerId: _selectedProduct?.customerId ?? widget.plate!.customerId,
        customerName: _selectedProduct?.customerName ?? widget.plate!.customerName,
        productId: _selectedProduct?.id ?? widget.plate!.productId,
        internalSkuCode: _selectedProduct?.internalSkuCode ?? widget.plate!.internalSkuCode,
        productName: _selectedProduct?.productName ?? widget.plate!.productName,
        artworkVersionId: _selectedProduct?.currentArtworkVersionId ?? widget.plate?.artworkVersionId ?? '',
        artworkVersionLabel: 'v1',
        colorCount: int.parse(_colorCountController.text.trim()),
        colorDetails: _colorDetailsController.text.trim(),
        revisionTag: _revisionTagController.text.trim(),
        remadeColors: _remadeColorsController.text.trim(),
        polymerThicknessMm: double.parse(_thicknessController.text.trim()),
        cylinderRepeatMm: double.parse(_repeatController.text.trim()),
        storageRackBin: _rackBinController.text.trim(),
        condition: _condition,
        status: _status,
        createdAt: widget.plate?.createdAt ?? DateTime.now(),
        createdBy: widget.plate?.createdBy ?? 'system',
        updatedAt: widget.plate != null ? DateTime.now() : null,
        updatedBy: widget.plate != null ? 'system' : null,
      );

      if (widget.plate == null) {
        await repo.createPlate(plateData);
      } else {
        await repo.updatePlate(plateData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.plate == null ? 'Plate registered successfully' : 'Plate updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plate: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider(null));

    return Scaffold(
      appBar: AppBar(title: Text(widget.plate == null ? 'New Plate Master' : 'Edit Plate Master')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.plate == null)
              productsAsync.when(
                data: (products) {
                  return DropdownButtonFormField<ProductModel>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(labelText: 'Link Product SKU *'),
                    items: products
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.productName} (${p.internalSkuCode})'),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedProduct = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Plate Code *', hintText: 'e.g. PL-SKU-101-A'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colorCountController,
                    decoration: const InputDecoration(labelText: 'Colors Count *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _thicknessController,
                    decoration: const InputDecoration(labelText: 'Polymer Thickness (mm)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _repeatController,
                    decoration: const InputDecoration(labelText: 'Cylinder Repeat (mm)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rackBinController,
                    decoration: const InputDecoration(labelText: 'Storage Location / Rack'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorDetailsController,
              decoration: const InputDecoration(
                labelText: 'Color Breakdown List',
                hintText: 'e.g. Cyan, Magenta, Yellow, Black, Spot P353C',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _revisionTagController,
                    decoration: const InputDecoration(
                      labelText: 'Revision Tag / Suffix',
                      hintText: 'e.g. Rev 1, Rev 2',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _remadeColorsController,
                    decoration: const InputDecoration(
                      labelText: 'Remade / Changed Colors',
                      hintText: 'e.g. Black (Text Change)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Partial Remake Quick Action
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build_circle_outlined, color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Plate Correction (Colors Changed)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Click button if color plates were remade due to text/design corrections.', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _condition = PlateCondition.partialRemake;
                        _revisionTagController.text = 'Rev 2 (Colors Changed)';
                        if (_remadeColorsController.text.isEmpty) {
                          _remadeColorsController.text = 'Black Plate Remade';
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as Partial Remake (Rev 2). Specify changed colors above.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                    child: const Text('Mark Colors Remade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _condition,
                    decoration: const InputDecoration(labelText: 'Plate Condition'),
                    items: PlateCondition.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _condition = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: PlateStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
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
                label: Text(_isSaving ? 'Saving...' : 'Save Plate Master'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
