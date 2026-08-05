import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/die_model.dart';
import '../../logic/tooling_providers.dart';

/// Dedicated Punch / Die Revision & Correction Wizard Screen.
/// Allows searching for existing Punch/Die (by Die Code, Product SKU, or Customer Name),
/// specifying revision notes/resharpening logs, and auto-generating revised Die master records.
class DieRevisionWizardScreen extends ConsumerStatefulWidget {
  const DieRevisionWizardScreen({super.key, this.initialDie});

  final DieModel? initialDie;

  @override
  ConsumerState<DieRevisionWizardScreen> createState() => _DieRevisionWizardScreenState();
}

class _DieRevisionWizardScreenState extends ConsumerState<DieRevisionWizardScreen> {
  final _formKey = GlobalKey<FormState>();

  DieModel? _selectedDie;
  String _searchQuery = '';

  late TextEditingController _revCodeController;
  late TextEditingController _revisionTagController;
  late TextEditingController _remadeNotesController;
  late TextEditingController _rackBinController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDie != null) {
      _selectDie(widget.initialDie!);
    } else {
      _revCodeController = TextEditingController();
      _revisionTagController = TextEditingController(text: 'Rev 2 (Remade)');
      _remadeNotesController = TextEditingController();
      _rackBinController = TextEditingController();
    }
  }

  void _selectDie(DieModel die) {
    setState(() {
      _selectedDie = die;

      final currentRev = die.revisionTag.isNotEmpty ? die.revisionTag : 'Rev 1';
      final nextRevNum = (int.tryParse(currentRev.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1) + 1;

      final newCode = die.dieCode.contains('-R')
          ? '${die.dieCode.substring(0, die.dieCode.lastIndexOf('-R'))}-R$nextRevNum'
          : '${die.dieCode}-R$nextRevNum';

      _revCodeController = TextEditingController(text: newCode);
      _revisionTagController = TextEditingController(text: 'Rev $nextRevNum (Remade / Revised)');
      _remadeNotesController = TextEditingController(text: 'Die re-sharpened / cavity modified for job repeat');
      _rackBinController = TextEditingController(text: die.storageRackBin);
    });
  }

  @override
  void dispose() {
    _revCodeController.dispose();
    _revisionTagController.dispose();
    _remadeNotesController.dispose();
    _rackBinController.dispose();
    super.dispose();
  }

  Future<void> _saveRevision() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an existing Punch / Die to revise')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(toolingRepositoryProvider);

      final revisedDie = DieModel(
        id: '',
        plantId: DefaultPlant.id,
        dieCode: _revCodeController.text.trim().toUpperCase(),
        dieType: _selectedDie!.dieType,
        shape: _selectedDie!.shape,
        customerId: _selectedDie!.customerId,
        customerName: _selectedDie!.customerName,
        productId: _selectedDie!.productId,
        internalSkuCode: _selectedDie!.internalSkuCode,
        productName: _selectedDie!.productName,
        labelWidthMm: _selectedDie!.labelWidthMm,
        labelHeightMm: _selectedDie!.labelHeightMm,
        cornerRadiusMm: _selectedDie!.cornerRadiusMm,
        cylinderRepeatMm: _selectedDie!.cylinderRepeatMm,
        gearTeethCount: _selectedDie!.gearTeethCount,
        webUps: _selectedDie!.webUps,
        repeatUps: _selectedDie!.repeatUps,
        revisionTag: _revisionTagController.text.trim(),
        remadeNotes: _remadeNotesController.text.trim(),
        storageRackBin: _rackBinController.text.trim(),
        condition: DieCondition.remade,
        status: DieStatus.available,
        createdAt: DateTime.now(),
        createdBy: 'system',
      );

      await repo.createDie(revisedDie);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Die Revision ${revisedDie.dieCode} saved successfully!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving die revision: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diesAsync = ref.watch(diesStreamProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Punch / Die Revision & Remake Wizard'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // STEP 1: Search & Select Existing Die
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.amber.shade400, width: 1.5)),
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search, color: Colors.amber, size: 22),
                        SizedBox(width: 8),
                        Text('Step 1: Search & Select Existing Punch / Die', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedDie == null) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Die Code, Customer Name, or Product SKU...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 180,
                        child: diesAsync.when(
                          data: (dies) {
                            final filtered = dies.where((d) {
                              if (_searchQuery.isEmpty) return true;
                              return d.dieCode.toLowerCase().contains(_searchQuery) ||
                                  d.customerName.toLowerCase().contains(_searchQuery) ||
                                  d.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                                  d.productName.toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (filtered.isEmpty) {
                              return const Center(child: Text('No existing dies found matching search.'));
                            }

                            return ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final d = filtered[index];
                                return ListTile(
                                  tileColor: Colors.white,
                                  title: Text('${d.dieCode} (${d.dieType})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('SKU: ${d.internalSkuCode} | Customer: ${d.customerName} | Size: ${d.specLabel}'),
                                  trailing: ElevatedButton(
                                    onPressed: () => _selectDie(d),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                                    child: const Text('Select Die', style: TextStyle(fontSize: 12)),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error loading dies: $err'),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.architecture, color: AppTheme.primary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedDie!.dieCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                                  Text('${_selectedDie!.productName} (${_selectedDie!.internalSkuCode})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('Customer: ${_selectedDie!.customerName} | Type: ${_selectedDie!.dieType} | Size: ${_selectedDie!.specLabel}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _selectedDie = null),
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: const Text('Change Die', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_selectedDie != null) ...[
              const SizedBox(height: 16),

              // STEP 2: Revision Details & Resharpening Notes
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note, color: AppTheme.primary, size: 22),
                          SizedBox(width: 8),
                          Text('Step 2: Punch / Die Revision & Modification Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _revCodeController,
                              decoration: const InputDecoration(labelText: 'Revised Die Code *', hintText: 'e.g. DIE-50x80-R2'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _revisionTagController,
                              decoration: const InputDecoration(labelText: 'Revision Tag / Suffix *'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _remadeNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Revision / Remake / Resharpening Notes *',
                          hintText: 'e.g. Cavity modified / re-sharpened for clean release',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _rackBinController,
                        decoration: const InputDecoration(labelText: 'Storage Rack Location'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Revision Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveRevision,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    _isSaving ? 'Saving Revision...' : 'Save & Issue Revised Punch / Die Master',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
