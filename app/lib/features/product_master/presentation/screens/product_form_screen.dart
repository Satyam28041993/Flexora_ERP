import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../data/models/product_model.dart';
import '../../logic/product_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product, this.preselectedCustomerId});

  final ProductModel? product;
  final String? preselectedCustomerId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerModel? _selectedCustomer;

  late TextEditingController _skuCodeController;
  late TextEditingController _custProductCodeController;
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;

  // Label Specs
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  String _shape = 'Rectangle';
  late TextEditingController _substrateController;
  late TextEditingController _gsmMicronController;
  String _adhesiveType = 'Permanent';
  String _linerType = 'Glassine';

  // Print Specs
  late TextEditingController _colorCountController;
  late TextEditingController _pantoneController;
  String _printMethod = 'Flexo 8-Color';
  String _varnishType = 'None';
  String _laminationType = 'None';

  // Machine Specs
  late TextEditingController _webWidthController;
  late TextEditingController _repeatCylinderController;
  late TextEditingController _acrossUpsController;
  late TextEditingController _aroundUpsController;
  late TextEditingController _punchDieCodeController;
  late TextEditingController _coreSizeController;
  late TextEditingController _labelsPerRollController;
  String _windingDirection = 'Head First';

  // Flexible Process Route
  late List<String> _processRoute;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _skuCodeController = TextEditingController(text: p?.internalSkuCode ?? '');
    _custProductCodeController = TextEditingController(text: p?.customerProductCode ?? '');
    _productNameController = TextEditingController(text: p?.productName ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');

    _widthController = TextEditingController(text: p?.labelSpec.widthMm.toString() ?? '');
    _heightController = TextEditingController(text: p?.labelSpec.heightMm.toString() ?? '');
    _shape = p?.labelSpec.shape ?? 'Rectangle';
    _substrateController = TextEditingController(text: p?.labelSpec.substrateMaterial ?? 'Chromo Paper');
    _gsmMicronController = TextEditingController(text: p?.labelSpec.gsmMicron ?? '80 GSM');
    _adhesiveType = p?.labelSpec.adhesiveType ?? 'Permanent';
    _linerType = p?.labelSpec.linerType ?? 'Glassine';

    _colorCountController = TextEditingController(text: p?.printSpec.colorCount.toString() ?? '4');
    _pantoneController = TextEditingController(text: p?.printSpec.pantoneCodes ?? '');
    _printMethod = p?.printSpec.printMethod ?? 'Flexo 8-Color';
    _varnishType = p?.printSpec.varnishType ?? 'None';
    _laminationType = p?.printSpec.laminationType ?? 'None';

    _webWidthController = TextEditingController(text: p?.machineSpec.webWidthMm.toString() ?? '220');
    _repeatCylinderController = TextEditingController(text: p?.machineSpec.repeatCylinderMm.toString() ?? '300');
    _acrossUpsController = TextEditingController(text: p?.machineSpec.acrossUps.toString() ?? '2');
    _aroundUpsController = TextEditingController(text: p?.machineSpec.aroundUps.toString() ?? '4');
    _punchDieCodeController = TextEditingController(text: p?.machineSpec.punchDieCode ?? '');
    _coreSizeController = TextEditingController(text: p?.machineSpec.coreSizeMm.toString() ?? '76');
    _labelsPerRollController = TextEditingController(text: p?.machineSpec.labelsPerRoll.toString() ?? '1000');
    _windingDirection = p?.machineSpec.windingDirection ?? 'Head First';

    _processRoute = List<String>.from(p?.processRoute ?? StandardProcessSteps.defaultRoute);
  }

  @override
  void dispose() {
    _skuCodeController.dispose();
    _custProductCodeController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _substrateController.dispose();
    _gsmMicronController.dispose();
    _colorCountController.dispose();
    _pantoneController.dispose();
    _webWidthController.dispose();
    _repeatCylinderController.dispose();
    _acrossUpsController.dispose();
    _aroundUpsController.dispose();
    _punchDieCodeController.dispose();
    _coreSizeController.dispose();
    _labelsPerRollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null && widget.product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Customer for this SKU')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(productRepositoryProvider);

      final productData = ProductModel(
        id: widget.product?.id ?? '',
        plantId: DefaultPlant.id,
        internalSkuCode: _skuCodeController.text.trim().toUpperCase(),
        customerId: _selectedCustomer?.id ?? widget.product!.customerId,
        customerName: _selectedCustomer?.companyName ?? widget.product!.customerName,
        customerProductCode: _custProductCodeController.text.trim(),
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        labelSpec: LabelSpecModel(
          widthMm: double.parse(_widthController.text.trim()),
          heightMm: double.parse(_heightController.text.trim()),
          shape: _shape,
          substrateMaterial: _substrateController.text.trim(),
          gsmMicron: _gsmMicronController.text.trim(),
          adhesiveType: _adhesiveType,
          linerType: _linerType,
        ),
        printSpec: PrintSpecModel(
          colorCount: int.parse(_colorCountController.text.trim()),
          pantoneCodes: _pantoneController.text.trim(),
          printMethod: _printMethod,
          varnishType: _varnishType,
          laminationType: _laminationType,
        ),
        machineSpec: MachineSpecModel(
          webWidthMm: double.parse(_webWidthController.text.trim()),
          repeatCylinderMm: double.parse(_repeatCylinderController.text.trim()),
          acrossUps: int.parse(_acrossUpsController.text.trim()),
          aroundUps: int.parse(_aroundUpsController.text.trim()),
          punchDieCode: _punchDieCodeController.text.trim(),
          coreSizeMm: double.parse(_coreSizeController.text.trim()),
          labelsPerRoll: int.parse(_labelsPerRollController.text.trim()),
          windingDirection: _windingDirection,
        ),
        processRoute: _processRoute,
        currentArtworkVersionId: widget.product?.currentArtworkVersionId,
        currentArtworkStoragePath: widget.product?.currentArtworkStoragePath,
        artworkApprovalStatus: widget.product?.artworkApprovalStatus ?? ArtworkApprovalStatus.pending,
        artworkApprovalDate: widget.product?.artworkApprovalDate,
        status: widget.product?.status ?? ProductStatus.active,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        createdBy: widget.product?.createdBy ?? 'system',
        updatedAt: widget.product != null ? DateTime.now() : null,
        updatedBy: widget.product != null ? 'system' : null,
      );

      if (widget.product == null) {
        await repo.createProduct(productData);
      } else {
        await repo.updateProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Product Master created successfully'
                : 'Product Master updated successfully'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCustomersAsync = ref.watch(activeCustomersFutureProvider);
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product Master' : 'New Product / SKU Master'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('General & Customer Identification'),
            if (!isEdit)
              activeCustomersAsync.when(
                data: (customers) {
                  if (_selectedCustomer == null && customers.isNotEmpty) {
                    if (widget.preselectedCustomerId != null) {
                      final match = customers.where((c) => c.id == widget.preselectedCustomerId);
                      if (match.isNotEmpty) _selectedCustomer = match.first;
                    }
                  }
                  return DropdownButtonFormField<CustomerModel>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(labelText: 'Customer *'),
                    items: customers
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.companyName} (${c.customerCode})'),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCustomer = val),
                    validator: (v) => v == null ? 'Customer is required' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error loading customers: $err', style: const TextStyle(color: AppTheme.danger)),
              )
            else
              Text('Customer: ${widget.product!.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skuCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Internal SKU Code *',
                      hintText: 'e.g. SKU-PG-101',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _custProductCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Product Code',
                      hintText: 'Client-side SKU',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product / Label Name *',
                hintText: 'e.g. 50ml Syrup Front Label',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('1. Label Technical Specification'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(labelText: 'Width (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Valid number required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Valid number required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _shape,
                    decoration: const InputDecoration(labelText: 'Shape'),
                    items: ['Rectangle', 'Circle', 'Oval', 'Custom']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _shape = val);
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
                    controller: _substrateController,
                    decoration: const InputDecoration(labelText: 'Substrate / Face Material *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _gsmMicronController,
                    decoration: const InputDecoration(labelText: 'GSM / Micron'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _adhesiveType,
                    decoration: const InputDecoration(labelText: 'Adhesive Type'),
                    items: ['Permanent', 'Removable', 'Hotmelt', 'Acrylic', 'Deep Freeze']
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _adhesiveType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _linerType,
                    decoration: const InputDecoration(labelText: 'Release Liner'),
                    items: ['Glassine', 'PET Film', 'Kraft Paper']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _linerType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('2. Printing Specification'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _colorCountController,
                    decoration: const InputDecoration(labelText: 'Color Count *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _printMethod,
                    decoration: const InputDecoration(labelText: 'Printing Method'),
                    items: ['Flexo 8-Color', 'UV Flexo', 'Digital']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _printMethod = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pantoneController,
              decoration: const InputDecoration(
                labelText: 'Pantone / Color Shades',
                hintText: 'e.g. Cyan, Magenta, Yellow, Black, Pantone 185 C',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _varnishType,
                    decoration: const InputDecoration(labelText: 'Varnish'),
                    items: ['None', 'Gloss UV', 'Matt UV', 'Drip Off', 'Water-based']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _varnishType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _laminationType,
                    decoration: const InputDecoration(labelText: 'Lamination'),
                    items: ['None', 'Thermal Gloss', 'Thermal Matt', 'Cold Foil']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _laminationType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('3. Machine & Conversion Specification'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _webWidthController,
                    decoration: const InputDecoration(labelText: 'Web Width (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _repeatCylinderController,
                    decoration: const InputDecoration(labelText: 'Cylinder Repeat (mm) *'),
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
                    controller: _acrossUpsController,
                    decoration: const InputDecoration(labelText: 'Across UPS *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _aroundUpsController,
                    decoration: const InputDecoration(labelText: 'Around UPS *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _punchDieCodeController,
                    decoration: const InputDecoration(labelText: 'Punch/Die Code'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _coreSizeController,
                    decoration: const InputDecoration(labelText: 'Core Size (mm)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _labelsPerRollController,
                    decoration: const InputDecoration(labelText: 'Labels Per Roll'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _windingDirection,
                    decoration: const InputDecoration(labelText: 'Winding Direction'),
                    items: ['Head First', 'Foot First', 'Left First', 'Right First']
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _windingDirection = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('4. Flexible Production Process Route'),
            const Text(
              'Select & sequence the manufacturing steps required for this product:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StandardProcessSteps.allSteps.map((step) {
                final isSelected = _processRoute.contains(step);
                return FilterChip(
                  label: Text(step),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _processRoute.add(step);
                      } else {
                        _processRoute.remove(step);
                      }
                    });
                  },
                  selectedColor: AppTheme.primary.withAlpha(50),
                  checkmarkColor: AppTheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : (isEdit ? 'Update Product Master' : 'Save Product Master')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
