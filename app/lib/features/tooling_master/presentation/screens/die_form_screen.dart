import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/die_model.dart';
import '../../logic/tooling_providers.dart';

class DieFormScreen extends ConsumerStatefulWidget {
  const DieFormScreen({super.key, this.die});

  final DieModel? die;

  @override
  ConsumerState<DieFormScreen> createState() => _DieFormScreenState();
}

class _DieFormScreenState extends ConsumerState<DieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  String _dieType = 'Flexible Magnetic Die';
  String _shape = 'Rectangle';

  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _cornerController;
  late TextEditingController _repeatController;
  late TextEditingController _teethController;
  late TextEditingController _acrossUpsController;
  late TextEditingController _aroundUpsController;
  late TextEditingController _rackBinController;

  String _condition = DieCondition.good;
  String _status = DieStatus.available;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.die;

    _codeController = TextEditingController(text: d?.dieCode ?? '');
    _dieType = d?.dieType ?? 'Flexible Magnetic Die';
    _shape = d?.shape ?? 'Rectangle';

    _widthController = TextEditingController(text: d?.labelWidthMm.toString() ?? '50');
    _heightController = TextEditingController(text: d?.labelHeightMm.toString() ?? '80');
    _cornerController = TextEditingController(text: d?.cornerRadiusMm.toString() ?? '2');
    _repeatController = TextEditingController(text: d?.cylinderRepeatMm.toString() ?? '300');
    _teethController = TextEditingController(text: d?.gearTeethCount.toString() ?? '96');
    _acrossUpsController = TextEditingController(text: d?.acrossUps.toString() ?? '2');
    _aroundUpsController = TextEditingController(text: d?.aroundUps.toString() ?? '4');
    _rackBinController = TextEditingController(text: d?.storageRackBin ?? 'Rack D-1');

    _condition = d?.condition ?? DieCondition.good;
    _status = d?.status ?? DieStatus.available;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _cornerController.dispose();
    _repeatController.dispose();
    _teethController.dispose();
    _acrossUpsController.dispose();
    _aroundUpsController.dispose();
    _rackBinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(toolingRepositoryProvider);

      final dieData = DieModel(
        id: widget.die?.id ?? '',
        plantId: DefaultPlant.id,
        dieCode: _codeController.text.trim().toUpperCase(),
        dieType: _dieType,
        shape: _shape,
        labelWidthMm: double.parse(_widthController.text.trim()),
        labelHeightMm: double.parse(_heightController.text.trim()),
        cornerRadiusMm: double.parse(_cornerController.text.trim()),
        cylinderRepeatMm: double.parse(_repeatController.text.trim()),
        gearTeethCount: int.parse(_teethController.text.trim()),
        acrossUps: int.parse(_acrossUpsController.text.trim()),
        aroundUps: int.parse(_aroundUpsController.text.trim()),
        storageRackBin: _rackBinController.text.trim(),
        condition: _condition,
        status: _status,
        createdAt: widget.die?.createdAt ?? DateTime.now(),
        createdBy: widget.die?.createdBy ?? 'system',
        updatedAt: widget.die != null ? DateTime.now() : null,
        updatedBy: widget.die != null ? 'system' : null,
      );

      if (widget.die == null) {
        await repo.createDie(dieData);
      } else {
        await repo.updateDie(dieData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.die == null ? 'Die registered successfully' : 'Die updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving die: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.die == null ? 'New Punch / Die Master' : 'Edit Punch / Die Master')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Die Code *', hintText: 'e.g. DIE-50x80-2x4'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _dieType,
                    decoration: const InputDecoration(labelText: 'Die Type'),
                    items: ['Flexible Magnetic Die', 'Solid Cylinder Die']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _dieType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(labelText: 'Label Width (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Label Height (mm) *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _shape,
                    decoration: const InputDecoration(labelText: 'Shape'),
                    items: ['Rectangle', 'Circle', 'Oval', 'Custom']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _shape = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _acrossUpsController,
                    decoration: const InputDecoration(labelText: 'Across UPS *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _aroundUpsController,
                    decoration: const InputDecoration(labelText: 'Around UPS *'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _teethController,
                    decoration: const InputDecoration(labelText: 'Teeth (Z Count)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _repeatController,
                    decoration: const InputDecoration(labelText: 'Cylinder Repeat (mm)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rackBinController,
                    decoration: const InputDecoration(labelText: 'Storage Location / Rack'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _condition,
                    decoration: const InputDecoration(labelText: 'Die Condition'),
                    items: DieCondition.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _condition = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: DieStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Die Master'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
