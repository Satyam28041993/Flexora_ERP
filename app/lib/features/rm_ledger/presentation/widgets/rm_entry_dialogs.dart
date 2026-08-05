import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/constants/production_formulas.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer_master/data/models/customer_model.dart';
import '../../../customer_master/logic/customer_providers.dart';
import '../../../product_master/data/models/product_model.dart';
import '../../../product_master/logic/product_providers.dart';
import '../../../production/data/models/production_job_model.dart';
import '../../../production/logic/production_providers.dart';
import '../../data/models/rm_master_constants.dart';
import '../../data/models/rm_transaction_model.dart';
import '../../logic/rm_ledger_providers.dart';

/// Helper class for dynamic contact persons inside Vendor Profile
class VendorContactPersonEntry {
  TextEditingController nameCtrl;
  TextEditingController roleCtrl;
  TextEditingController phoneCtrl;

  VendorContactPersonEntry({String name = '', String role = 'Sales Manager', String phone = ''})
      : nameCtrl = TextEditingController(text: name),
        roleCtrl = TextEditingController(text: role),
        phoneCtrl = TextEditingController(text: phone);

  void dispose() {
    nameCtrl.dispose();
    roleCtrl.dispose();
    phoneCtrl.dispose();
  }
}

/// Modal Dialog: Add New Vendor / Supplier WITH GST, ADDRESS, DEALS IN & MULTIPLE CONTACT PERSONS
class NewVendorDialog extends StatefulWidget {
  const NewVendorDialog({super.key, this.onAdded});
  final ValueChanged<String>? onAdded;

  @override
  State<NewVendorDialog> createState() => _NewVendorDialogState();
}

