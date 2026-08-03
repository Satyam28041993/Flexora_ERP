import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/plate_model.dart';
import '../../logic/tooling_providers.dart';

/// Dedicated Plate Revision & Correction Wizard Screen.
/// Allows operators to search for an existing Plate Master (by Code, Product SKU, or Customer),
/// select specific color plates being remade/corrected, auto-generate revision codes (e.g. PL-SKU-R2),
/// and save the revised Plate Master with complete correction logs.
class PlateRevisionWizardScreen extends ConsumerStatefulWidget {
  const PlateRevisionWizardScreen({super.key, this.initialPlate});

  final PlateModel? initialPlate;

  @override
  ConsumerState<PlateRevisionWizardScreen> createState() => _PlateRevisionWizardScreenState();
}

class _PlateRevisionWizardScreenState extends ConsumerState<PlateRevisionWizardScreen> {
  final _formKey = GlobalKey<FormState>();

  PlateModel? _selectedPlate;
  String _searchQuery = '';

  late TextEditingController _revCodeController;
  late TextEditingController _revisionTagController;
  late TextEditingController _remadeColorsController;
  late TextEditingController _colorDetailsController;
  late TextEditingController _revisionReasonController;
  late TextEditingController _rackBinController;

  final Map<String, bool> _colorSelection = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPlate != null) {
      _selectPlate(widget.initialPlate!);
    } else {
      _revCodeController = TextEditingController();
      _revisionTagController = TextEditingController(text: 'Rev 2 (Colors Changed)');
      _remadeColorsController = TextEditingController();
      _colorDetailsController = TextEditingController();
      _revisionReasonController = TextEditingController();
      _rackBinController = TextEditingController();
    }
  }

  void _selectPlate(PlateModel plate) {
    setState(() {
      _selectedPlate = plate;

      // Extract revision index (e.g. Rev 1 -> Rev 2)
      final currentRev = plate.revisionTag.isNotEmpty ? plate.revisionTag : 'Rev 1';
      final nextRevNum = (int.tryParse(currentRev.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1) + 1;

      final newCode = plate.plateCode.contains('-R')
          ? '${plate.plateCode.substring(0, plate.plateCode.lastIndexOf('-R'))}-R$nextRevNum'
          : '${plate.plateCode}-R$nextRevNum';

      _revCodeController = TextEditingController(text: newCode);
      _revisionTagController = TextEditingController(text: 'Rev $nextRevNum (Colors Changed)');
      _remadeColorsController = TextEditingController(text: plate.remadeColors.isNotEmpty ? plate.remadeColors : 'Black Plate Remade');
      _colorDetailsController = TextEditingController(text: plate.colorDetails);
      _revisionReasonController = TextEditingController(text: 'Text/Design Correction');
      _rackBinController = TextEditingController(text: plate.storageRackBin);

      // Parse color breakdown into selection checkboxes
      _colorSelection.clear();
      if (plate.colorDetails.isNotEmpty) {
        final colors = plate.colorDetails.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (final c in colors) {
          _colorSelection[c] = c.toLowerCase().contains('black') || c.toLowerCase().contains('spot');
        }
      } else {
        _colorSelection['Cyan'] = false;
        _colorSelection['Magenta'] = false;
        _colorSelection['Yellow'] = false;
        _colorSelection['Black'] = true;
      }
    });
  }

  @override
  void dispose() {
    _revCodeController.dispose();
    _revisionTagController.dispose();
    _remadeColorsController.dispose();
    _colorDetailsController.dispose();
    _revisionReasonController.dispose();
    _rackBinController.dispose();
    super.dispose();
  }

  void _updateRemadeColorsFromCheckboxes() {
    final selectedColors = _colorSelection.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedColors.isNotEmpty) {
      _remadeColorsController.text = '${selectedColors.join(', ')} Plate(s) Remade';
    }
  }

  Future<void> _saveRevision() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an existing Plate to revise')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(toolingRepositoryProvider);

      final revisedPlate = PlateModel(
        id: '',
        plantId: DefaultPlant.id,
        plateCode: _revCodeController.text.trim().toUpperCase(),
        customerId: _selectedPlate!.customerId,
        customerName: _selectedPlate!.customerName,
        productId: _selectedPlate!.productId,
        internalSkuCode: _selectedPlate!.internalSkuCode,
        productName: _selectedPlate!.productName,
        artworkVersionId: _selectedPlate!.artworkVersionId,
        artworkVersionLabel: _selectedPlate!.artworkVersionLabel,
        colorCount: _selectedPlate!.colorCount,
        colorDetails: _colorDetailsController.text.trim(),
        revisionTag: _revisionTagController.text.trim(),
        remadeColors: _remadeColorsController.text.trim(),
        polymerThicknessMm: _selectedPlate!.polymerThicknessMm,
        cylinderRepeatMm: _selectedPlate!.cylinderRepeatMm,
        storageRackBin: _rackBinController.text.trim(),
        condition: PlateCondition.partialRemake,
        status: PlateStatus.available,
        createdAt: DateTime.now(),
        createdBy: 'system',
      );

      await repo.createPlate(revisedPlate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plate Revision ${revisedPlate.plateCode} saved successfully!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plate revision: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platesAsync = ref.watch(platesStreamProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Plate Revision & Correction Wizard'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // STEP 1: Search & Select Master Plate
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
                        Text('Step 1: Search & Select Existing Master Plate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedPlate == null) ...[
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Plate Code, Customer Name, or Product SKU...',
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
                        child: platesAsync.when(
                          data: (plates) {
                            final filtered = plates.where((p) {
                              if (_searchQuery.isEmpty) return true;
                              return p.plateCode.toLowerCase().contains(_searchQuery) ||
                                  p.customerName.toLowerCase().contains(_searchQuery) ||
                                  p.internalSkuCode.toLowerCase().contains(_searchQuery) ||
                                  p.productName.toLowerCase().contains(_searchQuery);
                            }).toList();

                            if (filtered.isEmpty) {
                              return const Center(child: Text('No existing plates found matching search.'));
                            }

                            return ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final p = filtered[index];
                                return ListTile(
                                  tileColor: Colors.white,
                                  title: Text('${p.plateCode} — ${p.productName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('SKU: ${p.internalSkuCode} | Customer: ${p.customerName} | Rev: ${p.revisionTag}'),
                                  trailing: ElevatedButton(
                                    onPressed: () => _selectPlate(p),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                                    child: const Text('Select Plate', style: TextStyle(fontSize: 12)),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error loading plates: $err'),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: AppTheme.primary, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedPlate!.plateCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                                  Text('${_selectedPlate!.productName} (${_selectedPlate!.internalSkuCode})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('Customer: ${_selectedPlate!.customerName} | Current Rev: ${_selectedPlate!.revisionTag}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _selectedPlate = null),
                              icon: const Icon(Icons.swap_horiz, size: 16),
                              label: const Text('Change Plate', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_selectedPlate != null) ...[
              const SizedBox(height: 16),

              // STEP 2: Revision Details & Color Remake Picker
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
                          Text('Step 2: Plate Remake / Correction Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _revCodeController,
                              decoration: const InputDecoration(labelText: 'Revised Plate Code *', hintText: 'e.g. PL-SKU-101-R2'),
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
                      const SizedBox(height: 16),

                      // Color Checklist for Partial Remake
                      const Text('Select Which Color Plates Were Remade / Corrected:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorSelection.keys.map((colorName) {
                          final isChecked = _colorSelection[colorName] ?? false;
                          return FilterChip(
                            selected: isChecked,
                            label: Text(colorName, style: TextStyle(fontWeight: FontWeight.bold, color: isChecked ? Colors.black : Colors.grey.shade800)),
                            selectedColor: Colors.amber.shade300,
                            checkmarkColor: Colors.black,
                            onSelected: (val) {
                              setState(() {
                                _colorSelection[colorName] = val;
                                _updateRemadeColorsFromCheckboxes();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _remadeColorsController,
                        decoration: const InputDecoration(
                          labelText: 'Remade / Changed Colors Summary *',
                          hintText: 'e.g. Black Plate Remade (Text Change), Spot P353C',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _revisionReasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Revision / Correction',
                          hintText: 'e.g. Customer ingredient text correction',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _colorDetailsController,
                              decoration: const InputDecoration(labelText: 'Full Color List Breakdown'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _rackBinController,
                              decoration: const InputDecoration(labelText: 'Storage Rack Location'),
                            ),
                          ),
                        ],
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
                    _isSaving ? 'Saving Revision...' : 'Save & Issue Revised Plate Master',
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
