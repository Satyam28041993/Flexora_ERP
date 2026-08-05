import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/services/iso_report_exporter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/supplier_model.dart';
import '../../logic/supplier_providers.dart';

/// Approved Supplier Master (ISO XYZ/PUR/F/01-03).
///
/// Backed by the `suppliers` Firestore collection. Names were bulk-imported
/// from the PGPL stock workbook with commercial details blank, so the register
/// highlights rows that still need GSTIN/phone before a PO can be raised.
class SupplierRegistrationScreen extends ConsumerStatefulWidget {
  const SupplierRegistrationScreen({super.key});

  @override
  ConsumerState<SupplierRegistrationScreen> createState() =>
      _SupplierRegistrationScreenState();
}

class _SupplierRegistrationScreenState
    extends ConsumerState<SupplierRegistrationScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _onlyIncomplete = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SupplierModel> _filter(List<SupplierModel> all) {
    return all.where((s) {
      if (_onlyIncomplete && s.hasCommercialDetails) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return s.companyName.toLowerCase().contains(q) ||
          s.supplierCode.toLowerCase().contains(q) ||
          s.materialCategory.toLowerCase().contains(q) ||
          s.gstNo.toLowerCase().contains(q);
    }).toList();
  }

  void _exportApprovedSuppliersIso(List<SupplierModel> suppliers) {
    final doc = IsoReportDocument(
      title: 'LIST OF APPROVED SUPPLIERS',
      docNo: 'XYZ/PUR/F/02',
      revNo: '01',
      revDate: '01.06.2024',
      preparedBy: 'Purchase Manager',
      approvedBy: 'Managing Director',
      headers: const [
        'Supplier Code',
        'Supplier Name',
        'Material Category',
        'Contact Person & Mobile',
        'Email & Address',
        'GSTIN / PAN',
        'ISO Status',
        'Status',
      ],
      dataRows: suppliers
          .map((s) => [
                s.supplierCode,
                s.companyName,
                s.materialCategory,
                '${s.contactPerson} ${s.phone.isEmpty ? '' : '(${s.phone})'}'.trim(),
                '${s.email}\n${s.address}'.trim(),
                '${s.gstNo}\n${s.panNo}'.trim(),
                s.isoCertification,
                s.status,
              ])
          .toList(),
    );
    IsoReportExporter.exportIsoPdf(doc);
  }

  Future<void> _showSupplierDialog({SupplierModel? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.companyName ?? '');
    final catCtrl = TextEditingController(text: existing?.materialCategory ?? '');
    final contactCtrl = TextEditingController(text: existing?.contactPerson ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final gstCtrl = TextEditingController(text: existing?.gstNo ?? '');
    final panCtrl = TextEditingController(text: existing?.panNo ?? '');
    var isoStatus = existing?.isoCertification.isNotEmpty == true
        ? existing!.isoCertification
        : 'Not recorded';

    const isoOptions = [
      'Not recorded',
      'Yes (ISO 9001:2015)',
      'In Progress',
      'No',
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(isEdit
              ? 'Edit Supplier — ${existing.supplierCode}'
              : 'New Supplier Registration (XYZ/PUR/F/01)'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Supplier Company Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: catCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Material Category (Paper / Ink / Die / Film)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: contactCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Mobile / Phone No.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Registered Office Address & City / State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: gstCtrl,
                          decoration: const InputDecoration(
                            labelText: 'GSTIN No.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: panCtrl,
                          decoration: const InputDecoration(
                            labelText: 'PAN Card No.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: isoStatus,
                    decoration: const InputDecoration(
                      labelText: 'ISO 9001 Certification Status',
                      border: OutlineInputBorder(),
                    ),
                    items: isoOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setLocal(() => isoStatus = v ?? isoStatus),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final repo = ref.read(supplierRepositoryProvider);
                final now = DateTime.now();
                try {
                  if (isEdit) {
                    await repo.updateSupplier(existing.copyWith(
                      companyName: name,
                      materialCategory: catCtrl.text.trim(),
                      contactPerson: contactCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      gstNo: gstCtrl.text.trim(),
                      panNo: panCtrl.text.trim(),
                      isoCertification: isoStatus,
                      updatedAt: now,
                      updatedBy: 'purchase',
                    ));
                  } else {
                    await repo.createSupplier(SupplierModel(
                      id: '',
                      plantId: DefaultPlant.id,
                      supplierCode: 'SUP-${now.millisecondsSinceEpoch % 100000}',
                      companyName: name,
                      materialCategory: catCtrl.text.trim(),
                      contactPerson: contactCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      gstNo: gstCtrl.text.trim(),
                      panNo: panCtrl.text.trim(),
                      isoCertification: isoStatus,
                      createdAt: now,
                      createdBy: 'purchase',
                    ));
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isEdit
                          ? 'Supplier "$name" updated.'
                          : 'Supplier "$name" registered.'),
                      backgroundColor: Colors.green.shade800,
                    ));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Could not save supplier: $e'),
                      backgroundColor: AppTheme.danger,
                    ));
                  }
                }
              },
              label: Text(isEdit ? 'Save Changes' : 'Register Supplier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(SupplierModel s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text(
          '"${s.companyName}" will be removed from the supplier master.\n\n'
          'Existing stock and purchase records that reference this supplier '
          'are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(supplierRepositoryProvider).deleteSupplier(s.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Supplier "${s.companyName}" deleted.'),
          backgroundColor: Colors.orange.shade800,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not delete: $e'),
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏭 Approved Supplier Master (XYZ/PUR/F/01-02)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showSupplierDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('New Supplier'),
      ),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading suppliers: $e')),
        data: (all) {
          final filtered = _filter(all);
          final incomplete = all.where((s) => !s.hasCommercialDetails).length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) =>
                            setState(() => _query = v.trim()),
                        decoration: InputDecoration(
                          hintText:
                              'Search supplier name, code, category or GSTIN...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => setState(() {
                                    _searchCtrl.clear();
                                    _query = '';
                                  }),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _exportApprovedSuppliersIso(filtered),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export ISO PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.badge, size: 16),
                      label: Text('${all.length} suppliers'),
                      backgroundColor: AppTheme.primary.withAlpha(24),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _onlyIncomplete,
                      onSelected: (v) => setState(() => _onlyIncomplete = v),
                      avatar: Icon(
                        Icons.error_outline,
                        size: 16,
                        color: incomplete > 0 ? AppTheme.danger : Colors.grey,
                      ),
                      label: Text('$incomplete need GSTIN / phone'),
                      selectedColor: AppTheme.danger.withAlpha(30),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No suppliers match this search.'),
                        )
                      : Card(
                          elevation: 2,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 22,
                                columns: const [
                                  DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Contact & Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('GSTIN / PAN', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('ISO', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: filtered.map((s) {
                                  final incompleteRow = !s.hasCommercialDetails;
                                  return DataRow(
                                    color: incompleteRow
                                        ? WidgetStatePropertyAll(
                                            AppTheme.danger.withAlpha(12))
                                        : null,
                                    cells: [
                                      DataCell(Text(s.supplierCode,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                      DataCell(Text(s.companyName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                      DataCell(Text(s.materialCategory.isEmpty
                                          ? '—'
                                          : s.materialCategory)),
                                      DataCell(Text(
                                        [s.contactPerson, s.phone]
                                                .where((x) => x.isNotEmpty)
                                                .join('\n')
                                                .isEmpty
                                            ? '—'
                                            : [s.contactPerson, s.phone]
                                                .where((x) => x.isNotEmpty)
                                                .join('\n'),
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                      DataCell(Text(
                                        [s.gstNo, s.panNo]
                                                .where((x) => x.isNotEmpty)
                                                .join('\n')
                                                .isEmpty
                                            ? '—'
                                            : [s.gstNo, s.panNo]
                                                .where((x) => x.isNotEmpty)
                                                .join('\n'),
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                      DataCell(Text(s.isoCertification.isEmpty
                                          ? '—'
                                          : s.isoCertification)),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit',
                                            icon: const Icon(Icons.edit,
                                                size: 18,
                                                color: AppTheme.primary),
                                            onPressed: () => _showSupplierDialog(
                                                existing: s),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete',
                                            icon: const Icon(Icons.delete,
                                                size: 18,
                                                color: AppTheme.danger),
                                            onPressed: () => _confirmDelete(s),
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
