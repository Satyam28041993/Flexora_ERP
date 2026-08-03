import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/rm_master_constants.dart';
import '../../data/models/rm_transaction_model.dart';
import '../../logic/rm_ledger_providers.dart';

/// Modal Dialog: Add Stock-In Paper Receipt
class NewStockInDialog extends ConsumerStatefulWidget {
  const NewStockInDialog({super.key});

  @override
  ConsumerState<NewStockInDialog> createState() => _NewStockInDialogState();
}

class _NewStockInDialogState extends ConsumerState<NewStockInDialog> {
  final _formKey = GlobalKey<FormState>();

  String _selectedSupplier = RmMasterConstants.suppliers.first;
  String _selectedMaterial = RmMasterConstants.materials.first;

  final _supplierCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _gsmCtrl = TextEditingController(text: '80');
  final _webSizeCtrl = TextEditingController(text: '125');
  final _rmtInCtrl = TextEditingController(text: '2000');
  final _rateCtrl = TextEditingController(text: '29.5');

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _supplierCtrl.text = _selectedSupplier;
    _materialCtrl.text = _selectedMaterial;
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _materialCtrl.dispose();
    _gsmCtrl.dispose();
    _webSizeCtrl.dispose();
    _rmtInCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Add Raw Material Stock-In Purchase'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: RmMasterConstants.suppliers.contains(_selectedSupplier) ? _selectedSupplier : null,
                decoration: const InputDecoration(labelText: 'Supplier Name *'),
                items: RmMasterConstants.suppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSupplier = val;
                      _supplierCtrl.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : null,
                decoration: const InputDecoration(labelText: 'Substrate Material *'),
                items: RmMasterConstants.materials
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMaterial = val;
                      _materialCtrl.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gsmCtrl,
                      decoration: const InputDecoration(labelText: 'GSM/Micron'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _webSizeCtrl,
                      decoration: const InputDecoration(labelText: 'Web Size (mm) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rmtInCtrl,
                      decoration: const InputDecoration(labelText: 'RMT Purchased *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _rateCtrl,
                      decoration: const InputDecoration(labelText: 'Rate per Sq Mtr (₹)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  final model = RmStockInModel(
                    id: '',
                    plantId: DefaultPlant.id,
                    date: DateTime.now(),
                    supplier: _supplierCtrl.text.trim(),
                    material: _materialCtrl.text.trim(),
                    gsmMicron: double.tryParse(_gsmCtrl.text.trim()) ?? 80.0,
                    webSizeMm: double.parse(_webSizeCtrl.text.trim()),
                    rmtIn: double.parse(_rmtInCtrl.text.trim()),
                    ratePerSqMtr: double.tryParse(_rateCtrl.text.trim()) ?? 0.0,
                    createdAt: DateTime.now(),
                    createdBy: 'system',
                  );
                  await ref.read(rmLedgerRepositoryProvider).addStockIn(model);
                  if (context.mounted) Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          icon: const Icon(Icons.check),
          label: const Text('Save Stock In'),
        ),
      ],
    );
  }
}

/// Modal Dialog: Issue Paper Roll to Job Doc No
class NewIssueDialog extends ConsumerStatefulWidget {
  const NewIssueDialog({super.key, this.initialJobDocNo});

  final String? initialJobDocNo;

  @override
  ConsumerState<NewIssueDialog> createState() => _NewIssueDialogState();
}

