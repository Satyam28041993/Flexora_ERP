import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/customer_model.dart';
import '../../logic/customer_providers.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  final CustomerModel? customer;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _gstController;
  late TextEditingController _panController;

  late TextEditingController _contactNameController;
  late TextEditingController _contactDesignationController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactEmailController;

  late TextEditingController _billingAddr1Controller;
  late TextEditingController _billingAddr2Controller;
  late TextEditingController _billingCityController;
  late TextEditingController _billingStateController;
  late TextEditingController _billingPincodeController;

  late TextEditingController _specialInstructionsController;
  late TextEditingController _packingReqController;
  late TextEditingController _qcReqController;

  String _status = CustomerStatus.active;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;

    _codeController = TextEditingController(text: c?.customerCode ?? '');
    _nameController = TextEditingController(text: c?.companyName ?? '');
    _gstController = TextEditingController(text: c?.gstNo ?? '');
    _panController = TextEditingController(text: c?.panNo ?? '');

    _contactNameController = TextEditingController(text: c?.primaryContact.name ?? '');
    _contactDesignationController = TextEditingController(text: c?.primaryContact.designation ?? '');
    _contactPhoneController = TextEditingController(text: c?.primaryContact.phone ?? '');
    _contactEmailController = TextEditingController(text: c?.primaryContact.email ?? '');

    _billingAddr1Controller = TextEditingController(text: c?.billingAddress.addressLine1 ?? '');
    _billingAddr2Controller = TextEditingController(text: c?.billingAddress.addressLine2 ?? '');
    _billingCityController = TextEditingController(text: c?.billingAddress.city ?? '');
    _billingStateController = TextEditingController(text: c?.billingAddress.state ?? '');
    _billingPincodeController = TextEditingController(text: c?.billingAddress.pincode ?? '');

    _specialInstructionsController = TextEditingController(text: c?.specialInstructions ?? '');
    _packingReqController = TextEditingController(text: c?.packingRequirements ?? '');
    _qcReqController = TextEditingController(text: c?.qcRequirements ?? '');

    _status = c?.status ?? CustomerStatus.active;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _contactNameController.dispose();
    _contactDesignationController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _billingAddr1Controller.dispose();
    _billingAddr2Controller.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingPincodeController.dispose();
    _specialInstructionsController.dispose();
    _packingReqController.dispose();
    _qcReqController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(customerRepositoryProvider);

      final customerData = CustomerModel(
        id: widget.customer?.id ?? '',
        plantId: DefaultPlant.id,
        customerCode: _codeController.text.trim().toUpperCase(),
        companyName: _nameController.text.trim(),
        gstNo: _gstController.text.trim().isEmpty ? null : _gstController.text.trim(),
        panNo: _panController.text.trim().isEmpty ? null : _panController.text.trim(),
        primaryContact: ContactPersonModel(
          name: _contactNameController.text.trim(),
          designation: _contactDesignationController.text.trim(),
          phone: _contactPhoneController.text.trim(),
          email: _contactEmailController.text.trim(),
        ),
        billingAddress: AddressModel(
          addressLine1: _billingAddr1Controller.text.trim(),
          addressLine2: _billingAddr2Controller.text.trim(),
          city: _billingCityController.text.trim(),
          state: _billingStateController.text.trim(),
          pincode: _billingPincodeController.text.trim(),
        ),
        specialInstructions: _specialInstructionsController.text.trim().isEmpty
            ? null
            : _specialInstructionsController.text.trim(),
        packingRequirements:
            _packingReqController.text.trim().isEmpty ? null : _packingReqController.text.trim(),
        qcRequirements:
            _qcReqController.text.trim().isEmpty ? null : _qcReqController.text.trim(),
        status: _status,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        createdBy: widget.customer?.createdBy ?? 'system',
        updatedAt: widget.customer != null ? DateTime.now() : null,
        updatedBy: widget.customer != null ? 'system' : null,
      );

      if (widget.customer == null) {
        await repo.createCustomer(customerData);
      } else {
        await repo.updateCustomer(customerData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.customer == null
                ? 'Customer created successfully'
                : 'Customer updated successfully'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving customer: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Customer' : 'New Customer Master'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Company Information'),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Code *',
                      hintText: 'e.g. CUST-01',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name *',
                      hintText: 'Full Legal Name',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST Number'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _panController,
                    decoration: const InputDecoration(labelText: 'PAN Number'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Primary Contact Person'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(labelText: 'Contact Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _contactDesignationController,
                    decoration: const InputDecoration(labelText: 'Designation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(labelText: 'Phone / Mobile *'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Billing Address'),
            TextFormField(
              controller: _billingAddr1Controller,
              decoration: const InputDecoration(labelText: 'Address Line 1 *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _billingAddr2Controller,
              decoration: const InputDecoration(labelText: 'Address Line 2'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _billingCityController,
                    decoration: const InputDecoration(labelText: 'City *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _billingStateController,
                    decoration: const InputDecoration(labelText: 'State *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _billingPincodeController,
                    decoration: const InputDecoration(labelText: 'Pincode *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Customer Instructions & Rules'),
            TextFormField(
              controller: _specialInstructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Special Handling / Business Instructions',
                hintText: 'Specific preferences or rules for this client',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _packingReqController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'General Packing Requirements',
                hintText: 'e.g. Core size, labels per roll, box labeling',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qcReqController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'General QC Requirements',
                hintText: 'e.g. Specific test requirements, COA needed',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: CustomerStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
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
                label: Text(_isSaving ? 'Saving...' : (isEdit ? 'Update Customer' : 'Save Customer Master')),
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
