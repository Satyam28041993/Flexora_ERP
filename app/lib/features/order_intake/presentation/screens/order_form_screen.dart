import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/order_line_item_model.dart';
import '../../data/models/order_model.dart';
import '../../logic/order_providers.dart';

/// Records a confirmed PO into Flexora (Doc Section 2.2 — Flexora scope starts here).
///
/// NOTE: `createdBy` currently stores the Firebase Auth uid of a TEMPORARY
/// anonymous sign-in (see main.dart) — not a real named user identity. Once
/// the User & Permission module (Doc Section 8, item 24) is designed, this
/// should resolve to the actual logged-in user for real audit-trail purposes.
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _clientNameController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _materialDescriptionController = TextEditingController();
  final _totalQtyController = TextEditingController();

  DateTime? _orderDate;
  DateTime? _poDate;
  bool _advancePaymentReceived = false;
  bool _saving = false;

  final List<_LineItemDraft> _lineItems = [_LineItemDraft()];

  @override
  void dispose() {
    _clientNameController.dispose();
    _poNumberController.dispose();
    _materialDescriptionController.dispose();
    _totalQtyController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.every((item) => item.jobDocNoController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one Job Doc. No. line item.')),
      );
      return;
    }

    setState(() => _saving = true);

    final now = DateTime.now();
    final currentUser = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

    final primaryJobDocNo = _lineItems.first.jobDocNoController.text.trim();

    final order = OrderModel(
      id: '',
      plantId: DefaultPlant.id,
      jobDocNo: primaryJobDocNo,
      clientName: _clientNameController.text.trim(),
      poNumber: _poNumberController.text.trim(),
      status: OrderStatus.active,
      createdAt: now,
      createdBy: currentUser,
      orderDate: _orderDate,
      poDate: _poDate,
      materialDescription: _materialDescriptionController.text.trim().isEmpty
          ? null
          : _materialDescriptionController.text.trim(),
      totalRequiredQty: double.tryParse(_totalQtyController.text.trim()),
      advancePaymentReceived: _advancePaymentReceived,
    );

    final lineItems = _lineItems
        .where((item) => item.jobDocNoController.text.trim().isNotEmpty)
        .map((item) => OrderLineItemModel(
              id: '',
              orderId: '',
              jobDocNo: item.jobDocNoController.text.trim(),
              revisionNo: 1,
              createdAt: now,
              createdBy: currentUser,
              materialDescription: item.materialController.text.trim().isEmpty
                  ? null
                  : item.materialController.text.trim(),
              orderQty: double.tryParse(item.qtyController.text.trim()),
            ))
        .toList();

    try {
      final create = ref.read(createOrderProvider);
      await create(order, lineItems);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save order: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('New Order / PO')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'PO Details',
              children: [
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(labelText: 'Client Name'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poNumberController,
                  decoration: const InputDecoration(labelText: 'PO No.'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'PO Date',
                        value: _poDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate((d) => setState(() => _poDate = d)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'Order Date',
                        value: _orderDate,
                        dateFormat: dateFormat,
                        onTap: () => _pickDate((d) => setState(() => _orderDate = d)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _totalQtyController,
                  decoration: const InputDecoration(labelText: 'Total Order Qty'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _materialDescriptionController,
                  decoration: const InputDecoration(labelText: 'Material Description (optional)'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Advance payment received'),
                  subtitle: const Text(
                    'Reference only — ledger of record remains Tally',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  value: _advancePaymentReceived,
                  onChanged: (value) => setState(() => _advancePaymentReceived = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Job / Product Line Items',
              children: [
                for (var i = 0; i < _lineItems.length; i++) ...[
                  _LineItemRow(
                    draft: _lineItems[i],
                    onRemove: _lineItems.length > 1
                        ? () => setState(() => _lineItems.removeAt(i))
                        : null,
                  ),
                  if (i != _lineItems.length - 1) const Divider(height: 24),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _lineItems.add(_LineItemDraft())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add line item'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Order'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemDraft {
  final jobDocNoController = TextEditingController();
  final materialController = TextEditingController();
  final qtyController = TextEditingController();

  void dispose() {
    jobDocNoController.dispose();
    materialController.dispose();
    qtyController.dispose();
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.draft, this.onRemove});

  final _LineItemDraft draft;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: draft.jobDocNoController,
            decoration: const InputDecoration(labelText: 'Job Doc. No.'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: draft.materialController,
            decoration: const InputDecoration(labelText: 'Material Description'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: draft.qtyController,
            decoration: const InputDecoration(labelText: 'Qty'),
            keyboardType: TextInputType.number,
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
            onPressed: onRemove,
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.dateFormat,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value != null ? dateFormat.format(value!) : 'Select date'),
      ),
    );
  }
}
