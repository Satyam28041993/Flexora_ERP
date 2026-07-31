import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/iso_control_header.dart';
import '../../../job_card_master/data/models/job_card_model.dart';
import '../../../job_card_master/logic/job_card_providers.dart';
import '../../data/models/qc_control_record_model.dart';
import '../../logic/qc_providers.dart';

class QCInspectionFormScreen extends ConsumerStatefulWidget {
  const QCInspectionFormScreen({super.key});

  @override
  ConsumerState<QCInspectionFormScreen> createState() => _QCInspectionFormScreenState();
}

class _QCInspectionFormScreenState extends ConsumerState<QCInspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedGateType = QCGateType.gate2StartUp;
  JobCardModel? _selectedJobCard;

  late TextEditingController _inspectorController;
  late TextEditingController _codeController;
  late TextEditingController _remarksController;

  String _disposition = QCDisposition.passed;

  final Map<String, bool> _checklistResults = {
    'Text Matter & Spelling Correctness': true,
    'Artwork Content Match against Approved Proof': true,
    'Color Match against Approved Shade Card': true,
    'Rub Test & Ink Adhesion Check': true,
    'Web Tension & Die Registration': true,
    'Label Dimensions & Cutting Accuracy': true,
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _inspectorController = TextEditingController(text: 'QC Inspector');
    _codeController = TextEditingController(
      text: 'QC-${DateTime.now().millisecondsSinceEpoch % 1000}',
    );
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    _codeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _onGateChanged(String? gateType) {
    if (gateType == null) return;
    setState(() {
      _selectedGateType = gateType;
      _checklistResults.clear();
      if (gateType == QCGateType.gate1Incoming) {
        _checklistResults.addAll({
          'Roll Width Accuracy Check': true,
          'Substrate Material Spec Verification': true,
          'GSM / Micron Measurement Check': true,
          'Vendor Batch / Lot Traceability Check': true,
          'Visual Surface Defect Check': true,
        });
      } else if (gateType == QCGateType.gate2StartUp) {
        _checklistResults.addAll({
          'Text Matter & Spelling Correctness': true,
          'Artwork Content Match against Approved Proof': true,
          'Color Match against Approved Shade Card': true,
          'Rub Test & Ink Adhesion Check': true,
          'Web Tension & Die Registration': true,
          'Label Dimensions & Cutting Accuracy': true,
        });
      } else {
        _checklistResults.addAll({
          'Winding & Unwinding Direction Check': true,
          'Label Orientation (Face Out/In) Check': true,
          'Labels Per Roll Count Accuracy': true,
          'Slitting Edge Quality Check': true,
          'Box Packaging & Packing List Match': true,
        });
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(qcRepositoryProvider);

      final record = QCControlRecordModel(
        id: '',
        plantId: DefaultPlant.id,
        gateType: _selectedGateType,
        recordCode: _codeController.text.trim().toUpperCase(),
        jobCardId: _selectedJobCard?.id,
        jobCardNo: _selectedJobCard?.jobCardNo,
        customerName: _selectedJobCard?.customerName ?? 'Incoming Material Vendor',
        productName: _selectedJobCard?.productName ?? 'Raw Material Roll',
        inspectionDate: DateTime.now(),
        inspectorName: _inspectorController.text.trim(),
        checklistResults: _checklistResults,
        disposition: _disposition,
        remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        createdAt: DateTime.now(),
        createdBy: 'qc',
      );

      await repo.createQCRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QC Release Gate inspection logged successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving QC inspection: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobCardsAsync = ref.watch(jobCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Log QC Gate Inspection')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ISOControlHeader(
              docTitle: 'INSPECTION & RELEASE CHECKLIST',
              docNo: 'PGPL/QC/F-02',
              department: 'Quality Assurance',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGateType,
              decoration: const InputDecoration(labelText: 'Select QC Release Gate *'),
              items: const [
                DropdownMenuItem(value: QCGateType.gate1Incoming, child: Text('QC Gate 1 — Incoming Material Release')),
                DropdownMenuItem(value: QCGateType.gate2StartUp, child: Text('QC Gate 2 — Production Start-Up Release')),
                DropdownMenuItem(value: QCGateType.gate3Final, child: Text('QC Gate 3 — Finished Goods Release')),
              ],
              onChanged: _onGateChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'QC Record Code *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _inspectorController,
                    decoration: const InputDecoration(labelText: 'Inspector Name *'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedGateType != QCGateType.gate1Incoming)
              jobCardsAsync.when(
                data: (jobCards) => DropdownButtonFormField<JobCardModel>(
                  value: _selectedJobCard,
                  decoration: const InputDecoration(labelText: 'Link Job Card *'),
                  items: jobCards
                      .map((j) => DropdownMenuItem(value: j, child: Text('${j.jobCardNo} (${j.productName})')))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedJobCard = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
            const SizedBox(height: 20),
            const Text('Mandatory QC Release Checklist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
            const Divider(),
            ..._checklistResults.keys.map((checkItem) {
              final isPassed = _checklistResults[checkItem] ?? true;
              return CheckboxListTile(
                title: Text(checkItem, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                value: isPassed,
                onChanged: (val) => setState(() => _checklistResults[checkItem] = val ?? false),
                activeColor: Colors.green,
              );
            }),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _disposition,
              decoration: const InputDecoration(labelText: 'QC Disposition / Decision *'),
              items: QCDisposition.values
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _disposition = val);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'QC Remarks / Hold Notes'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.check),
                label: Text(_isSaving ? 'Submitting...' : 'Submit QC Release Record'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
