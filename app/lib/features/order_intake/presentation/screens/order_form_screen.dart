import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/services/gemini_po_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/po_document_parser.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/presentation/screens/product_form_screen.dart';
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

  // Attachment Info
  String? _attachmentFileName;
  String? _attachmentFilePath;
  String? _attachmentFileType;
  Uint8List? _attachedFileBytes;
  bool _isExtracting = false;

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
      _attachmentFileName = o.attachmentFileName;
      _attachmentFilePath = o.attachmentFilePath;
      _attachmentFileType = o.attachmentFileType;

      for (var item in o.lineItems) {
        _lineItemRows.add(_LineItemRowState.fromModel(item));
      }
    } else {
      // Add default 1 empty line item row for clean new entry
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

  // Open Gemini API Key Configuration Dialog
  void _configureGeminiKey() {
    final keyController = TextEditingController(text: GeminiPOService.userApiKey ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Configure Gemini AI API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your Google Gemini API key to enable 100% dynamic AI extraction of ANY Purchase Order PDF layout:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = keyController.text.trim();
              setState(() {
                GeminiPOService.userApiKey = key.isEmpty ? null : key;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(key.isNotEmpty
                      ? 'Gemini AI API Key saved! Dynamic AI PO extraction activated.'
                      : 'Gemini API Key cleared.'),
                  backgroundColor: AppTheme.accentEmerald,
                ),
              );
            },
            child: const Text('Save API Key'),
          ),
        ],
      ),
    );
  }

  // Pick / Upload PO File (Direct Native/Web File Explorer Picker)
  Future<void> _pickPOFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = file.extension?.toLowerCase() ?? 'pdf';
        final safePath = kIsWeb ? file.name : (file.path ?? file.name);

        setState(() {
          _attachmentFileName = file.name;
          _attachmentFilePath = safePath;
          _attachmentFileType = (ext == 'pdf') ? 'pdf' : 'image';
          _attachedFileBytes = file.bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attached file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)'),
              backgroundColor: AppTheme.primary,
            ),
          );
        }

        // Auto-extract data immediately on file attachment!
        await _extractPOData();
      }
    } catch (e) {
      debugPrint('FilePicker error: $e');
    }
  }

  // Auto-Extract Data from PO Document using Gemini AI Vision or Local Rules Engine
  Future<void> _extractPOData() async {
    if (_attachmentFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please attach a PO PDF or Image file first')),
      );
      return;
    }

    setState(() => _isExtracting = true);

    try {
      ParsedPOData? parsedData;

      // 1. Try Gemini AI Vision API if Key is set and bytes available
      if (GeminiPOService.hasKey && _attachedFileBytes != null) {
        parsedData = await GeminiPOService.extractPOWithGemini(
          fileBytes: _attachedFileBytes!,
          fileName: _attachmentFileName!,
          mimeType: _attachmentFileType == 'pdf' ? 'application/pdf' : 'image/png',
        );
      }

      // 2. Fallback to PODocumentParser
      parsedData ??= await PODocumentParser.parseFile(
        fileName: _attachmentFileName!,
        filePath: _attachmentFilePath!,
      );

      setState(() {
        _poNumberController.text = parsedData!.poNumber;
        _poDate = parsedData.poDate;
        _shippingAddressController.text = parsedData.shippingAddress;
        if (parsedData.specialNotes != null) {
          _specialNotesController.text = parsedData.specialNotes!;
        }
        _oneTimePunchCostController.text = parsedData.oneTimePunchCost.toString();
        _freightChargesController.text = parsedData.freightCharges.toString();

        // Clear existing rows and load extracted line items
        for (var r in _lineItemRows) {
          r.dispose();
        }
        _lineItemRows.clear();

        for (var item in parsedData.lineItems) {
          _lineItemRows.add(_LineItemRowState.fromModel(item));
        }

        // Try auto-selecting customer if matched
        final customers = ref.read(customersStreamProvider).value;
        if (customers != null && parsedData.customerName.isNotEmpty) {
          try {
            _selectedCustomer = customers.firstWhere(
              (c) =>
                  c.companyName.toLowerCase().contains(parsedData!.customerName.toLowerCase()) ||
                  parsedData.customerName.toLowerCase().contains(c.companyName.toLowerCase()),
            );
          } catch (_) {}
        }
      });

      if (mounted) {
        final isAi = GeminiPOService.hasKey && _attachedFileBytes != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAi
                ? '✨ Gemini AI Extraction Complete! ${parsedData.lineItems.length} label item(s) extracted.'
                : 'PO Data Extracted! ${parsedData.lineItems.length} label item(s) loaded.'),
            backgroundColor: AppTheme.accentEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extraction error: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }

  Future<void> _openSkuMasterPopup(int rowIndex) async {
    final result = await showDialog<ProductModel>(
      context: context,
      builder: (context) {
        final row = _lineItemRows[rowIndex];
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 1000,
              height: 800,
              child: ProductFormScreen(
                preselectedCustomerId: _selectedCustomer?.id,
                preselectedName: row.itemNameController.text,
                preselectedWidth: row.widthController.text,
                preselectedHeight: row.heightController.text,
              ),
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        final row = _lineItemRows[rowIndex];
        row.itemNameController.text = result.productName;
        row.widthController.text = result.labelSpec.widthMm.toString();
        row.heightController.text = result.labelSpec.heightMm.toString();
      });
    }
  }

  // Calculate Financial Totals Live
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

      final lineItemsModels = _lineItemRows.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final r = entry.value;
        return OrderLineItemModel(
          id: r.id,
          itemNo: idx,
          itemName: r.itemNameController.text.trim(),
          labelDescription: r.descController.text.trim(),
          sizeWidthMm: double.tryParse(r.widthController.text.trim()) ?? 0.0,
          sizeHeightMm: double.tryParse(r.heightController.text.trim()) ?? 0.0,
          hsnCode: r.hsnController.text.trim(),
          quantityPcs: double.tryParse(r.qtyController.text.trim()) ?? 0.0,
          unitRateRs: double.tryParse(r.rateController.text.trim()) ?? 0.0,
          lineAmountRs: r.lineAmount,
        );
      }).toList();

      final orderData = OrderModel(
        id: widget.order?.id ?? '',
        plantId: DefaultPlant.id,
        poNumber: _poNumberController.text.trim().toUpperCase(),
        poDate: _poDate,
        customerId: _selectedCustomer?.id ?? widget.order?.customerId ?? 'cust-default',
        customerName: _selectedCustomer?.companyName ?? widget.order?.customerName ?? 'Direct Customer',
        customerGstNo: _selectedCustomer?.gstNo ?? widget.order?.customerGstNo ?? '',
        shippingAddress: _shippingAddressController.text.trim(),
        paymentTermsDays: _paymentTermsDays,
        specialNotes: _specialNotesController.text.trim().isEmpty ? null : _specialNotesController.text.trim(),
        attachmentFileName: _attachmentFileName,
        attachmentFilePath: _attachmentFilePath,
        attachmentFileType: _attachmentFileType,
        lineItems: lineItemsModels,
        taxableSubtotal: _taxableSubtotal,
        gstRatePercent: _gstRatePercent,
        cgstAmount: _gstAmount / 2.0,
        sgstAmount: _gstAmount / 2.0,
        freightCharges: _freightCost,
        oneTimePunchCost: _punchCost,
        grandTotalAmount: _grandTotal,
        status: widget.order?.status ?? 'Pending',
        createdAt: widget.order?.createdAt ?? DateTime.now(),
        createdBy: widget.order?.createdBy ?? 'sales',
        updatedAt: widget.order != null ? DateTime.now() : null,
        updatedBy: widget.order != null ? 'sales' : null,
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
            // Section 1: PO Document Attachment & Gemini AI Auto-Extractor
            Card(
              color: const Color(0xFFF1F5F9),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.attach_file, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text('PO Document Attachment & AI Auto-Extractor',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _configureGeminiKey,
                              icon: Icon(
                                GeminiPOService.hasKey ? Icons.check_circle : Icons.key,
                                size: 16,
                                color: GeminiPOService.hasKey ? AppTheme.accentEmerald : AppTheme.primary,
                              ),
                              label: Text(
                                GeminiPOService.hasKey ? 'Gemini AI Active ✨' : 'Add Gemini API Key 🔑',
                                style: TextStyle(
                                  color: GeminiPOService.hasKey ? AppTheme.accentEmerald : AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_attachmentFileName != null)
                              ElevatedButton.icon(
                                onPressed: _isExtracting ? null : _extractPOData,
                                icon: _isExtracting
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.auto_fix_high, size: 18),
                                label: Text(_isExtracting ? 'Extracting Data...' : 'Auto-Extract PO Data'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentEmerald),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickPOFile,
                          icon: const Icon(Icons.folder_open),
                          label: Text(_attachmentFileName == null ? 'Attach PO PDF / Image File' : 'Change Attached File'),
                        ),
                        const SizedBox(width: 16),
                        if (_attachmentFileName != null)
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _attachmentFileName!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Header Metadata
            const Text('PO Header & Customer Info',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: customersAsync.when(
                    data: (customers) => DropdownButtonFormField<CustomerModel>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(labelText: 'Customer / Billing Party *'),
                      items: customers
                          .map((c) => DropdownMenuItem(value: c, child: Text('${c.companyName} (${c.customerCode})')))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCustomer = val),
                      validator: (v) => v == null && widget.order == null ? 'Required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _poNumberController,
                    decoration: const InputDecoration(labelText: 'PO Number *', hintText: 'e.g. PK/MUM/155/2026-2027'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
                      decoration: const InputDecoration(labelText: 'PO Date *'),
                      child: Text(dateFormat.format(_poDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _paymentTermsDays,
                    decoration: const InputDecoration(labelText: 'Payment Terms'),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 Days Credit')),
                      DropdownMenuItem(value: 45, child: Text('45 Days Credit')),
                      DropdownMenuItem(value: 60, child: Text('60 Days Credit')),
                      DropdownMenuItem(value: 0, child: Text('Advance Payment')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentTermsDays = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shippingAddressController,
              decoration: const InputDecoration(labelText: 'Shipping / Consignee Address *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Section 3: Multiple Label SKUs / Line Items Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PO Line Items (Label SKUs Breakdown)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                OutlinedButton.icon(
                  onPressed: _addLineItemRow,
                  icon: const Icon(Icons.add, size: 18),
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
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
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
                            child: TextFormField(
                              controller: row.itemNameController,
                              decoration: const InputDecoration(labelText: 'Label Name / Item Description *', hintText: 'e.g. Nomocheck Triple Action 500ml'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openSkuMasterPopup(idx),
                            icon: const Icon(Icons.add_box, color: AppTheme.primary),
                            tooltip: 'Create New SKU',
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.widthController,
                              decoration: const InputDecoration(labelText: 'Width (mm)', hintText: 'e.g. 215'),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: row.qtyController,
                              decoration: const InputDecoration(labelText: 'Qty (Pcs/Nos) *', hintText: 'e.g. 6000'),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: row.rateController,
                              decoration: const InputDecoration(labelText: 'Unit Rate (Rs.) *', hintText: 'e.g. 5.40'),
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

            // Section 4: Financial Summary Breakdown
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
                        const SizedBox(width: 12),
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
  final TextEditingController itemNameController;
  final TextEditingController descController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController hsnController;
  final TextEditingController qtyController;
  final TextEditingController rateController;

  _LineItemRowState({
    String? id,
    String itemName = '',
    String desc = '',
    String width = '',
    String height = '',
    String hsn = '48211020',
    String qty = '',
    String rate = '',
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        itemNameController = TextEditingController(text: itemName),
        descController = TextEditingController(text: desc),
        widthController = TextEditingController(text: width),
        heightController = TextEditingController(text: height),
        hsnController = TextEditingController(text: hsn),
        qtyController = TextEditingController(text: qty),
        rateController = TextEditingController(text: rate);

  factory _LineItemRowState.empty() {
    return _LineItemRowState(
      itemName: '',
      desc: '',
      width: '',
      height: '',
      hsn: '48211020',
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
    qtyController.dispose();
    rateController.dispose();
  }
}