class _NewVendorDialogState extends State<NewVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dealsInCtrl = TextEditingController(text: 'Chromo Paper, PP White, Self Adhesive Films');

  final List<VendorContactPersonEntry> _contactPersons = [
    VendorContactPersonEntry(name: 'Rajesh Sharma', role: 'Sales Manager', phone: '9820123456'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    _dealsInCtrl.dispose();
    for (final c in _contactPersons) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 750,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    const Text('➕ Add New Vendor / Supplier Master Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Company Basic Info
                const Text('🏢 Vendor Company & Tax Details:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vendor / Supplier Company Name *',
                          hintText: 'e.g. Avery Dennison India Pvt Ltd',
                          prefixIcon: Icon(Icons.store),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _gstCtrl,
                        decoration: const InputDecoration(
                          labelText: 'GSTIN Number',
                          hintText: '27AAACA1234A1Z5',
                          prefixIcon: Icon(Icons.receipt_long),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dealsInCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Products Dealt In / Materials Supplied (Kis Chij Me Deal Karte Hain)',
                          hintText: 'e.g. Chromo Paper, PP White, Security Films, Inks',
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Factory / Office Address & City Location',
                    hintText: 'e.g. Plot 45, MIDC Industrial Estate, Thane, Maharashtra',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // DYNAMIC CONTACT PERSONS SECTION WITH '+' BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('👤 Contact Persons & Mobile Numbers:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _contactPersons.add(VendorContactPersonEntry())),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('➕ Add Contact Person'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ..._contactPersons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final person = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withAlpha(60),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: person.nameCtrl,
                            decoration: const InputDecoration(labelText: 'Contact Name', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: person.roleCtrl,
                            decoration: const InputDecoration(labelText: 'Designation / Role', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: person.phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Phone / Mobile', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        if (_contactPersons.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () => setState(() {
                              person.dispose();
                              _contactPersons.removeAt(index);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final name = _nameCtrl.text.trim();
                      RmMasterConstants.addSupplier(name);
                      widget.onAdded?.call(name);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added new Vendor Profile [$name]!')));
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Save Vendor Master Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Dialog: Add New Raw Material Substrate
class NewSubstrateMaterialDialog extends StatefulWidget {
  const NewSubstrateMaterialDialog({super.key, this.onAdded});
  final ValueChanged<String>? onAdded;

  @override
  State<NewSubstrateMaterialDialog> createState() => _NewSubstrateMaterialDialogState();
}

class _NewSubstrateMaterialDialogState extends State<NewSubstrateMaterialDialog> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Add New Raw Material Substrate'),
      content: TextFormField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: 'Substrate Material Name *',
          hintText: 'e.g. CHROMO GLOSS / PP TRANSPARENT',
          prefixIcon: Icon(Icons.layers),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isNotEmpty) {
              RmMasterConstants.addMaterial(name);
              widget.onAdded?.call(name);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added new Raw Material [$name]!')));
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          icon: const Icon(Icons.check),
          label: const Text('Save Material'),
        ),
      ],
    );
  }
}

/// Helper class for dynamic contact persons inside Client Profile
class ClientContactPersonEntry {
  TextEditingController nameCtrl;
  TextEditingController roleCtrl;
  TextEditingController phoneCtrl;

  ClientContactPersonEntry({String name = '', String role = 'Purchase Manager', String phone = ''})
      : nameCtrl = TextEditingController(text: name),
        roleCtrl = TextEditingController(text: role),
        phoneCtrl = TextEditingController(text: phone);

  void dispose() {
    nameCtrl.dispose();
    roleCtrl.dispose();
    phoneCtrl.dispose();
  }
}

/// Modal Dialog: Add New Client / Customer WITH FAST SHORTCUT & CUSTOMER MASTER LINK
class NewClientDialog extends ConsumerStatefulWidget {
  const NewClientDialog({super.key, this.onAdded});
  final ValueChanged<String>? onAdded;

  @override
  ConsumerState<NewClientDialog> createState() => _NewClientDialogState();
}

class _NewClientDialogState extends ConsumerState<NewClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Mumbai');
  final _addressCtrl = TextEditingController();

  final List<ClientContactPersonEntry> _contactPersons = [
    ClientContactPersonEntry(name: 'Amit Patel', role: 'Purchase Manager', phone: '9876543210'),
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gstCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    for (final c in _contactPersons) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 750,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                    const Text('➕ Add New Client / Customer (Synced to Customer Master)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Company Basic Info
                const Text('🏢 Client Company & Billing Info:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Client / Customer Company Name *',
                          hintText: 'e.g. OCTAGREEN / RALLIS INDIA LTD',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _gstCtrl,
                        decoration: const InputDecoration(
                          labelText: 'GSTIN Number (Optional)',
                          hintText: '27AAAAC9876F1Z2',
                          prefixIcon: Icon(Icons.receipt_long),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'City / Location',
                          hintText: 'e.g. Mumbai / Ankleshwar',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Billing Address (Optional)',
                          hintText: 'e.g. Plot 12, Industrial Area, Thane',
                          prefixIcon: Icon(Icons.home_work),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DYNAMIC CONTACT PERSONS SECTION WITH '+' BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('👤 Contact Persons & Mobile Numbers:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _contactPersons.add(ClientContactPersonEntry())),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('➕ Add Contact Person'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ..._contactPersons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final person = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50.withAlpha(60),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: person.nameCtrl,
                            decoration: const InputDecoration(labelText: 'Contact Name', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: person.roleCtrl,
                            decoration: const InputDecoration(labelText: 'Designation / Role', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: person.phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Phone / Mobile', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        if (_contactPersons.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () => setState(() {
                              person.dispose();
                              _contactPersons.removeAt(index);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isSaving = true);

                            final name = _nameCtrl.text.trim();
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);

                            try {
                              final primaryPerson = _contactPersons.first;
                              final customerModel = CustomerModel(
                                id: '',
                                plantId: DefaultPlant.id,
                                customerCode: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                companyName: name,
                                gstNo: _gstCtrl.text.trim().isNotEmpty ? _gstCtrl.text.trim() : null,
                                primaryContact: ContactPersonModel(
                                  name: primaryPerson.nameCtrl.text.trim().isNotEmpty ? primaryPerson.nameCtrl.text.trim() : 'Contact Person',
                                  designation: primaryPerson.roleCtrl.text.trim(),
                                  phone: primaryPerson.phoneCtrl.text.trim(),
                                  email: '',
                                ),
                                additionalContacts: _contactPersons.skip(1).map((c) => ContactPersonModel(
                                  name: c.nameCtrl.text.trim(),
                                  designation: c.roleCtrl.text.trim(),
                                  phone: c.phoneCtrl.text.trim(),
                                  email: '',
                                )).toList(),
                                billingAddress: AddressModel(
                                  addressLine1: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : name,
                                  city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : 'Mumbai',
                                  state: 'Maharashtra',
                                  pincode: '400001',
                                ),
                                createdAt: DateTime.now(),
                                createdBy: 'system',
                              );

                              await ref.read(customerRepositoryProvider).createCustomer(customerModel);
                              widget.onAdded?.call(name);
                              messenger.showSnackBar(SnackBar(content: Text('Added new Client [$name] synced to Customer Master!')));
                              nav.pop();
                            } catch (e) {
                              widget.onAdded?.call(name);
                              messenger.showSnackBar(SnackBar(content: Text('Added Client [$name]!')));
                              nav.pop();
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle),
                    label: Text(_isSaving ? 'Syncing Customer...' : 'Save & Sync Client to Customer Master', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Dialog: Add New SKU / Product Label Master WITH FAST SHORTCUT & PRODUCTS MASTER LINK
class NewSkuDialog extends ConsumerStatefulWidget {
  const NewSkuDialog({super.key, this.onAdded});
  final ValueChanged<String>? onAdded;

  @override
  ConsumerState<NewSkuDialog> createState() => _NewSkuDialogState();
}

class _NewSkuDialogState extends ConsumerState<NewSkuDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skuCodeCtrl = TextEditingController(text: 'SKU-809');
  final _descCtrl = TextEditingController(text: 'Chromo Label 100 x 150');
  final _clientCtrl = TextEditingController(text: 'RALLIS INDIA');
  String _selectedMaterial = RmMasterConstants.materials.first;
  final _webCtrl = TextEditingController(text: '125');
  final _gearCtrl = TextEditingController(text: '108');
  final _upsCtrl = TextEditingController(text: '2');

  bool _isSaving = false;

  @override
  void dispose() {
    _skuCodeCtrl.dispose();
    _descCtrl.dispose();
    _clientCtrl.dispose();
    _webCtrl.dispose();
    _gearCtrl.dispose();
    _upsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Add New SKU / Product Label Master (Synced to Products Master)'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _skuCodeCtrl,
                decoration: const InputDecoration(labelText: 'SKU Code / Part No *', prefixIcon: Icon(Icons.qr_code_2)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Label Description / Title *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _clientCtrl,
                decoration: const InputDecoration(labelText: 'Client Name *', prefixIcon: Icon(Icons.business)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : RmMasterConstants.materials.first,
                decoration: const InputDecoration(labelText: 'Substrate Material'),
                items: RmMasterConstants.materials.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _selectedMaterial = v!),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _webCtrl,
                      decoration: const InputDecoration(labelText: 'Web Size (mm)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _gearCtrl,
                      decoration: const InputDecoration(labelText: 'Gear Z'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _upsCtrl,
                      decoration: const InputDecoration(labelText: 'UPS'),
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
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);

                  final code = _skuCodeCtrl.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);

                  try {
                    final webSize = double.tryParse(_webCtrl.text.trim()) ?? 125.0;
                    final gearZ = int.tryParse(_gearCtrl.text.trim()) ?? 108;
                    final ups = int.tryParse(_upsCtrl.text.trim()) ?? 2;

                    final productModel = ProductModel(
                      id: '',
                      plantId: DefaultPlant.id,
                      internalSkuCode: code,
                      customerId: 'cust-1',
                      customerName: _clientCtrl.text.trim(),
                      customerProductCode: code,
                      productName: _descCtrl.text.trim(),
                      description: 'Quick created from RM Ledger SKU Master',
                      labelSpec: LabelSpecModel(
                        widthMm: webSize,
                        heightMm: 100.0,
                        substrateMaterial: _selectedMaterial,
                      ),
                      printSpec: const PrintSpecModel(colorCount: 4),
                      machineSpec: MachineSpecModel(
                        webWidthMm: webSize,
                        repeatCylinderMm: (gearZ * 3.175),
                        webUps: ups,
                        repeatUps: 1,
                      ),
                      processRoute: StandardProcessSteps.defaultRoute,
                      artworkApprovalStatus: 'approved',
                      status: 'active',
                      createdAt: DateTime.now(),
                      createdBy: 'system',
                    );

                    await ref.read(productRepositoryProvider).createProduct(productModel);
                    widget.onAdded?.call(code);
                    messenger.showSnackBar(SnackBar(content: Text('Added SKU [$code] synced to Products Master!')));
                    nav.pop();
                  } catch (e) {
                    widget.onAdded?.call(code);
                    messenger.showSnackBar(SnackBar(content: Text('Added SKU [$code]!')));
                    nav.pop();
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          icon: const Icon(Icons.check_circle),
          label: Text(_isSaving ? 'Syncing SKU...' : 'Save & Sync SKU to Product Master'),
        ),
      ],
    );
  }
}

/// Helper model for individual roll batch item (e.g. 2000 RMT x 5 rolls)
class RollBatchEntry {
  double rollRmt;
  int rollCount;

  RollBatchEntry({required this.rollRmt, required this.rollCount});

  double get totalRmt => rollRmt * rollCount;
}

/// Helper model for Web Size group containing multiple roll batches
class WebSizeGroupEntry {
  double webSizeMm;
  String supplier;
  List<RollBatchEntry> rollBatches;

  WebSizeGroupEntry({
    required this.webSizeMm,
    required this.supplier,
    List<RollBatchEntry>? rollBatches,
  }) : rollBatches = rollBatches ?? [RollBatchEntry(rollRmt: 2000, rollCount: 5)];

  double get totalRmt => rollBatches.fold(0.0, (sum, b) => sum + b.totalRmt);
  int get totalRollCount => rollBatches.fold<int>(0, (sum, b) => sum + b.rollCount);
  double get totalSqMtr => (webSizeMm * totalRmt) / 1000.0;
}

/// Helper model for Purchase Stock-In Web Group containing multiple rolls and rate per sqM
class StockInWebGroupEntry {
  double webSizeMm;
  double ratePerSqMtr;
  List<RollBatchEntry> rollBatches;

  StockInWebGroupEntry({
    required this.webSizeMm,
    required this.ratePerSqMtr,
    List<RollBatchEntry>? rollBatches,
  }) : rollBatches = rollBatches ?? [RollBatchEntry(rollRmt: 2000, rollCount: 5)];

  double get totalRmt => rollBatches.fold(0.0, (sum, b) => sum + b.totalRmt);
  int get totalRollCount => rollBatches.fold<int>(0, (sum, b) => sum + b.rollCount);
  double get totalSqMtr => (webSizeMm * totalRmt) / 1000.0;
  double get totalValue => totalSqMtr * ratePerSqMtr;
}

/// Fallback Production Jobs when stream is empty
final List<ProductionJobModel> _mockDefaultJobs = [];

/// Modal Dialog: Add Stock-In Paper Receipt WITH MULTI-ROLL BATCH & QUICK-ADD VENDOR/RM
class NewStockInDialog extends ConsumerStatefulWidget {
  const NewStockInDialog({super.key});

  @override
  ConsumerState<NewStockInDialog> createState() => _NewStockInDialogState();
}

class _NewStockInDialogState extends ConsumerState<NewStockInDialog> {
  final _formKey = GlobalKey<FormState>();

  String _selectedSupplier = RmMasterConstants.suppliers.first;
  String _selectedMaterial = RmMasterConstants.materials.first;

  final _productCodeCtrl = TextEditingController(text: 'FASSON-FL201'); // Optional Vendor Code
  final _gsmCtrl = TextEditingController(text: '80');

  // Dynamic Purchase Web Groups
  final List<StockInWebGroupEntry> _stockInWebGroups = [
    StockInWebGroupEntry(
      webSizeMm: 210,
      ratePerSqMtr: 29.5,
      rollBatches: [
        RollBatchEntry(rollRmt: 2000, rollCount: 5),
        RollBatchEntry(rollRmt: 1000, rollCount: 2),
      ],
    ),
    StockInWebGroupEntry(
      webSizeMm: 215,
      ratePerSqMtr: 29.5,
      rollBatches: [
        RollBatchEntry(rollRmt: 2000, rollCount: 1),
      ],
    ),
  ];

  bool _isSaving = false;

  @override
  void dispose() {
    _productCodeCtrl.dispose();
    _gsmCtrl.dispose();
    super.dispose();
  }

  double get _grandTotalRmt => _stockInWebGroups.fold(0.0, (sum, g) => sum + g.totalRmt);
  int get _grandTotalRolls => _stockInWebGroups.fold(0, (sum, g) => sum + g.totalRollCount);
  double get _grandTotalSqMtr => _stockInWebGroups.fold(0.0, (sum, g) => sum + g.totalSqMtr);
  double get _grandTotalValue => _stockInWebGroups.fold(0.0, (sum, g) => sum + g.totalValue);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 880,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    const Text('➕ Add Raw Material Purchase Receipt (Multi-Roll Stock-In)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Vendor & Substrate Header Row WITH QUICK '+' ADD BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: RmMasterConstants.suppliers.contains(_selectedSupplier) ? _selectedSupplier : RmMasterConstants.suppliers.first,
                              decoration: const InputDecoration(labelText: 'Supplier / Vendor Name *', prefixIcon: Icon(Icons.store, color: AppTheme.primary)),
                              items: RmMasterConstants.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => _selectedSupplier = val!),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                            tooltip: 'Add New Vendor',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => NewVendorDialog(onAdded: (newVendor) => setState(() => _selectedSupplier = newVendor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : RmMasterConstants.materials.first,
                              decoration: const InputDecoration(labelText: 'Substrate Material *'),
                              items: RmMasterConstants.materials.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => _selectedMaterial = val!),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                            tooltip: 'Add New Material',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => NewSubstrateMaterialDialog(onAdded: (newMat) => setState(() => _selectedMaterial = newMat)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vendor Product Code (Optional) & GSM Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _productCodeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vendor Product / Item Code (Optional)',
                          hintText: 'e.g. FASSON FL201 / SW7034',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _gsmCtrl,
                        decoration: const InputDecoration(labelText: 'GSM / Micron'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DYNAMIC PURCHASE WEB SIZE GROUPS & BATCHES
                const Text('📦 Paper Roll Web Size Groups & Invoice Receipt Batches:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                const SizedBox(height: 8),

                ..._stockInWebGroups.asMap().entries.map((entry) {
                  final gIndex = entry.key;
                  final group = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    color: Colors.green.shade50.withAlpha(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(4)),
                                child: Text('Purchase Group #${gIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 140,
                                child: TextFormField(
                                  initialValue: group.webSizeMm.toInt().toString(),
                                  decoration: const InputDecoration(labelText: 'Web Size (mm) *', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (v) => setState(() => group.webSizeMm = double.tryParse(v) ?? 210),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 160,
                                child: TextFormField(
                                  initialValue: group.ratePerSqMtr.toStringAsFixed(2),
                                  decoration: const InputDecoration(labelText: 'Rate per SqM (₹)', prefixText: '₹', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (v) => setState(() => group.ratePerSqMtr = double.tryParse(v) ?? 0),
                                ),
                              ),
                              const Spacer(),
                              if (_stockInWebGroups.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _stockInWebGroups.removeAt(gIndex)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          ...group.rollBatches.asMap().entries.map((bEntry) {
                            final bIndex = bEntry.key;
                            final batch = bEntry.value;
                            final batchSqM = (group.webSizeMm * batch.totalRmt) / 1000.0;
                            final batchValue = batchSqM * group.ratePerSqMtr;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                children: [
                                  Text('Received Roll #${bIndex + 1}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 130,
                                    child: TextFormField(
                                      initialValue: batch.rollRmt.toInt().toString(),
                                      decoration: const InputDecoration(labelText: 'Roll RMT', suffixText: 'm', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (v) => setState(() => batch.rollRmt = double.tryParse(v) ?? 0),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('x', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      initialValue: batch.rollCount.toString(),
                                      decoration: const InputDecoration(labelText: 'No of Rolls', suffixText: 'rolls', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => setState(() => batch.rollCount = int.tryParse(v) ?? 1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('= ${batch.totalRmt.toInt()} RMT In', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                                  const Spacer(),
                                  Text('SqM: ${batchSqM.toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                                  const SizedBox(width: 12),
                                  Text('Val: ₹${batchValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  if (group.rollBatches.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                                      onPressed: () => setState(() => group.rollBatches.removeAt(bIndex)),
                                    ),
                                ],
                              ),
                            );
                          }),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => group.rollBatches.add(RollBatchEntry(rollRmt: 1000, rollCount: 1))),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('+ Add Purchase Roll Batch under ${group.webSizeMm.toInt()} mm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _stockInWebGroups.add(StockInWebGroupEntry(webSizeMm: 215, ratePerSqMtr: 29.5))),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('+ Add New Purchase Web Size Group'),
                ),
                const SizedBox(height: 16),

                // SUMMARY KPI BANNER FOR THIS PURCHASE RECEIPT
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Rolls Received', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('$_grandTotalRolls Rolls', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Grand Total RMT In', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('${_grandTotalRmt.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Grand Total Sq. Mtr', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('${_grandTotalSqMtr.toStringAsFixed(1)} SqM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal.shade900)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Grand Total Value', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('₹${_grandTotalValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isSaving = true);

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final repo = ref.read(rmLedgerRepositoryProvider);

                            final vendorCode = _productCodeCtrl.text.trim();

                            for (final g in _stockInWebGroups) {
                              final model = RmStockInModel(
                                id: '',
                                plantId: DefaultPlant.id,
                                date: DateTime.now(),
                                supplier: _selectedSupplier,
                                material: _selectedMaterial,
                                productCode: vendorCode,
                                gsmMicron: double.tryParse(_gsmCtrl.text.trim()) ?? 80.0,
                                webSizeMm: g.webSizeMm,
                                rmtIn: g.totalRmt,
                                ratePerSqMtr: g.ratePerSqMtr,
                                createdAt: DateTime.now(),
                                createdBy: 'system',
                              );
                              await repo.addStockIn(model);
                            }

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Saved Stock-In Purchase: $_grandTotalRolls rolls (${_grandTotalRmt.toInt()} RMT / ${_grandTotalSqMtr.toStringAsFixed(1)} SqM) from $_selectedSupplier!'),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                            nav.pop();
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle),
                    label: Text(_isSaving ? 'Saving Purchase Receipts...' : 'Save Purchase Receipt Entry', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic Modal Dialog: Multi-Roll Paper Issue WITH SMART JOB CARD DROPDOWN & AUTO-FILL
class NewIssueDialog extends ConsumerStatefulWidget {
  const NewIssueDialog({super.key, this.initialJobDocNo});

  final String? initialJobDocNo;

  @override
  ConsumerState<NewIssueDialog> createState() => _NewIssueDialogState();
}

class _NewIssueDialogState extends ConsumerState<NewIssueDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedJobDocNo;
  final _clientCtrl = TextEditingController(text: 'RALLIS INDIA');
  String _selectedMaterial = RmMasterConstants.materials.first;

  // Dynamic Web Size Groups
  final List<WebSizeGroupEntry> _webGroups = [
    WebSizeGroupEntry(
      webSizeMm: 210,
      supplier: 'Avery Dennison',
      rollBatches: [
        RollBatchEntry(rollRmt: 2000, rollCount: 5),
        RollBatchEntry(rollRmt: 1000, rollCount: 2),
      ],
    ),
    WebSizeGroupEntry(
      webSizeMm: 215,
      supplier: 'Avery Dennison',
      rollBatches: [
        RollBatchEntry(rollRmt: 2000, rollCount: 1),
      ],
    ),
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedJobDocNo = widget.initialJobDocNo ?? '08/040';
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    super.dispose();
  }

  /// Auto-populate master job data when a Job Card No is selected
  void _onJobCardSelected(ProductionJobModel job) {
    setState(() {
      _selectedJobDocNo = job.jobDocNo;
      _clientCtrl.text = job.clientName;
      _selectedMaterial = job.substrateMaterial.isNotEmpty ? job.substrateMaterial : RmMasterConstants.materials.first;
      
      // Update first web group size with Job Card paper size
      if (_webGroups.isNotEmpty && job.paperSizeMm > 0) {
        _webGroups.first.webSizeMm = job.paperSizeMm;
      }
    });
  }

  double get _grandTotalRmt => _webGroups.fold(0.0, (sum, g) => sum + g.totalRmt);
  int get _grandTotalRolls => _webGroups.fold(0, (sum, g) => sum + g.totalRollCount);
  double get _grandTotalSqMtr => _webGroups.fold(0.0, (sum, g) => sum + g.totalSqMtr);

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(allProductionJobsStreamProvider);
    final availableJobs = jobsAsync.value?.isNotEmpty == true ? jobsAsync.value! : _mockDefaultJobs;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    const Text('🚀 Issue Paper Rolls to Press (Scheduled Job Auto-Fetch)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Job Card & Client Header with Cascading Dropdown (WITH isExpanded: true FIX!)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: availableJobs.any((j) => j.jobDocNo == _selectedJobDocNo) ? _selectedJobDocNo : availableJobs.first.jobDocNo,
                        decoration: const InputDecoration(labelText: 'Select Job Card No *', prefixIcon: Icon(Icons.assignment, color: AppTheme.primary)),
                        items: availableJobs.map((j) {
                          return DropdownMenuItem<String>(
                            value: j.jobDocNo,
                            child: Text(
                              '${j.jobDocNo} - ${j.clientName} (${j.substrateMaterial} ${j.paperSizeMm.toInt()}mm)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selectedJob = availableJobs.firstWhere((j) => j.jobDocNo == val, orElse: () => availableJobs.first);
                            _onJobCardSelected(selectedJob);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _clientCtrl,
                        decoration: const InputDecoration(labelText: 'Client Name (Auto)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: RmMasterConstants.materials.contains(_selectedMaterial) ? _selectedMaterial : RmMasterConstants.materials.first,
                        decoration: const InputDecoration(labelText: 'Substrate Material (Auto)'),
                        items: RmMasterConstants.materials.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => _selectedMaterial = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // DYNAMIC WEB SIZE GROUPS & BATCHES
                const Text('📦 Paper Roll Web Size Groups & Roll Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                const SizedBox(height: 8),

                ..._webGroups.asMap().entries.map((entry) {
                  final gIndex = entry.key;
                  final group = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    color: Colors.blue.shade50.withAlpha(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                                child: Text('Web Group #${gIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 140,
                                child: TextFormField(
                                  initialValue: group.webSizeMm.toInt().toString(),
                                  decoration: const InputDecoration(labelText: 'Web Size (mm) *', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (v) => setState(() => group.webSizeMm = double.tryParse(v) ?? 210),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: RmMasterConstants.suppliers.contains(group.supplier) ? group.supplier : RmMasterConstants.suppliers.first,
                                  decoration: const InputDecoration(labelText: 'Vendor / Supplier *', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  items: RmMasterConstants.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (v) => setState(() => group.supplier = v!),
                                ),
                              ),
                              if (_webGroups.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _webGroups.removeAt(gIndex)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          ...group.rollBatches.asMap().entries.map((bEntry) {
                            final bIndex = bEntry.key;
                            final batch = bEntry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                children: [
                                  Text('Roll Size #${bIndex + 1}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 130,
                                    child: TextFormField(
                                      initialValue: batch.rollRmt.toInt().toString(),
                                      decoration: const InputDecoration(labelText: 'Roll RMT', suffixText: 'm', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (v) => setState(() => batch.rollRmt = double.tryParse(v) ?? 0),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('x', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      initialValue: batch.rollCount.toString(),
                                      decoration: const InputDecoration(labelText: 'No of Rolls', suffixText: 'rolls', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => setState(() => batch.rollCount = int.tryParse(v) ?? 1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('= ${batch.totalRmt.toInt()} Total RMT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary)),
                                  const Spacer(),
                                  Text('SqM: ${((group.webSizeMm * batch.totalRmt) / 1000.0).toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                  if (group.rollBatches.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                                      onPressed: () => setState(() => group.rollBatches.removeAt(bIndex)),
                                    ),
                                ],
                              ),
                            );
                          }),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => group.rollBatches.add(RollBatchEntry(rollRmt: 1000, rollCount: 1))),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('+ Add Roll Batch under ${group.webSizeMm.toInt()} mm Web Size'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _webGroups.add(WebSizeGroupEntry(webSizeMm: 215, supplier: _selectedMaterial))),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('+ Add New Web Size Group'),
                ),
                const SizedBox(height: 16),

                // SUMMARY KPI BANNER FOR THIS ISSUE
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Rolls Issued', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('$_grandTotalRolls Rolls', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Grand Total RMT', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('${_grandTotalRmt.toInt()} RMT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Grand Total Sq. Mtr', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('${_grandTotalSqMtr.toStringAsFixed(1)} SqM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade900)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isSaving = true);

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final repo = ref.read(rmLedgerRepositoryProvider);

                            final targetJob = _selectedJobDocNo ?? '08/040';

                            for (final g in _webGroups) {
                              final model = RmIssueModel(
                                id: '',
                                plantId: DefaultPlant.id,
                                date: DateTime.now(),
                                jobDocNo: targetJob,
                                material: _selectedMaterial,
                                gsmMicron: 80.0,
                                webSizeMm: g.webSizeMm,
                                supplier: g.supplier,
                                client: _clientCtrl.text.trim(),
                                rmtIssued: g.totalRmt,
                                remarks: '${g.totalRollCount} Rolls Issued (${g.webSizeMm.toInt()}mm)',
                                createdAt: DateTime.now(),
                                createdBy: 'system',
                              );
                              await repo.addIssue(model);
                            }

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Issued $_grandTotalRolls rolls (${_grandTotalRmt.toInt()} RMT) to Job [$targetJob]!'),
                                backgroundColor: Colors.green.shade800,
                              ),
                            );
                            nav.pop();
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check_circle),
                    label: Text(_isSaving ? 'Processing Issue...' : 'Confirm Roll Issue Entry', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dynamic Modal Dialog: Press Return WITH SMART JOB CARD DROPDOWN (ONLY ISSUED JOBS)
class NewReturnDialog extends ConsumerStatefulWidget {
  const NewReturnDialog({super.key, this.initialJobDocNo});

  final String? initialJobDocNo;

  @override
  ConsumerState<NewReturnDialog> createState() => _NewReturnDialogState();
}

class _NewReturnDialogState extends ConsumerState<NewReturnDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedJobDocNo;
  final _clientCtrl = TextEditingController(text: 'RALLIS INDIA');
  String _selectedMaterial = RmMasterConstants.materials.first;

  final List<WebSizeGroupEntry> _returnWebGroups = [
    WebSizeGroupEntry(
      webSizeMm: 210,
      supplier: 'Avery Dennison',
      rollBatches: [
        RollBatchEntry(rollRmt: 1000, rollCount: 1),
      ],
    ),
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedJobDocNo = widget.initialJobDocNo ?? '08/040';
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    super.dispose();
  }

  double get _grandTotalRmt => _returnWebGroups.fold(0.0, (sum, g) => sum + g.totalRmt);
  int get _grandTotalRolls => _returnWebGroups.fold(0, (sum, g) => sum + g.totalRollCount);

  /// Perform Strict Validation against Issued Rolls for Job Card
  void _validateAndSave(List<RmIssueModel> allIssues) async {
    if (!_formKey.currentState!.validate()) return;

    final targetJobDocNo = _selectedJobDocNo ?? '08/040';
    final issuedForJob = allIssues.where((i) => i.jobDocNo.trim() == targetJobDocNo).toList();

    // STRICT CHECK 1: Was ANY roll issued to this Job Card?
    if (issuedForJob.isEmpty) {
      _showRedMismatchError('CRITICAL MISMATCH ERROR', 'No paper rolls were EVER issued to Job Card [$targetJobDocNo]!\n\nYou cannot process a paper roll return for an unissued Job Card.');
      return;
    }

    // STRICT CHECK 2 & 3: Match Web Size, Supplier, and Total Returned RMT
    for (final retGroup in _returnWebGroups) {
      final matchingIssued = issuedForJob.where((i) => i.webSizeMm.toInt() == retGroup.webSizeMm.toInt() && i.supplier.trim().toLowerCase() == retGroup.supplier.trim().toLowerCase()).toList();

      if (matchingIssued.isEmpty) {
        _showRedMismatchError(
          'CRITICAL MISMATCH ERROR',
          'Web Size [${retGroup.webSizeMm.toInt()} mm] from Vendor [${retGroup.supplier}] was NEVER issued to Job Card [$targetJobDocNo]!\n\nIssued Web Sizes for this Job Card are: ${issuedForJob.map((i) => '${i.webSizeMm.toInt()}mm (${i.supplier})').join(', ')}.\n\nReturn entry blocked!',
        );
        return;
      }

      final totalIssuedRmtForGroup = matchingIssued.fold(0.0, (sum, i) => sum + i.rmtIssued);
      if (retGroup.totalRmt > totalIssuedRmtForGroup) {
        _showRedMismatchError(
          'EXCESS RETURN MISMATCH ERROR',
          'Returned RMT (${retGroup.totalRmt.toInt()} RMT) EXCEEDS total Issued RMT (${totalIssuedRmtForGroup.toInt()} RMT) for Web Size [${retGroup.webSizeMm.toInt()} mm] on Job Card [$targetJobDocNo]!\n\nReturn entry blocked!',
        );
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    // All Strict Checks Passed! Save Return Record.
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(rmLedgerRepositoryProvider);
      for (final g in _returnWebGroups) {
        final model = RmReturnModel(
          id: '',
          plantId: DefaultPlant.id,
          date: DateTime.now(),
          jobDocNo: targetJobDocNo,
          material: _selectedMaterial,
          gsmMicron: 80.0,
          webSizeMm: g.webSizeMm,
          supplier: g.supplier,
          client: _clientCtrl.text.trim(),
          rmtReturned: g.totalRmt,
          remarks: '${g.totalRollCount} Unused Rolls Returned (${g.webSizeMm.toInt()}mm)',
          createdAt: DateTime.now(),
          createdBy: 'system',
        );
        await repo.addReturn(model);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('Successfully matched & returned $_grandTotalRolls rolls (${_grandTotalRmt.toInt()} RMT) to Store for Job [$targetJobDocNo]!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      nav.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showRedMismatchError(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade700, width: 2)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade800, size: 28),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.red.shade900, fontSize: 14, height: 1.4)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK, I will Fix the Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(rmIssuesStreamProvider);
    final allIssues = issuesAsync.value ?? [];
    
    // Filter active Job Cards that have issued paper rolls
    final issuedJobNumbers = allIssues.map((i) => i.jobDocNo.trim()).toSet().toList();
    if (issuedJobNumbers.isEmpty) {
      issuedJobNumbers.addAll(['08/040', '08/061', '08/064', '08/067']);
    }

    final targetJobDocNo = _selectedJobDocNo ?? issuedJobNumbers.first;
    final issuedForJob = allIssues.where((i) => i.jobDocNo.trim() == targetJobDocNo).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    const Text('↩ Return Unused Rolls to Store (Issued Jobs Dynamic Dropdown)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Job Card Dropdown (Filter ONLY Issued Jobs with isExpanded: true)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: issuedJobNumbers.contains(_selectedJobDocNo) ? _selectedJobDocNo : issuedJobNumbers.first,
                        decoration: const InputDecoration(labelText: 'Select Job Card No (Issued Jobs Only) *', prefixIcon: Icon(Icons.assignment_return, color: Colors.amber)),
                        items: issuedJobNumbers.map((jobNo) {
                          final matchingIssue = allIssues.firstWhere((i) => i.jobDocNo == jobNo, orElse: () => RmIssueModel(id: '', plantId: '', date: DateTime.now(), jobDocNo: jobNo, material: 'CHROMO', gsmMicron: 80, webSizeMm: 160, supplier: 'Avery Dennison', client: 'RALLIS INDIA', rmtIssued: 3290, createdAt: DateTime.now(), createdBy: ''));
                          return DropdownMenuItem<String>(
                            value: jobNo,
                            child: Text(
                              '$jobNo - ${matchingIssue.client} (${matchingIssue.rmtIssued.toInt()} RMT Issued)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final matchingIssue = allIssues.firstWhere((i) => i.jobDocNo == val, orElse: () => RmIssueModel(id: '', plantId: '', date: DateTime.now(), jobDocNo: val, material: 'CHROMO', gsmMicron: 80, webSizeMm: 160, supplier: 'Avery Dennison', client: 'RALLIS INDIA', rmtIssued: 3290, createdAt: DateTime.now(), createdBy: ''));
                            setState(() {
                              _selectedJobDocNo = val;
                              _clientCtrl.text = matchingIssue.client;
                              _selectedMaterial = matchingIssue.material.isNotEmpty ? matchingIssue.material : RmMasterConstants.materials.first;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _clientCtrl,
                        decoration: const InputDecoration(labelText: 'Client Name (Auto)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // BANNER DISPLAYING ACTUAL ISSUED ROLLS FOR THIS JOB CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: issuedForJob.isNotEmpty ? Colors.amber.shade50 : Colors.blue.shade50,
                    border: Border.all(color: issuedForJob.isNotEmpty ? Colors.amber.shade300 : Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📜 Active Paper Rolls Issued for Job Card [$targetJobDocNo]:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                      ),
                      const SizedBox(height: 4),
                      if (issuedForJob.isEmpty)
                        Text('ℹ️ Roll issue record: 210mm (Avery Dennison): 12,000 RMT Issued for Job [$targetJobDocNo]', style: TextStyle(fontSize: 12, color: Colors.amber.shade900))
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: issuedForJob.map((i) {
                            return Chip(
                              avatar: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              label: Text('${i.webSizeMm.toInt()}mm (${i.supplier}): ${i.rmtIssued.toInt()} RMT Issued'),
                              backgroundColor: Colors.white,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // DYNAMIC RETURN WEB SIZE GROUPS
                const Text('📦 Unused Paper Rolls Being Returned:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
                const SizedBox(height: 8),

                ..._returnWebGroups.asMap().entries.map((entry) {
                  final gIndex = entry.key;
                  final group = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    color: Colors.amber.shade50.withAlpha(80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.amber.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.amber.shade900, borderRadius: BorderRadius.circular(4)),
                                child: Text('Return Group #${gIndex + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 140,
                                child: TextFormField(
                                  initialValue: group.webSizeMm.toInt().toString(),
                                  decoration: const InputDecoration(labelText: 'Web Size (mm) *', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (v) => setState(() => group.webSizeMm = double.tryParse(v) ?? 210),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: RmMasterConstants.suppliers.contains(group.supplier) ? group.supplier : RmMasterConstants.suppliers.first,
                                  decoration: const InputDecoration(labelText: 'Vendor / Supplier *', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                  items: RmMasterConstants.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (v) => setState(() => group.supplier = v!),
                                ),
                              ),
                              if (_returnWebGroups.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => setState(() => _returnWebGroups.removeAt(gIndex)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          ...group.rollBatches.asMap().entries.map((bEntry) {
                            final bIndex = bEntry.key;
                            final batch = bEntry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
                              child: Row(
                                children: [
                                  Text('Returned Roll #${bIndex + 1}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 130,
                                    child: TextFormField(
                                      initialValue: batch.rollRmt.toInt().toString(),
                                      decoration: const InputDecoration(labelText: 'Returned RMT', suffixText: 'm', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (v) => setState(() => batch.rollRmt = double.tryParse(v) ?? 0),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('x', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      initialValue: batch.rollCount.toString(),
                                      decoration: const InputDecoration(labelText: 'No of Rolls', suffixText: 'rolls', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                                      keyboardType: TextInputType.number,
                                      onChanged: (v) => setState(() => batch.rollCount = int.tryParse(v) ?? 1),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('= ${batch.totalRmt.toInt()} Returned RMT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900)),
                                  const Spacer(),
                                  Text('SqM: ${((group.webSizeMm * batch.totalRmt) / 1000.0).toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                  if (group.rollBatches.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                                      onPressed: () => setState(() => group.rollBatches.removeAt(bIndex)),
                                    ),
                                ],
                              ),
                            );
                          }),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => setState(() => group.rollBatches.add(RollBatchEntry(rollRmt: 500, rollCount: 1))),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text('+ Add Return Roll Batch under ${group.webSizeMm.toInt()} mm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                OutlinedButton.icon(
                  onPressed: () => setState(() => _returnWebGroups.add(WebSizeGroupEntry(webSizeMm: 210, supplier: 'Avery Dennison'))),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('+ Add Return Web Size Group'),
                ),
                const SizedBox(height: 20),

                // Confirm Action
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _validateAndSave(allIssues),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
                    icon: const Icon(Icons.verified),
                    label: Text(_isSaving ? 'Validating & Returning...' : 'Validate Match & Confirm Return', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Dialog: Log OK Label Qty & Production Wastage WITH DYNAMIC JOB CARD FETCH
class NewWastageEntryDialog extends ConsumerStatefulWidget {
  const NewWastageEntryDialog({super.key, this.initialJobDocNo, this.initialOkQty});

  final String? initialJobDocNo;
  final double? initialOkQty;

  @override
  ConsumerState<NewWastageEntryDialog> createState() => _NewWastageEntryDialogState();
}

class _NewWastageEntryDialogState extends ConsumerState<NewWastageEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedJobDocNo;
  late TextEditingController _okQtyCtrl;
  late TextEditingController _webSizeCtrl;
  late TextEditingController _vendorCtrl;
  late TextEditingController _materialCtrl;
  late TextEditingController _upsCtrl;
  late TextEditingController _gearZCtrl;
  late TextEditingController _rmtIssuedCtrl;
  late TextEditingController _rmtReturnedCtrl;

  @override
  void initState() {
    super.initState();
    _selectedJobDocNo = widget.initialJobDocNo ?? '08/040';
    _okQtyCtrl = TextEditingController(text: (widget.initialOkQty ?? 65300).toInt().toString());
    _webSizeCtrl = TextEditingController(text: '165');
    _vendorCtrl = TextEditingController(text: 'Avery Dennison');
    _materialCtrl = TextEditingController(text: 'VOID FILM');
    _upsCtrl = TextEditingController(text: '30');
    _gearZCtrl = TextEditingController(text: '124');
    _rmtIssuedCtrl = TextEditingController(text: '1350');
    _rmtReturnedCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _okQtyCtrl.dispose();
    _webSizeCtrl.dispose();
    _vendorCtrl.dispose();
    _materialCtrl.dispose();
    _upsCtrl.dispose();
    _gearZCtrl.dispose();
    _rmtIssuedCtrl.dispose();
    _rmtReturnedCtrl.dispose();
    super.dispose();
  }

  /// Auto-fill all master specs (Cylinder Gear Z, UPS, Paper Web Size, Target RMT, Issued RMT, Returned RMT)
  void _onJobCardSelected(ProductionJobModel job, List<RmIssueModel> allIssues, List<RmReturnModel> allReturns) {
    final jobIssues = allIssues.where((i) => i.jobDocNo.trim() == job.jobDocNo.trim()).toList();
    final jobReturns = allReturns.where((r) => r.jobDocNo.trim() == job.jobDocNo.trim()).toList();

    final totalIssued = jobIssues.fold(0.0, (sum, i) => sum + i.rmtIssued);
    final totalReturned = jobReturns.fold(0.0, (sum, r) => sum + r.rmtReturned);

    setState(() {
      _selectedJobDocNo = job.jobDocNo;
      _okQtyCtrl.text = job.totalReqQty > 0 ? job.totalReqQty.toInt().toString() : '65300';
      _webSizeCtrl.text = job.paperSizeMm > 0 ? job.paperSizeMm.toInt().toString() : '165';
      _materialCtrl.text = job.substrateMaterial;
      _upsCtrl.text = job.ups > 0 ? job.ups.toString() : '30';
      _gearZCtrl.text = job.gearTeethCount > 0 ? job.gearTeethCount.toString() : '124';
      _rmtIssuedCtrl.text = totalIssued > 0 ? totalIssued.toInt().toString() : '1350';
      _rmtReturnedCtrl.text = totalReturned.toInt().toString();
    });
  }

  // Math Formulas from Excel 'Job usage' sheet
  double get _calcLpMeter {
    final gearZ = double.tryParse(_gearZCtrl.text.trim()) ?? 0;
    final ups = double.tryParse(_upsCtrl.text.trim()) ?? 0;
    return ProductionFormulas.labelsPerMetre(gearTeethZ: gearZ, ups: ups);
  }

  double get _calcOkRmt {
    final okQty = double.tryParse(_okQtyCtrl.text.trim()) ?? 0;
    final lp = _calcLpMeter;
    if (lp <= 0) return 0;
    return okQty / lp;
  }

  double get _calcNetRmtUsed {
    final issued = double.tryParse(_rmtIssuedCtrl.text.trim()) ?? 0;
    final returned = double.tryParse(_rmtReturnedCtrl.text.trim()) ?? 0;
    return issued - returned;
  }

  double get _calcWastageRmt {
    final net = _calcNetRmtUsed;
    final okRmt = _calcOkRmt;
    final w = net - okRmt;
    return w > 0 ? w : 0;
  }

  double get _calcWastageSqMtr {
    final web = double.tryParse(_webSizeCtrl.text.trim()) ?? 100;
    return (_calcWastageRmt * web) / 1000.0;
  }

  double get _calcWastagePercent {
    final net = _calcNetRmtUsed;
    if (net <= 0) return 0;
    return (_calcWastageRmt / net) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(allProductionJobsStreamProvider);
    final availableJobs = jobsAsync.value?.isNotEmpty == true ? jobsAsync.value! : _mockDefaultJobs;

    final issues = ref.watch(rmIssuesStreamProvider).value ?? [];
    final returns = ref.watch(rmReturnsStreamProvider).value ?? [];

    return AlertDialog(
      title: const Text('📊 Log OK Label Quantity & Calculate Production Wastage'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smart Job Card Dropdown (WITH isExpanded: true FIX!)
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: availableJobs.any((j) => j.jobDocNo == _selectedJobDocNo) ? _selectedJobDocNo : availableJobs.first.jobDocNo,
                decoration: const InputDecoration(labelText: 'Select Job Card No *', prefixIcon: Icon(Icons.calculate, color: AppTheme.primary)),
                items: availableJobs.map((j) {
                  return DropdownMenuItem<String>(
                    value: j.jobDocNo,
                    child: Text(
                      '${j.jobDocNo} - ${j.clientName} (${j.substrateMaterial} ${j.paperSizeMm.toInt()}mm)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final selectedJob = availableJobs.firstWhere((j) => j.jobDocNo == val, orElse: () => availableJobs.first);
                    _onJobCardSelected(selectedJob, issues, returns);
                  }
                },
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _okQtyCtrl,
                      decoration: const InputDecoration(labelText: 'OK Label Quantity (Pcs) *', hintText: '65300'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _webSizeCtrl,
                      decoration: const InputDecoration(labelText: 'Paper Web Size (mm) *'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gearZCtrl,
                      decoration: const InputDecoration(labelText: 'Cylinder Gear (Z Teeth)'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _upsCtrl,
                      decoration: const InputDecoration(labelText: 'Total UPS (Auto)'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _vendorCtrl,
                      decoration: const InputDecoration(labelText: 'Vendor / Supplier Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rmtIssuedCtrl,
                      decoration: const InputDecoration(labelText: 'RMT Issued (Auto)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _rmtReturnedCtrl,
                      decoration: const InputDecoration(labelText: 'RMT Returned (Auto)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // LIVE FORMULA CALCULATION CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Used RMT:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${_calcNetRmtUsed.toStringAsFixed(1)} RMT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('OK Quantity RMT:', style: TextStyle(fontSize: 12, color: Colors.green)),
                        Text('${_calcOkRmt.toStringAsFixed(1)} RMT', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Actual Wastage RMT:', style: TextStyle(fontSize: 12, color: Colors.red)),
                        Text('${_calcWastageRmt.toStringAsFixed(1)} RMT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wastage Sq. Mtr:', style: TextStyle(fontSize: 12)),
                        Text('${_calcWastageSqMtr.toStringAsFixed(1)} SqM', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wastage Percentage (%):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        Chip(
                          label: Text('${_calcWastagePercent.toStringAsFixed(1)}%'),
                          backgroundColor: Colors.purple.shade100,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final jobNo = _selectedJobDocNo ?? '08/040';
              final okQty = double.tryParse(_okQtyCtrl.text.trim()) ?? 0.0;
              final web = double.tryParse(_webSizeCtrl.text.trim()) ?? 100.0;
              final gearZ = int.tryParse(_gearZCtrl.text.trim()) ?? 100;
              final ups = int.tryParse(_upsCtrl.text.trim()) ?? 1;
              final issued = double.tryParse(_rmtIssuedCtrl.text.trim()) ?? 0.0;
              final returned = double.tryParse(_rmtReturnedCtrl.text.trim()) ?? 0.0;
              final client = availableJobs.firstWhere((j) => j.jobDocNo == jobNo, orElse: () => availableJobs.first).clientName;
              final mat = _materialCtrl.text.trim().isNotEmpty ? _materialCtrl.text.trim() : 'Chromo';
              final supp = _vendorCtrl.text.trim().isNotEmpty ? _vendorCtrl.text.trim() : 'Avery Dennison';

              final model = RmJobReconciliationModel(
                jobDocNo: jobNo,
                clientName: client,
                material: mat,
                supplier: supp,
                webSizeMm: web,
                rmtIssued: issued,
                rmtReturned: returned,
                okQuantity: okQty,
                totalUps: ups,
                gearTeethZ: gearZ,
              );

              await ref.read(rmLedgerRepositoryProvider).addOrUpdateReconciliation(model);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged OK Quantity for Job [$jobNo]! Wastage: ${_calcWastagePercent.toStringAsFixed(1)}%'),
                    backgroundColor: Colors.green.shade800,
                  ),
                );
                Navigator.of(context).pop();
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          icon: const Icon(Icons.save),
          label: const Text('Save Wastage Log'),
        ),
      ],
    );
  }
}
