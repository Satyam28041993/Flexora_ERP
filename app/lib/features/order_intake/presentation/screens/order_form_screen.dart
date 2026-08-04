import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../data/models/order_model.dart';
import '../../logic/order_providers.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key, this.order});

  final OrderModel? order;

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  CustomerModel? _selectedCustomer;

  late TextEditingController _poNumberController;
  late TextEditingController _shippingAddressController;
  late TextEditingController _specialNotesController;
  late TextEditingController _oneTimePunchCostController;
  late TextEditingController _freightChargesController;

  DateTime _poDate = DateTime.now();
  int _paymentTermsDays = 30;
  double _gstRatePercent = 18.0;

  // Multi-Line Items State
  final List<_LineItemRowState> _lineItemRows = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.order;

    _poNumberController = TextEditingController(text: o?.poNumber ?? '');
    _shippingAddressController = TextEditingController(text: o?.shippingAddress ?? '');
    _specialNotesController = TextEditingController(text: o?.specialNotes ?? '');
    _oneTimePunchCostController = TextEditingController(text: o?.oneTimePunchCost.toString() ?? '0.0');
    _freightChargesController = TextEditingController(text: o?.freightCharges.toString() ?? '0.0');

    if (o != null) {
      _poDate = o.poDate;
      _paymentTermsDays = o.paymentTermsDays;
      _gstRatePercent = o.gstRatePercent;

      for (var item in o.lineItems) {
        _lineItemRows.add(_LineItemRowState.fromModel(item));
      }
    } else {
      _lineItemRows.add(_LineItemRowState.empty());
    }
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _shippingAddressController.dispose();
    _specialNotesController.dispose();
    _oneTimePunchCostController.dispose();
    _freightChargesController.dispose();
    for (var r in _lineItemRows) {
      r.dispose();
    }
    super.dispose();
  }

  /// 1-Click Quick Add SKU Dialog to Sync Line Item directly to SKU Master Database
  Future<void> _openQuickAddSkuDialog(int rowIndex) async {
    final row = _lineItemRows[rowIndex];

    final codeCtrl = TextEditingController(
      text: row.ourSkuCodeController.text.isNotEmpty
          ? row.ourSkuCodeController.text
          : 'SKU-${_selectedCustomer?.companyName.substring(0, 3).toUpperCase() ?? 'GEN'}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    final clientCodeCtrl = TextEditingController(text: row.clientSkuCodeController.text);
    final nameCtrl = TextEditingController(text: row.itemNameController.text);
    final widthCtrl = TextEditingController(text: row.widthController.text.isEmpty ? '100' : row.widthController.text);
    final heightCtrl = TextEditingController(text: row.heightController.text.isEmpty ? '150' : row.heightController.text);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.add_box, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Quick Add & Register SKU in Master'),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Register a new SKU into SKU Master Catalog with basic info. Detailed technical specs (Gear Z, UPS, Substrates) can be edited later in SKU Master screen.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Our Internal SKU Code *'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: clientCodeCtrl,
                  decoration: const InputDecoration(labelText: 'Client Product Code (Optional)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product / Label Name *'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: widthCtrl,
                        decoration: const InputDecoration(labelText: 'Width (mm)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: heightCtrl,
                        decoration: const InputDecoration(labelText: 'Height (mm)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            onPressed: () async {
              final skuCode = codeCtrl.text.trim();
              final prodName = nameCtrl.text.trim();
              if (skuCode.isEmpty || prodName.isEmpty) return;

              final w = double.tryParse(widthCtrl.text.trim()) ?? 100.0;
              final h = double.tryParse(heightCtrl.text.trim()) ?? 150.0;

              final productModel = ProductModel(
                id: '',
                plantId: DefaultPlant.id,
                internalSkuCode: skuCode,
                customerId: _selectedCustomer?.id ?? 'gen-cust',
                customerName: _selectedCustomer?.companyName ?? 'General Customer',
                customerProductCode: clientCodeCtrl.text.trim(),
                productName: prodName,
                description: 'Quick synced from PO Order Intake',
                labelSpec: LabelSpecModel(
                  widthMm: w,
                  heightMm: h,
                  substrateMaterial: 'Self-Adhesive Chromo Paper 80 GSM',
                ),
                printSpec: const PrintSpecModel(colorCount: 4),
                machineSpec: MachineSpecModel(
                  webWidthMm: w + 10.0,
                  repeatCylinderMm: 254.0,
                  acrossUps: 2,
                  aroundUps: 1,
                ),
                processRoute: StandardProcessSteps.defaultRoute,
                artworkApprovalStatus: 'approved',
                createdAt: DateTime.now(),
                createdBy: 'po_intake_sync',
              );

              final repo = ref.read(productRepositoryProvider);
              await repo.createProduct(productModel);

              setState(() {
                row.selectedProduct = productModel;
                row.ourSkuCodeController.text = skuCode;
                row.clientSkuCodeController.text = clientCodeCtrl.text.trim();
                row.itemNameController.text = prodName;
                row.widthController.text = w.toString();
                row.heightController.text = h.toString();
              });

              if (mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registered SKU [$skuCode] to SKU Master Catalog successfully!'),
                    backgroundColor: AppTheme.accentEmerald,
                  ),
                );
              }
            },
            icon: const Icon(Icons.sync),
            label: const Text('Save & Select SKU'),
          ),
        ],
      ),
    );
  }

  double get _taxableSubtotal {
    double total = 0.0;
    for (var r in _lineItemRows) {
      total += r.lineAmount;
    }
    return total;
  }

  double get _punchCost => double.tryParse(_oneTimePunchCostController.text.trim()) ?? 0.0;
  double get _freightCost => double.tryParse(_freightChargesController.text.trim()) ?? 0.0;

  double get _gstAmount => (_taxableSubtotal + _punchCost + _freightCost) * (_gstRatePercent / 100.0);
  double get _grandTotal => _taxableSubtotal + _punchCost + _freightCost + _gstAmount;

  void _addLineItemRow() {
    setState(() {
      _lineItemRows.add(_LineItemRowState.empty());
    });
  }

  void _removeLineItemRow(int index) {
    if (_lineItemRows.length <= 1) return;
    setState(() {
      _lineItemRows[index].dispose();
      _lineItemRows.removeAt(index);
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null && widget.order == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Customer')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(orderRepositoryProvider);

      final lineItemModels = _lineItemRows.asMap().entries.map((e) {
        final idx = e.key;
        final row = e.value;
        return OrderLineItemModel(
          id: row.id,
          itemNo: idx + 1,
          itemName: row.itemNameController.text.trim(),
          labelDescription: row.descController.text.trim(),
          sizeWidthMm: double.tryParse(row.widthController.text.trim()) ?? 0.0,
          sizeHeightMm: double.tryParse(row.heightController.text.trim()) ?? 0.0,
          hsnCode: row.hsnController.text.trim().isEmpty ? '48211020' : row.hsnController.text.trim(),
          ourSkuCode: row.ourSkuCodeController.text.trim(),
          customerSkuCode: row.clientSkuCodeController.text.trim(),
          quantityPcs: double.tryParse(row.qtyController.text.trim()) ?? 0.0,
          unitRateRs: double.tryParse(row.rateController.text.trim()) ?? 0.0,
          lineAmountRs: row.lineAmount,
        );
      }).toList();

      final orderData = OrderModel(
        id: widget.order?.id ?? '',
        plantId: DefaultPlant.id,
        poNumber: _poNumberController.text.trim(),
        poDate: _poDate,
        customerId: _selectedCustomer?.id ?? widget.order?.customerId ?? '',
        customerName: _selectedCustomer?.companyName ?? widget.order?.customerName ?? '',
        customerGstNo: _selectedCustomer?.gstNo ?? widget.order?.customerGstNo ?? '',
        shippingAddress: _shippingAddressController.text.trim(),
        lineItems: lineItemModels,
        taxableSubtotal: _taxableSubtotal,
        grandTotalAmount: _grandTotal,
        paymentTermsDays: _paymentTermsDays,
        oneTimePunchCost: _punchCost,
        freightCharges: _freightCost,
        gstRatePercent: _gstRatePercent,
        specialNotes: _specialNotesController.text.trim(),
        createdAt: widget.order?.createdAt ?? DateTime.now(),
        createdBy: widget.order?.createdBy ?? 'system',
      );

      if (widget.order == null) {
        await repo.createOrder(orderData);
      } else {
        await repo.updateOrder(orderData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.order == null ? 'Purchase Order registered successfully' : 'PO updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PO: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider(_selectedCustomer?.id));
    final products = productsAsync.value ?? [];
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Order Received Entry (New PO)' : 'Edit Purchase Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Section 1: PO Header & Customer Selection
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PO Header & Customer Info',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: customersAsync.when(
                            data: (customers) {
                              if (_selectedCustomer == null && widget.order != null) {
                                try {
                                  _selectedCustomer = customers.firstWhere((c) => c.id == widget.order!.customerId);
                                } catch (_) {}
                              }
                              return DropdownButtonFormField<CustomerModel>(
                                isExpanded: true,
                                value: _selectedCustomer,
                                decoration: const InputDecoration(labelText: 'Customer / Billing Party *', prefixIcon: Icon(Icons.business)),
                                items: customers
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c.companyName, overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCustomer = val;
                                    if (val != null && val.shippingAddresses.isNotEmpty) {
                                      _shippingAddressController.text =
                                          '${val.shippingAddresses.first.addressLine1}, ${val.shippingAddresses.first.city}';
                                    }
                                  });
                                },
                                validator: (v) => v == null ? 'Customer is required' : null,
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error loading customers: $e'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _poNumberController,
                            decoration: const InputDecoration(labelText: 'PO Number *', prefixIcon: Icon(Icons.receipt)),
                            validator: (v) => v == null || v.trim().isEmpty ? 'PO Number is required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _poDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) setState(() => _poDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'PO Date *', suffixIcon: Icon(Icons.calendar_today)),
                              child: Text(dateFormat.format(_poDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _paymentTermsDays,
                            decoration: const InputDecoration(labelText: 'Payment Terms'),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Advance Payment')),
                              DropdownMenuItem(value: 7, child: Text('7 Days Credit')),
                              DropdownMenuItem(value: 15, child: Text('15 Days Credit')),
                              DropdownMenuItem(value: 30, child: Text('30 Days Credit')),
                              DropdownMenuItem(value: 45, child: Text('45 Days Credit')),
                              DropdownMenuItem(value: 60, child: Text('60 Days Credit')),
                            ],
                            onChanged: (val) => setState(() => _paymentTermsDays = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _shippingAddressController,
                      decoration: const InputDecoration(labelText: 'Shipping / Consignee Address *', prefixIcon: Icon(Icons.location_on)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Shipping address required' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: PO Line Items Breakdown (Searchable SKU Dropdown + Manual Rates)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PO Line Items (Label SKUs Breakdown)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                OutlinedButton.icon(
                  onPressed: _addLineItemRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Label Item'),
                ),
              ],
            ),
            const Divider(),

            ..._lineItemRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Searchable SKU Dropdown + Quick Add SKU Button
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primary.withAlpha(30),
                            child: Text('${idx + 1}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<ProductModel>(
                              isExpanded: true,
                              value: row.selectedProduct,
                              decoration: const InputDecoration(
                                labelText: 'Select Product SKU (Search by SKU Code or Label Name) *',
                                prefixIcon: Icon(Icons.search),
                              ),
                              items: products.map((p) {
                                final clientCodeStr = p.customerProductCode.isNotEmpty ? ' [${p.customerProductCode}]' : '';
                                return DropdownMenuItem<ProductModel>(
                                  value: p,
                                  child: Text(
                                    '${p.internalSkuCode} - ${p.productName}$clientCodeStr',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    row.selectedProduct = val;
                                    row.itemNameController.text = val.productName;
                                    row.ourSkuCodeController.text = val.internalSkuCode;
                                    row.clientSkuCodeController.text = val.customerProductCode;
                                    row.widthController.text = val.labelSpec.widthMm.toString();
                                    row.heightController.text = val.labelSpec.heightMm.toString();
                                  });
                                }
                              },
                              validator: (v) => (row.itemNameController.text.trim().isEmpty && v == null) ? 'Select a SKU or add new' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                            onPressed: () => _openQuickAddSkuDialog(idx),
                            icon: const Icon(Icons.add_box, size: 16),
                            label: const Text('➕ Add New SKU'),
                          ),
                          const SizedBox(width: 8),
                          if (_lineItemRows.length > 1)
                            IconButton(
                              onPressed: () => _removeLineItemRow(idx),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Item',
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 2: Label Description (Manual / Auto-filled)
                      TextFormField(
                        controller: row.itemNameController,
                        decoration: const InputDecoration(
                          labelText: 'Label Name / Description *',
                          hintText: 'e.g. Paracetamol 500mg 100ml Syrup Label',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),

                      // Row 3: Our SKU Code & Client Product Code
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.ourSkuCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Our Internal SKU Code',
                                hintText: 'e.g. SKU-CIPLA-PARA-500',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: row.clientSkuCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Client Product / Part Code',
                                hintText: 'e.g. CIP-PARA-V2',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 4: Dimensions & HSN Code
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.widthController,
                              decoration: const InputDecoration(labelText: 'Width (mm)', hintText: 'e.g. 65'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: row.heightController,
                              decoration: const InputDecoration(labelText: 'Height (mm)', hintText: 'e.g. 120'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: row.hsnController,
                              decoration: const InputDecoration(labelText: 'HSN/SAC Code'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Row 5: Qty, Unit Rate & Total Line Amount
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.qtyController,
                              decoration: const InputDecoration(labelText: 'Qty (Pcs/Nos) *', hintText: 'e.g. 60000'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: row.rateController,
                              decoration: const InputDecoration(labelText: 'Unit Rate (Rs.) *', hintText: 'e.g. 4.50'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Text(
                                'Total: ₹${row.lineAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Section 3: Financial Summary Breakdown
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Financial Summary Breakdown (Rs.)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _oneTimePunchCostController,
                            decoration: const InputDecoration(labelText: 'One-Time Punch / Development Cost (Rs.)'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _freightChargesController,
                            decoration: const InputDecoration(labelText: 'Freight & Packing Charges (Rs.)'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Taxable Subtotal', '₹${_taxableSubtotal.toStringAsFixed(2)}'),
                    if (_punchCost > 0) _buildSummaryRow('Punch / Development Cost', '₹${_punchCost.toStringAsFixed(2)}'),
                    if (_freightCost > 0) _buildSummaryRow('Freight & Packing', '₹${_freightCost.toStringAsFixed(2)}'),
                    _buildSummaryRow('GST (18% CGST/SGST)', '₹${_gstAmount.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GRAND TOTAL AMOUNT:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹${_grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.accentEmerald)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specialNotesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'PO Terms & Conditions / Special Instructions'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveOrder,
                icon: const Icon(Icons.check_circle),
                label: Text(_isSaving ? 'Saving PO...' : 'Save Purchase Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LineItemRowState {
  final String id;
  ProductModel? selectedProduct;
  final TextEditingController itemNameController;
  final TextEditingController descController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController hsnController;
  final TextEditingController ourSkuCodeController;
  final TextEditingController clientSkuCodeController;
  final TextEditingController qtyController;
  final TextEditingController rateController;

  _LineItemRowState({
    String? id,
    this.selectedProduct,
    String itemName = '',
    String desc = '',
    String width = '',
    String height = '',
    String hsn = '48211020',
    String ourSkuCode = '',
    String clientSkuCode = '',
    String qty = '',
    String rate = '',
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        itemNameController = TextEditingController(text: itemName),
        descController = TextEditingController(text: desc),
        widthController = TextEditingController(text: width),
        heightController = TextEditingController(text: height),
        hsnController = TextEditingController(text: hsn),
        ourSkuCodeController = TextEditingController(text: ourSkuCode),
        clientSkuCodeController = TextEditingController(text: clientSkuCode),
        qtyController = TextEditingController(text: qty),
        rateController = TextEditingController(text: rate);

  factory _LineItemRowState.empty() {
    return _LineItemRowState(
      itemName: '',
      desc: '',
      width: '',
      height: '',
      hsn: '48211020',
      ourSkuCode: '',
      clientSkuCode: '',
      qty: '',
      rate: '',
    );
  }

  factory _LineItemRowState.fromModel(OrderLineItemModel model) {
    return _LineItemRowState(
      id: model.id,
      itemName: model.itemName,
      desc: model.labelDescription,
      width: model.sizeWidthMm > 0 ? model.sizeWidthMm.toString() : '',
      height: model.sizeHeightMm > 0 ? model.sizeHeightMm.toString() : '',
      hsn: model.hsnCode,
      ourSkuCode: model.ourSkuCode,
      clientSkuCode: model.customerSkuCode,
      qty: model.quantityPcs > 0 ? model.quantityPcs.toString() : '',
      rate: model.unitRateRs > 0 ? model.unitRateRs.toString() : '',
    );
  }

  double get lineAmount {
    final q = double.tryParse(qtyController.text.trim()) ?? 0.0;
    final r = double.tryParse(rateController.text.trim()) ?? 0.0;
    return q * r;
  }

  void dispose() {
    itemNameController.dispose();
    descController.dispose();
    widthController.dispose();
    heightController.dispose();
    hsnController.dispose();
    ourSkuCodeController.dispose();
    clientSkuCodeController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}
