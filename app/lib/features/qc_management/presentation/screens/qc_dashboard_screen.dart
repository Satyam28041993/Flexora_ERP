import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/iso_control_header.dart';
import '../../data/models/qc_control_record_model.dart';
import '../../logic/qc_providers.dart';
import 'qc_inspection_form_screen.dart';

class QCDashboardScreen extends ConsumerStatefulWidget {
  const QCDashboardScreen({super.key});

  @override
  ConsumerState<QCDashboardScreen> createState() => _QCDashboardScreenState();
}

class _QCDashboardScreenState extends ConsumerState<QCDashboardScreen> {
  String? _selectedGateType;

  @override
  Widget build(BuildContext context) {
    final qcRecordsAsync = ref.watch(qcRecordsStreamProvider(_selectedGateType));

    return Scaffold(
      appBar: AppBar(title: const Text('Quality Control & 3 QC Gates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QCInspectionFormScreen()),
        ),
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('New QC Inspection'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ISOControlHeader(
              docTitle: 'QUALITY CONTROL RELEASE RECORD',
              docNo: 'PGPL/QC/F-01',
              department: 'Quality Assurance',
              revisionNo: '01',
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('All QC Gates'),
                  selected: _selectedGateType == null,
                  onSelected: (_) => setState(() => _selectedGateType = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gate 1: Incoming Material'),
                  selected: _selectedGateType == QCGateType.gate1Incoming,
                  onSelected: (_) => setState(() => _selectedGateType = QCGateType.gate1Incoming),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gate 2: Start-Up Release'),
                  selected: _selectedGateType == QCGateType.gate2StartUp,
                  onSelected: (_) => setState(() => _selectedGateType = QCGateType.gate2StartUp),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gate 3: Finished Goods'),
                  selected: _selectedGateType == QCGateType.gate3Final,
                  onSelected: (_) => setState(() => _selectedGateType = QCGateType.gate3Final),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: qcRecordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No QC Control records found for this gate.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _QCCard(record: records[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading QC records: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _QCCard extends StatelessWidget {
  const _QCCard({required this.record});

  final QCControlRecordModel record;

  @override
  Widget build(BuildContext context) {
    final isPassed = record.disposition == QCDisposition.passed;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record.recordCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                Chip(
                  label: Text(record.disposition.toUpperCase()),
                  backgroundColor: isPassed ? Colors.green.shade50 : Colors.red.shade50,
                  labelStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(record.gateTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (record.jobCardNo != null)
              Text('Job Card: ${record.jobCardNo} | Customer: ${record.customerName}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inspector: ${record.inspectorName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text('ISO Ref: ${record.isoDocNo} Rev ${record.isoRevisionNo}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
