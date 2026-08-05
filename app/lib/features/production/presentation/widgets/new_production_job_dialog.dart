import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/constants/production_formulas.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../customer_master/presentation/screens/customer_form_screen.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../../product_master/presentation/screens/product_form_screen.dart';
import '../../../rm_ledger/data/models/rm_master_constants.dart';
import '../../data/models/production_job_model.dart';
import '../../logic/production_providers.dart';

class NewProductionJobDialog extends ConsumerStatefulWidget {
  const NewProductionJobDialog({super.key, this.initialJob});

  final ProductionJobModel? initialJob;

  @override
  ConsumerState<NewProductionJobDialog> createState() => _NewProductionJobDialogState();
}

class _NewProductionJobDialogState extends ConsumerState<NewProductionJobDialog> {
  final _formKey = GlobalKey<FormState>();

  JobCardModel? _selectedJobCard;
  CustomerModel? _selectedCustomer;
  ProductModel? _selectedProduct;

  late TextEditingController _jobDocNoController;
  late TextEditingController _clientNameController;
  late TextEditingController _poNoController;
  late TextEditingController _matDescController;
  late TextEditingController _reqQtyController;
  late TextEditingController _gearController;
  late TextEditingController _upsController;
  late TextEditingController _paperSizeController;
  late TextEditingController _materialController;
  late TextEditingController _labelSizeController;
  late TextEditingController _plantLocController;
  late TextEditingController _wastageRmtController;

  String _pendingSubStatus = PendingSubStatus.newPending;
  String _lamination = 'No';
  String _foil = 'No';
  String _paperStatus = 'Available';

  DateTime _orderDate = DateTime.now();
  DateTime? _poDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final j = widget.initialJob;

    _jobDocNoController = TextEditingController(text: j?.jobDocNo ?? '');
    _clientNameController = TextEditingController(text: j?.clientName ?? '');
    _poNoController = TextEditingController(text: j?.poNumber ?? '');
    _matDescController = TextEditingController(text: j?.materialDescription ?? '');
    _reqQtyController = TextEditingController(text: j?.totalReqQty.toString() ?? '10000');
    _gearController = TextEditingController(text: j?.gearTeethCount.toString() ?? '75');
    _upsController = TextEditingController(text: j?.ups.toString() ?? '2');
    _paperSizeController = TextEditingController(text: j?.paperSizeMm.toString() ?? '195');
    _materialController = TextEditingController(text: j?.substrateMaterial ?? 'CHROMO');
    _labelSizeController = TextEditingController(text: j?.labelSize ?? '180 X 117');
    _plantLocController = TextEditingController(text: j?.plantLocation ?? 'MAIN');
    _wastageRmtController = TextEditingController(text: j?.wastageRmt.toString() ?? '300');