class _NewIssueDialogState extends ConsumerState<NewIssueDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _jobDocNoCtrl;
  final _clientCtrl = TextEditingController(text: 'Aries Agro');

  String _selectedMaterial = RmMasterConstants.materials.first;
  String _selectedSupplier = RmMasterConstants.suppliers.first;

  final _materialCtrl = TextEditingController();
  final _gsmCtrl = TextEditingController(text: '80');
  final _webSizeCtrl = TextEditingController(text: '250');
  final _supplierCtrl = TextEditingController();
  final _rmtIssuedCtrl = TextEditingController(text: '2000');
  final _remarksCtrl = TextEditingController(text: '2 Rolls Issued for Schedule Print');

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _jobDocNoCtrl = TextEditingController(text: widget.initialJobDocNo ?? '08/061');
    _materialCtrl.text = _selectedMaterial;
    _supplierCtrl.text = _selectedSupplier;
  }

  @override
  void dispose() {
    _jobDocNoCtrl.dispose();
    _clientCtrl.dispose();
    _materialCtrl.dispose();
    _gsmCtrl.dispose();
    _webSizeCtrl.dispose();
    _supplierCtrl.dispose();
    _rmtIssuedCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🚀 Issue Paper Roll to Job Press'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jobDocNoCtrl,
                      decoration: const InputDecoration(labelText: 'Job Doc No *', hintText: '08/061'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _clientCtrl,
                      decoration: const InputDecoration(labelText: 'Client Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : null,
                decoration: const InputDecoration(labelText: 'Substrate Material *'),
                items: RmMasterConstants.materials
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMaterial = val;
                      _materialCtrl.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _webSizeCtrl,
                      decoration: const InputDecoration(labelText: 'Web Size (mm) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: RmMasterConstants.suppliers.contains(_selectedSupplier) ? _selectedSupplier : null,
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      items: RmMasterConstants.suppliers
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSupplier = val;
                            _supplierCtrl.text = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _rmtIssuedCtrl,
                decoration: const InputDecoration(labelText: 'RMT Issued to Press *', hintText: 'e.g. 2000 RMT'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks / Roll Code'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  final model = RmIssueModel(
                    id: '',
                    plantId: DefaultPlant.id,
                    date: DateTime.now(),
                    jobDocNo: _jobDocNoCtrl.text.trim(),
                    material: _materialCtrl.text.trim(),
                    gsmMicron: double.tryParse(_gsmCtrl.text.trim()) ?? 80.0,
                    webSizeMm: double.parse(_webSizeCtrl.text.trim()),
                    supplier: _supplierCtrl.text.trim(),
                    client: _clientCtrl.text.trim(),
                    rmtIssued: double.parse(_rmtIssuedCtrl.text.trim()),
                    remarks: _remarksCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    createdBy: 'system',
                  );
                  await ref.read(rmLedgerRepositoryProvider).addIssue(model);
                  if (context.mounted) Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          icon: const Icon(Icons.check),
          label: const Text('Confirm Issue'),
        ),
      ],
    );
  }
}

/// Modal Dialog: Return Unused Roll to Store
class NewReturnDialog extends ConsumerStatefulWidget {
  const NewReturnDialog({super.key, this.initialJobDocNo});

  final String? initialJobDocNo;

  @override
  ConsumerState<NewReturnDialog> createState() => _NewReturnDialogState();
}

class _NewReturnDialogState extends ConsumerState<NewReturnDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _jobDocNoCtrl;
  final _clientCtrl = TextEditingController(text: 'Aries Agro');

  String _selectedMaterial = RmMasterConstants.materials.first;
  String _selectedSupplier = RmMasterConstants.suppliers.first;

  final _materialCtrl = TextEditingController();
  final _gsmCtrl = TextEditingController(text: '80');
  final _webSizeCtrl = TextEditingController(text: '250');
  final _supplierCtrl = TextEditingController();
  final _rmtReturnedCtrl = TextEditingController(text: '1000');
  final _remarksCtrl = TextEditingController(text: '1 Unused Roll Returned to Store');

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _jobDocNoCtrl = TextEditingController(text: widget.initialJobDocNo ?? '08/061');
    _materialCtrl.text = _selectedMaterial;
    _supplierCtrl.text = _selectedSupplier;
  }

  @override
  void dispose() {
    _jobDocNoCtrl.dispose();
    _clientCtrl.dispose();
    _materialCtrl.dispose();
    _gsmCtrl.dispose();
    _webSizeCtrl.dispose();
    _supplierCtrl.dispose();
    _rmtReturnedCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('↩ Return Unused Roll to Raw Material Store'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jobDocNoCtrl,
                      decoration: const InputDecoration(labelText: 'Job Doc No *', hintText: '08/061'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _clientCtrl,
                      decoration: const InputDecoration(labelText: 'Client Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : null,
                decoration: const InputDecoration(labelText: 'Substrate Material *'),
                items: RmMasterConstants.materials
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMaterial = val;
                      _materialCtrl.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _webSizeCtrl,
                      decoration: const InputDecoration(labelText: 'Web Size (mm) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: RmMasterConstants.suppliers.contains(_selectedSupplier) ? _selectedSupplier : null,
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      items: RmMasterConstants.suppliers
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSupplier = val;
                            _supplierCtrl.text = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _rmtReturnedCtrl,
                decoration: const InputDecoration(labelText: 'RMT Returned to Store *', hintText: 'e.g. 1000 RMT'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _remarksCtrl,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  final model = RmReturnModel(
                    id: '',
                    plantId: DefaultPlant.id,
                    date: DateTime.now(),
                    jobDocNo: _jobDocNoCtrl.text.trim(),
                    material: _materialCtrl.text.trim(),
                    gsmMicron: double.tryParse(_gsmCtrl.text.trim()) ?? 80.0,
                    webSizeMm: double.parse(_webSizeCtrl.text.trim()),
                    supplier: _supplierCtrl.text.trim(),
                    client: _clientCtrl.text.trim(),
                    rmtReturned: double.parse(_rmtReturnedCtrl.text.trim()),
                    remarks: _remarksCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    createdBy: 'system',
                  );
                  await ref.read(rmLedgerRepositoryProvider).addReturn(model);
                  if (context.mounted) Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
          icon: const Icon(Icons.check),
          label: const Text('Confirm Return'),
        ),
      ],
    );
  }
}