    _pendingSubStatus = j?.pendingSubStatus ?? PendingSubStatus.newPending;
    _lamination = j?.lamination ?? 'No';
    _foil = j?.foil ?? 'No';
    _paperStatus = j?.paperStatus ?? 'Available';
    _orderDate = j?.orderDate ?? DateTime.now();
    _poDate = j?.poDate;
  }

  @override
  void dispose() {
    _jobDocNoController.dispose();
    _clientNameController.dispose();
    _poNoController.dispose();
    _matDescController.dispose();
    _reqQtyController.dispose();
    _gearController.dispose();
    _upsController.dispose();
    _paperSizeController.dispose();
    _materialController.dispose();
    _labelSizeController.dispose();
    _plantLocController.dispose();
    _wastageRmtController.dispose();
    super.dispose();
  }

  // Live Formula Calculations
  double get _calcRepeatInches {
    final gear = double.tryParse(_gearController.text.trim()) ?? 0;
    return gear > 0 ? gear / 8.0 : 0.0;
  }

  double get _calcLpMeter {
    final gear = double.tryParse(_gearController.text.trim()) ?? 0;
    final ups = double.tryParse(_upsController.text.trim()) ?? 0;
    return ProductionFormulas.labelsPerMetre(gearTeethZ: gear, ups: ups);
  }

  double get _calcReqRmt {
    final qty = double.tryParse(_reqQtyController.text.trim()) ?? 0;
    final lp = _calcLpMeter;
    if (lp <= 0) return 0.0;
    return qty / lp;
  }

  double get _calcTotalRmtWithWastage {
    final wastage = double.tryParse(_wastageRmtController.text.trim()) ?? 300.0;
    return _calcReqRmt + wastage;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(productionRepositoryProvider);

      String docNo = _jobDocNoController.text.trim();
      if (docNo.isEmpty && widget.initialJob == null) {
        docNo = await repo.generateNextJobDocNo(DefaultPlant.id);
      }

      final jobData = ProductionJobModel(
        id: widget.initialJob?.id ?? '',
        plantId: DefaultPlant.id,
        jobDocNo: docNo,
        clientName: _clientNameController.text.trim(),
        orderDate: _orderDate,
        poNumber: _poNoController.text.trim(),
        poDate: _poDate,
        materialDescription: _matDescController.text.trim(),
        totalReqQty: double.parse(_reqQtyController.text.trim()),
        gearTeethCount: int.parse(_gearController.text.trim()),
        ups: int.parse(_upsController.text.trim()),
        paperSizeMm: double.parse(_paperSizeController.text.trim()),
        substrateMaterial: _materialController.text.trim(),
        labelSize: _labelSizeController.text.trim(),
        plantLocation: _plantLocController.text.trim(),
        wastageRmt: double.tryParse(_wastageRmtController.text.trim()) ?? 300.0,
        pendingSubStatus: _pendingSubStatus,
        paperStatus: _paperStatus,
        lamination: _lamination,
        foil: _foil,
        currentStage: widget.initialJob?.currentStage ?? ProductionStage.pending,
        createdAt: widget.initialJob?.createdAt ?? DateTime.now(),
        createdBy: widget.initialJob?.createdBy ?? 'system',
      );

      if (widget.initialJob == null) {
        await repo.createProductionJob(jobData);
      } else {
        await repo.updateProductionJob(jobData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialJob == null ? 'Production Job Order created successfully' : 'Job updated successfully'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving production job: $e'), backgroundColor: AppTheme.danger),
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
    final nextDocNoAsync = ref.watch(nextJobDocNoFutureProvider);

    final dateFormat = DateFormat('dd-MM-yyyy');
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 850,
          maxHeight: screenHeight * 0.88,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialJob == null ? '➕ New Production Order Entry' : 'Edit Production Job Order',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // 1. Job Card Auto-Fill Selection Dropdown
                Consumer(
                  builder: (context, ref, child) {
                    final jobCardsAsync = ref.watch(jobCardsStreamProvider);
                    return jobCardsAsync.when(
                      data: (jobCards) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.assignment, color: AppTheme.primary, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Select Issued Job Card (Auto-Fill Production Entry)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Autocomplete<JobCardModel>(
                                displayStringForOption: (j) => '${j.jobCardNo} - ${j.productName} (${j.customerName})',
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return jobCards;
                                  }
                                  final q = textEditingValue.text.toLowerCase();
                                  return jobCards.where((j) =>
                                      j.jobCardNo.toLowerCase().contains(q) ||
                                      j.productName.toLowerCase().contains(q) ||
                                      j.customerName.toLowerCase().contains(q) ||
                                      j.poNumber.toLowerCase().contains(q));
                                },
                                onSelected: (j) {
                                  setState(() {
                                    _selectedJobCard = j;
                                    _jobDocNoController.text = j.jobCardNo;
                                    _clientNameController.text = j.customerName;
                                    _poNoController.text = j.poNumber;
                                    _matDescController.text = j.productName;
                                    _reqQtyController.text = j.targetOrderQty.toString();
                                    if (j.ups > 0) _upsController.text = j.ups.toString();
                                    if (j.paperSize > 0) _paperSizeController.text = j.paperSize.toString();
                                    _labelSizeController.text = '${j.paperSize.toInt()} mm';
                                  });
                                },
                                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                  if (_selectedJobCard != null && controller.text.isEmpty) {
                                    controller.text = '${_selectedJobCard!.jobCardNo} - ${_selectedJobCard!.productName} (${_selectedJobCard!.customerName})';
                                  }
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: '🔍 Search & Select Job Card (by Job Card No, Product Name, Customer)',
                                      hintText: 'Type 08/013 or PANIDA...',
                                      prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  );
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 250),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final j = options.elementAt(index);
                                            return ListTile(
                                              leading: const Icon(Icons.assignment, color: AppTheme.primary),
                                              title: Text('${j.jobCardNo} - ${j.productName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              subtitle: Text('${j.customerName} | Target Qty: ${j.targetOrderQty.toInt()} pcs | PO: ${j.poNumber}', style: const TextStyle(fontSize: 11)),
                                              onTap: () => onSelected(j),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Customer & Product Link Pickers WITH SHORTCUT '+' BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: customersAsync.when(
                              data: (customers) {
                                return DropdownButtonFormField<CustomerModel>(
                                  isExpanded: true,
                                  value: _selectedCustomer,
                                  decoration: const InputDecoration(labelText: 'Select Customer / Client'),
                                  items: customers
                                      .map((c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(c.companyName, overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (c) {
                                    setState(() {
                                      _selectedCustomer = c;
                                      if (c != null) _clientNameController.text = c.companyName;
                                    });
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (err, _) => Text('Error loading customers: $err'),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 26),
                            tooltip: 'Quick Add Customer Master',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
                              );
                              ref.invalidate(activeCustomersFutureProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: productsAsync.when(
                              data: (products) {
                                return DropdownButtonFormField<ProductModel>(
                                  isExpanded: true,
                                  value: _selectedProduct,
                                  decoration: const InputDecoration(labelText: 'Select Product SKU (Auto-Fill)'),
                                  items: products
                                      .map((p) => DropdownMenuItem(
                                            value: p,
                                            child: Text('${p.productName} (${p.internalSkuCode})', overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (p) {
                                    setState(() {
                                      _selectedProduct = p;
                                      if (p != null) {
                                        _matDescController.text = p.productName;
                                        _substrateMaterialControllerText(p.labelSpec.substrateMaterial);
                                        if (p.machineSpec.webWidthMm > 0) _paperSizeController.text = p.machineSpec.webWidthMm.toString();
                                        if (p.machineSpec.totalUps > 0) _upsController.text = p.machineSpec.totalUps.toString();
                                      }
                                    });
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (err, _) => Text('Error loading products: $err'),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 26),
                            tooltip: 'Quick Add Product SKU Master',
                            onPressed: () async {
                              final newProduct = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductFormScreen(
                                    preselectedCustomerId: _selectedCustomer?.id,
                                  ),
                                ),
                              );
                              ref.invalidate(productsStreamProvider(_selectedCustomer?.id));
                              if (newProduct != null && newProduct is ProductModel) {
                                setState(() {
                                  _selectedProduct = newProduct;
                                  _matDescController.text = newProduct.productName;
                                  _substrateMaterialControllerText(newProduct.labelSpec.substrateMaterial);
                                  if (newProduct.machineSpec.webWidthMm > 0) _paperSizeController.text = newProduct.machineSpec.webWidthMm.toString();
                                  if (newProduct.machineSpec.totalUps > 0) _upsController.text = newProduct.machineSpec.totalUps.toString();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Job Doc No & Client Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jobDocNoController,
                        decoration: InputDecoration(
                          labelText: 'Job Doc No *',
                          hintText: nextDocNoAsync.when(data: (no) => 'Auto: $no', loading: () => 'Loading...', error: (_, __) => 'e.g. 06/021'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _clientNameController,
                        decoration: const InputDecoration(labelText: 'Client Name *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // PO Number, PO Date, Plant Location
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _poNoController,
                        decoration: const InputDecoration(labelText: 'PO Number'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _poDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _poDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'PO Date'),
                          child: Text(_poDate != null ? dateFormat.format(_poDate!) : 'Select Date'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _plantLocController,
                        decoration: const InputDecoration(labelText: 'Plant Location', hintText: 'e.g. DAMAN, AKOLA'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _matDescController,
                  decoration: const InputDecoration(labelText: 'Material Description / Job Name *', hintText: 'e.g. LEAFLET OF ECL ZENATANE'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Qty, Gear, Ups, Paper Size
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _reqQtyController,
                        decoration: const InputDecoration(labelText: 'Total Req Qty *'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _gearController,
                        decoration: const InputDecoration(labelText: 'Gear (Z Teeth) *'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _upsController,
                        decoration: const InputDecoration(labelText: 'UPS *'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _paperSizeController,
                        decoration: const InputDecoration(labelText: 'Paper Size (mm) *'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Material, Label Size, Wastage RMT, Sub-Status
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: RmMasterConstants.materials.contains(_materialController.text.trim())
                            ? _materialController.text.trim()
                            : RmMasterConstants.materials.first,
                        decoration: const InputDecoration(labelText: 'Substrate Material *'),
                        items: RmMasterConstants.materials
                            .map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _materialController.text = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _labelSizeController,
                        decoration: const InputDecoration(labelText: 'Label Size', hintText: '110 X 80'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _wastageRmtController,
                        decoration: const InputDecoration(labelText: 'Wastage RMT (Default 300) *'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _pendingSubStatus,
                        decoration: const InputDecoration(labelText: 'Pending Sub-Status *'),
                        items: PendingSubStatus.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _pendingSubStatus = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // LIVE MATH FORMULAS SUMMARY CARD
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Repeat (Inches)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text('${_calcRepeatInches.toStringAsFixed(3)}"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            const Text('L.P. Meter (Formula)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text(_calcLpMeter.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            const Text('Net Req RMT', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text('${_calcReqRmt.toStringAsFixed(1)} RMT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green.shade800)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            const Text('Wastage RMT', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text('+${double.tryParse(_wastageRmtController.text.trim()) ?? 300.0} RMT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(6)),
                          child: Column(
                            children: [
                              const Text('Total RMT (with Wastage)', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                              Text('${_calcTotalRmtWithWastage.toStringAsFixed(1)} RMT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Saving Order...' : 'Save & Issue Production Order', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _substrateMaterialControllerText(String mat) {
    if (mat.isNotEmpty) _materialController.text = mat;
  }
}
